#+build linux
package fiber


import "core:c"
import "core:reflect"
import "core:sys/linux"
import "core:net"

import "core:sys/posix"
foreign import libfiber "libfiber.a"
@(default_calling_convention="c")
foreign libfiber { 

 acl_fiber_share_epoll :: proc(yes: c.int) ---
}


@(private)
_listen_tcp :: proc(endpoint: net.Endpoint, backlog := 1000) -> (socket: net.TCP_Socket, err: Error ) {
	errno: linux.Errno
	assert(backlog > 0 && i32(backlog) < max(i32))

	// Figure out the address family and address of the endpoint
	ep_family := _unwrap_os_family(net.family_from_endpoint(endpoint))
	ep_address := _unwrap_os_addr(endpoint)

	// Create TCP socket
	os_sock: linux.Fd
	os_sock, errno = linux.socket(ep_family, .STREAM, {.CLOEXEC}, .TCP)
	if errno != .NONE {
		err = int(errno)
	}
	socket = cast(net.TCP_Socket)os_sock
	defer if err != nil { close_tcp(socket) }

	// NOTE(tetra): This is so that if we crash while the socket is open, we can
	// bypass the cooldown period, and allow the next run of the program to
	// use the same address immediately.
	//
	// TODO(tetra, 2022-02-15): Confirm that this doesn't mean other processes can hijack the address!
	do_reuse_addr: b32 = true
	if errno = linux.setsockopt(os_sock, linux.SOL_SOCKET, linux.Socket_Option.REUSEADDR, &do_reuse_addr); errno != .NONE {
		err = int(errno)
		return
	}

	// Bind the socket to endpoint address
	if errno = linux.bind(os_sock, &ep_address); errno != .NONE {
		err = int(errno)
		return
	}

	// Listen on bound socket
	if errno =  linux.Errno(acl_fiber_listen(cast(socket_t)(os_sock), cast(i32) backlog)); errno != .NONE {
		err = int(errno)
	}

	return
}

@(private="file")
_unwrap_os_addr :: proc "contextless" (endpoint: net.Endpoint) -> linux.Sock_Addr_Any {
	switch address in endpoint.address {
	case net.IP4_Address:
		return {
			ipv4 = {
				sin_family = .INET,
				sin_port = u16be(endpoint.port),
				sin_addr = ([4]u8)(endpoint.address.(net.IP4_Address)),
			},
		}
	case net.IP6_Address:
		return {
			ipv6 = {
				sin6_port = u16be(endpoint.port),
				sin6_addr = transmute([16]u8)endpoint.address.(net.IP6_Address),
				sin6_family = .INET6,
			},
		}
	case:
		unreachable()
	}
}

@(private="file")
_unwrap_os_family :: proc "contextless" (family: net.Address_Family) -> linux.Address_Family {
	switch family {
	case .IP4:  return .INET
	case .IP6:  return .INET6
	case:
		unreachable()
	}
}


@(private)
_recv_tcp :: proc(tcp_sock: net.TCP_Socket, buf: []byte) -> (int, Error) {
	if len(buf) <= 0 {
		return 0, nil
	}
	bytes_read := acl_fiber_recv(socket(tcp_sock), raw_data(buf), len(buf), 0)
	if bytes_read <= 0 {
	errno := linux.Errno(acl_fiber_last_error())
	if errno != .NONE {
		return 0, int(errno)
	}
	}
	return int(bytes_read), nil
}

@(private)
_accept_tcp :: proc(sock: net.TCP_Socket, options := net.default_tcp_options) -> (tcp_client: net.TCP_Socket, endpoint: net.Endpoint, err:Error) {
	addr: linux.Sock_Addr_Any
	client_sock, errno := _accept(socket_t(sock), &addr)
	if errno != .NONE {
		return {}, {}, int(errno)
	}
	// NOTE(tetra): Not vital to succeed; error ignored
	val: b32 = cast(b32) options.no_delay
	_ = linux.setsockopt(linux.Fd(client_sock), linux.SOL_TCP, linux.Socket_TCP_Option.NODELAY, &val)
	return net.TCP_Socket(client_sock), _wrap_os_addr(addr), nil
}

@(private="file")
_wrap_os_addr :: proc "contextless" (addr: linux.Sock_Addr_Any) -> net.Endpoint {
	#partial switch addr.family {
	case .INET:
		return {
			address = cast(net.IP4_Address) addr.sin_addr,
			port = cast(int) addr.sin_port,
		}
	case .INET6:
		return {
			port = cast(int) addr.sin6_port,
			address = transmute(net.IP6_Address) addr.sin6_addr,
		}
	case:
		unreachable()
	}
}

_accept :: proc "contextless" (sock: socket, addr: ^$T, sockflags: linux.Socket_FD_Flags = {}) -> (socket, linux.Errno)
where
	T == linux.Sock_Addr_In ||
	T == linux.Sock_Addr_In6 ||
	T == linux.Sock_Addr_Un ||
	T == linux.Sock_Addr_Any
{
	addr_len: i32 = size_of(T)
	ret := acl_fiber_accept(sock, cast(^posix.sockaddr)addr,cast(^posix.socklen_t)( &addr_len))
	return errno_unwrap(ret, socket)
}


// Note(bumbread): This should shrug off a few lines from every syscall.
// Since not any type can be trivially casted to another type, we take two arguments:
// the final type to cast to, and the type to transmute to before casting.
// One transmute + one cast should allow us to get to any type we might want
// to return from a syscall wrapper.
@(private)
errno_unwrap3 :: #force_inline proc "contextless" (ret: $P, $T: typeid, $U: typeid) -> (T, linux.Errno)
where
	intrinsics.type_is_ordered_numeric(P)
{
    using linux
	if ret < 0 {
		default_value: T
		return default_value, Errno(-ret)
	} else {
		return T(transmute(U)ret), Errno(.NONE)
	}
}

@(private)
errno_unwrap2 :: #force_inline proc "contextless" (ret: $P, $T: typeid) -> (T, linux.Errno) {

using linux
	if ret < 0 {
		default_value: T
		return default_value, Errno(-ret)
	} else {
		return T(ret), Errno(.NONE)
	}
}

@(private)
errno_unwrap :: proc {errno_unwrap2, errno_unwrap3}




@(private)
_recv_udp :: proc(udp_sock: net.UDP_Socket, buf: []byte) -> (int, net.Endpoint, Error) {
	if len(buf) <= 0 {
		// NOTE(flysand): It was returning no error, I didn't change anything
		return 0, {}, {}
	}
	// NOTE(tetra): On Linux, if the buffer is too small to fit the entire datagram payload, the rest is silently discarded,
	// and no error is returned.
	// However, if you pass MSG_TRUNC here, 'res' will be the size of the incoming message, rather than how much was read.
	// We can use this fact to detect this condition and return .Buffer_Too_Small.
	from_addr: posix.sockaddr
	flags :linux.Socket_Msg = {.TRUNC}
	sock_len:posix.socklen_t
	bytes_read := acl_fiber_recvfrom(socket(udp_sock),raw_data(buf),   c.size_t(len(buf)),  transmute(i32)(flags),&from_addr , &sock_len)
	if (bytes_read <= 0) {
	errno :=  linux.Errno(acl_fiber_last_error())
	if errno != .NONE {
		return 0, {}, int(errno)
	}
	}
	if bytes_read > len(buf) {
		// NOTE(tetra): The buffer has been filled, with a partial message.
		return len(buf), {}, int(1)
	}
	return bytes_read,  _sockaddr_basic_to_endpoint(&from_addr), nil
	

	}

	@(private)
_set_blocking2 :: proc(socket: net.Any_Socket, should_block: bool) -> (err: Error) {
		socket := net.any_socket_to_socket(socket)

		flags_ := posix.fcntl(posix.FD(socket), .GETFL, 0)
		if flags_ < 0 {
			return 1
		}
		flags := transmute(posix.O_Flags)flags_

		if should_block {
			flags -= {.NONBLOCK}
		} else {
			flags += {.NONBLOCK}
		}

		if posix.fcntl(posix.FD(socket), .SETFL, flags) < 0 {
			return 1
		}

		return nil
}

@private
_endpoint_to_sockaddr :: proc(ep: net.Endpoint) -> (sockaddr: posix.sockaddr_storage) {
		switch a in ep.address {
		case net.IP4_Address:
			(^posix.sockaddr_in)(&sockaddr)^ = {
				sin_port = u16be(ep.port),
				sin_addr = transmute(posix.in_addr)a,
				sin_family = .INET,
				 // sin_len = size_of(posix.sockaddr_in),
			}
			return
		case net.IP6_Address:
			(^posix.sockaddr_in6)(&sockaddr)^ = posix.sockaddr_in6 {
				sin6_port = u16be(ep.port),
				sin6_addr = transmute(posix.in6_addr)a,
				sin6_family = .INET6,
				// sin6_len = size_of(posix.sockaddr_in6),
			}
			return
		}
		unreachable()
}
@private
_sockaddr_to_endpoint :: proc(native_addr: ^posix.sockaddr_storage) -> (ep: net.Endpoint) {
	#partial switch native_addr.ss_family {
	case .INET:
		addr := cast(^posix.sockaddr_in)native_addr
		port := int(addr.sin_port)
		ep = net.Endpoint {
			address = net.IP4_Address(transmute([4]byte)addr.sin_addr),
			port    = port,
		}
	case .INET6:
		addr := cast(^posix.sockaddr_in6)native_addr
		port := int(addr.sin6_port)
		ep = net.Endpoint {
			address = net.IP6_Address(transmute([8]u16be)addr.sin6_addr),
			port    = port,
		}
	case:
		panic("native_addr is neither IP4 or IP6 address")
	}
	return
}
@(private)
_sockaddr_basic_to_endpoint :: proc(native_addr: ^posix.sockaddr) -> (ep: net.Endpoint) {
	#partial switch native_addr.sa_family {
	case .INET:
		addr := cast(^posix.sockaddr_in)native_addr
		port := int(addr.sin_port)
		ep = net.Endpoint {
			address = net.IP4_Address(transmute([4]byte)addr.sin_addr),
			port    = port,
		}
	case .INET6:
		addr := cast(^posix.sockaddr_in6)native_addr
		port := int(addr.sin6_port)
		ep = net.Endpoint {
			address = net.IP6_Address(transmute([8]u16be)addr.sin6_addr),
			port    = port,
		}
	case:
		panic("native_addr is neither IP4 or IP6 address")
	}
	return
}