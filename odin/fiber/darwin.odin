#+build darwin
package fiber


import "core:c"
import "core:reflect"
import "core:net"

import "core:sys/posix"
foreign import libfiber "libfiber.a"

@(private)
__Errno :: posix.errno
@(private)
_dial_tcp_from_endpoint :: proc(endpoint: net.Endpoint, options := net.default_tcp_options) -> (skt: net.TCP_Socket, err: Error) {
	if endpoint.port == 0 {
		return 0, .Port_Required
	}

	family := net.family_from_endpoint(endpoint)
	sock :=net.create_socket(family, .TCP) or_return
	skt = sock.(net.TCP_Socket)

	// NOTE(tetra): This is so that if we crash while the socket is open, we can
	// bypass the cooldown period, and allow the next run of the program to
	// use the same address immediately.
	_ = set_option(skt, .Reuse_Address, true)

	sockaddr := _endpoint_to_sockaddr(endpoint)
	if Errno(acl_fiber_connect(socket_t(skt), (^posix.sockaddr)(&sockaddr), posix.socklen_t(sockaddr.ss_len))) != .OK {
		err =  Errno(acl_fiber_last_error())
		close(skt)
	}

	return
}

@(private)
_bind :: proc(skt: Any_Socket, ep: net.Endpoint) -> (err: Error) {
	sockaddr := _endpoint_to_sockaddr(ep)
	s := net.any_socket_to_socket(skt)
	if posix.bind(posix.FD(s), (^posix.sockaddr)(&sockaddr), posix.socklen_t(sockaddr.ss_len)) != .OK {
		err = last_fiber_error()
	}

	return
}

@(private)
_listen_tcp :: proc(interface_endpoint: net.Endpoint, backlog := 1000) -> (skt: net.TCP_Socket, err: Error) {
	assert(backlog > 0 && i32(backlog) < max(i32))

	family := net.family_from_endpoint(interface_endpoint)
	sock := net.create_socket(family, .TCP) or_return
	skt = sock.(net.TCP_Socket)
	defer if err != nil { acl_fiber_close(socket_t(skt)) }

	// NOTE(tetra): This is so that if we crash while the socket is open, we can
	// bypass the cooldown period, and allow the next run of the program to
	// use the same address immediately.
	//
	_ = net.set_option(sock, .Reuse_Address, true)

	bind(sock, interface_endpoint) or_return

	if Errno(acl_fiber_listen(socket_t(skt), i32(backlog))) != .OK {
		err = last_fiber_error()
	}

	return
}

@(private)
_bound_endpoint :: proc(sock: net.Any_Socket) -> (ep: net.Endpoint, err: Error) {
	addr: posix.sockaddr_storage
	addr_len := posix.socklen_t(size_of(addr))
	if posix.getsockname(posix.FD(net.any_socket_to_socket(sock)), (^posix.sockaddr)(&addr), &addr_len) != .OK {
		err = last_fiber_error()
		return
	}

	ep = _sockaddr_to_endpoint(&addr)
	return
}

@(private)
_accept_tcp :: proc(sock: net.TCP_Socket, options := net.default_tcp_options) -> (client: net.TCP_Socket, source: net.Endpoint, err: Error) {
	addr: posix.sockaddr_storage
	addr_len := posix.socklen_t(size_of(addr))
	client_sock := acl_fiber_accept(socket_t(sock), (^posix.sockaddr)(&addr), &addr_len)
	if client_sock < 0 {
		err = last_fiber_error()
		return
	}

	client = net.TCP_Socket(client_sock)
	source = _sockaddr_to_endpoint(&addr)
	return
}

@(private)
_close :: proc(skt: net.Any_Socket) {
	s := net.any_socket_to_socket(skt)
	acl_fiber_close(socket_t(s))
}

@(private)
_recv_tcp :: proc(skt: net.TCP_Socket, buf: []byte) -> (bytes_read: int, err: Error) {
	if len(buf) <= 0 {
		return
	}

	res := acl_fiber_recv(socket_t(skt), raw_data(buf), len(buf), 0)
	if res < 0 {
		err = last_fiber_error()
		return
	}

	return int(res), nil
}

@(private)
_recv_udp :: proc(skt: net.UDP_Socket, buf: []byte) -> (bytes_read: int, remote_endpoint: net.Endpoint, err: Error) {
	if len(buf) <= 0 {
		return
	}

	from: posix.sockaddr_storage
	fromsize := posix.socklen_t(size_of(from))
	res := acl_fiber_recvfrom(socket_t(skt), raw_data(buf), len(buf), 0, (^posix.sockaddr)(&from), &fromsize)
	if res < 0 {
		err = last_fiber_error()
		return
	}

	bytes_read = int(res)
	remote_endpoint = _sockaddr_to_endpoint(&from)
	return
}

@(private)
_send_tcp :: proc(skt: net.TCP_Socket, buf: []byte) -> (bytes_written: int, err: Error) {
	for bytes_written < len(buf) {
		limit := min(int(max(i32)), len(buf) - bytes_written)
		remaining := buf[bytes_written:][:limit]
		flags : bit_set[posix.Msg_Flag_Bits; i32]= {.NOSIGNAL}
		res := acl_fiber_send(socket_t(skt), raw_data(remaining), len(remaining), i32(flags))
		if res < 0 {
			err = last_fiber_error()
			return
		}

		bytes_written += int(res)
	}
	return
}

@(private)
_send_udp :: proc(skt: net.UDP_Socket, buf: []byte, to: net.Endpoint) -> (bytes_written: int, err: net.UDP_Send_Error) {
	toaddr := _endpoint_to_sockaddr(to)
	for bytes_written < len(buf) {
		limit := min(1<<31, len(buf) - bytes_written)
		remaining := buf[bytes_written:][:limit]
		flags : bit_set[posix.Msg_Flag_Bits; i32]= {.NOSIGNAL}

		res := acl_fiber_sendto(socket_t(skt), raw_data(remaining), len(remaining),i32(flags) , (^posix.sockaddr)(&toaddr), posix.socklen_t(toaddr.ss_len))
		if res < 0 {
			err = last_fiber_error()
			return
		}

		bytes_written += int(res)
	}
	return
}

@(private)
_shutdown :: proc(skt: net.Any_Socket, manner: net.Shutdown_Manner) -> (err: Error) {
	s := net.any_socket_to_socket(skt)
	if posix.shutdown(posix.FD(s), posix.Shut(manner)) != .OK {
		err = last_fiber_error()
	}
	return
}

@(private)
_set_option :: proc(s: net.Any_Socket, option: net.Socket_Option, value: any, loc := #caller_location) -> Error {
	level := posix.SOL_SOCKET if option != .TCP_Nodelay else posix.IPPROTO_TCP

	// NOTE(tetra, 2022-02-15): On Linux, you cannot merely give a single byte for a bool;
	//  it _has_ to be a b32.
	//  I haven't tested if you can give more than that.
	bool_value: b32
	int_value: posix.socklen_t
	timeval_value: posix.timeval

	ptr: rawptr
	len: posix.socklen_t

	switch option {
	case
		.Broadcast,
		.Reuse_Address,
		.Keep_Alive,
		.Out_Of_Bounds_Data_Inline,
		.TCP_Nodelay:
		// TODO: verify whether these are options or not on Linux
		// .Broadcast,
		// .Conditional_Accept,
		// .Dont_Linger:
			switch x in value {
			case bool, b8:
				x2 := x
				bool_value = b32((^bool)(&x2)^)
			case b16:
				bool_value = b32(x)
			case b32:
				bool_value = b32(x)
			case b64:
				bool_value = b32(x)
			case:
				panic("set_option() value must be a boolean here", loc)
			}
			ptr = &bool_value
			len = size_of(bool_value)
	case
		.Linger,
		.Send_Timeout,
		.Receive_Timeout:
			t := value.(time.Duration) or_else panic("set_option() value must be a time.Duration here", loc)

			micros := i64(time.duration_microseconds(t))
			timeval_value.tv_usec = posix.suseconds_t(micros % 1e6)
			timeval_value.tv_sec  = posix.time_t(micros - i64(timeval_value.tv_usec)) / 1e6

			ptr = &timeval_value
			len = size_of(timeval_value)
	case
		.Receive_Buffer_Size,
		.Send_Buffer_Size:
			// TODO: check for out of range values and return .Value_Out_Of_Range?
			switch i in value {
			case i8, u8:   i2 := i; int_value = posix.socklen_t((^u8)(&i2)^)
			case i16, u16: i2 := i; int_value = posix.socklen_t((^u16)(&i2)^)
			case i32, u32: i2 := i; int_value = posix.socklen_t((^u32)(&i2)^)
			case i64, u64: i2 := i; int_value = posix.socklen_t((^u64)(&i2)^)
			case i128, u128: i2 := i; int_value = posix.socklen_t((^u128)(&i2)^)
			case int, uint: i2 := i; int_value = posix.socklen_t((^uint)(&i2)^)
			case:
				panic("set_option() value must be an integer here", loc)
			}
			ptr = &int_value
			len = size_of(int_value)
	}

	skt := net.any_socket_to_socket(s)
	if posix.setsockopt(posix.FD(skt), i32(level), posix.Sock_Option(option), ptr, len) != .OK {
		return last_fiber_error()
	}

	return nil
}

@(private)
_set_blocking :: proc(socket: net.Any_Socket, should_block: bool) -> (err: Error) {
	socket := net.any_socket_to_socket(socket)

	flags_ := posix.fcntl(posix.FD(socket), .GETFL, 0)
	if flags_ < 0 {
		return last_fiber_error()
	}
	flags := transmute(posix.O_Flags)flags_

	if should_block {
		flags -= {.NONBLOCK}
	} else {
		flags += {.NONBLOCK}
	}

	if posix.fcntl(posix.FD(socket), .SETFL, flags) < 0 {
		return last_fiber_error()
	}

	return nil
}

@private
_endpoint_to_sockaddr :: proc(ep: net.Endpoint) -> (sockaddr: posix.sockaddr_storage) {
	switch a in ep.address {
	case net.IP4_Address:
		(^posix.sockaddr_in)(&sockaddr)^ = posix.sockaddr_in {
			sin_port = u16be(ep.port),
			sin_addr = transmute(posix.in_addr)a,
			sin_family = .INET,
			sin_len = size_of(posix.sockaddr_in),
		}
		return
	case net.IP6_Address:
		(^posix.sockaddr_in6)(&sockaddr)^ = posix.sockaddr_in6 {
			sin6_port = u16be(ep.port),
			sin6_addr = transmute(posix.in6_addr)a,
			sin6_family = .INET6,
			sin6_len = size_of(posix.sockaddr_in6),
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