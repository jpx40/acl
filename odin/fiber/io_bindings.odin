package fiber


import "core:c"

import "core:sys/posix"
foreign import libfiber "libfiber.a"

socket_t :: distinct i32

mode_t :: distinct u16


@(default_calling_convention="c")
foreign libfiber {


    
    acl_fiber_socket :: proc(domain: c.int,type: c.int,protocol: c.int) -> socket_t ---
    acl_fiber_listen :: proc(sock: socket_t,backlog: c.int) -> c.int ---
    acl_fiber_close :: proc(fd: socket_t) -> c.int ---
    acl_fiber_accept :: proc(sock: socket_t , addr :^posix.sockaddr, socklen : ^posix.socklen_t ) -> socket_t ---
    acl_fiber_connect :: proc(sock: socket_t , addr: ^posix.sockaddr ,socklen: posix.socklen_t ) -> c.int ---
    acl_fiber_read :: proc(socket_t,buf: [^]u8,count: c.size_t) -> c.ssize_t ---
    acl_fiber_readv :: proc(socket: socket_t,iov: ^posix.iovec,iovcnt: c.int) -> c.ssize_t ---
    acl_fiber_recvmsg :: proc(socket: socket_t, msg: ^posix.msghdr, flags:c.int)  -> c.ssize_t---


    
    
    acl_fiber_write :: proc(sock: socket_t,buf: [^]u8,count: c.size_t)  -> c.ssize_t ---
    acl_fiber_writev :: proc(sock: socket_t, iov: ^posix.iovec, iovcnt: c.int )  -> c.ssize_t ---
     acl_fiber_sendmsg :: proc(sock: socket_t, msg: ^posix.msghdr, flags:c.int)  -> c.ssize_t ---
    
     acl_fiber_recv :: proc(sock: socket_t,buf:[^]u8,  len: c.size_t,  flags: c.int)  -> c.ssize_t ---
      acl_fiber_recvfrom :: proc(sock: socket_t,buf:[^]u8,  len: c.size_t,  flags: c.int,
	src_addr: ^posix.sockaddr, addrlen: ^posix.socklen_t)  -> c.ssize_t ---
    
    acl_fiber_send :: proc(sock: socket_t,buf:[^]u8,  len: c.size_t,  flags: c.int) -> c.ssize_t ---
     acl_fiber_sendto :: proc(sock: socket_t, buf:[^]u8,  len: c.size_t,  flags: c.int, dest_addr : ^posix.sockaddr,  addrlen: posix.socklen_t)  -> c.ssize_t ---
    
 //    FIBER_API int acl_fiber_select :: proc(int nfds, fd_set *readfds, fd_set *writefds,
	// fd_set *exceptfds, timeout: ^posix.tim) -> c.int ---
 //    FIBER_API int acl_fiber_poll(struct pollfd *fds, nfds_t nfds, int timeout) -> c.int ---
    
    acl_fiber_gethostbyname :: proc(name: cstring)-> ^posix.hostent ---
     acl_fiber_gethostbyname_r:: proc(name: cstring, ent: ^posix.hostent,buf: [^]u8,  buflen: c.size_t, result: [^]^posix.hostent, h_errnop: c.int)  -> c.int ---
    acl_fiber_getaddrinfo::proc(node: cstring, service: cstring,hints:^posix.addrinfo, res: [^]^posix.addrinfo)  -> c.int ---
    acl_fiber_freeaddrinfo :: proc(res: ^posix.addrinfo) ---
    
    
acl_fiber_set_sysio :: proc( fd: socket_t) ---

acl_fiber_open :: proc(pathname: cstring, #c_vararg flags: ..c.int) -> c.int ---
    
  


    acl_fiber_openat :: proc(dirfd: c.int,pathname: cstring,#c_vararg flags: ..c.int) -> c.int ---
    acl_fiber_renameat2 :: proc(olddirfd: c.int, oldpath: cstring, newdirfd: c.int,newpath: cstring,  flags: c.uint)  -> c.int ---
	acl_fiber_renameat :: proc(olddirfd: c.int,oldpath:cstring,newdirfd:c.int, newpath:cstring) -> c.int ---
    acl_fiber_rename :: proc(oldpath:cstring, newpath: cstring) -> c.int ---
	 acl_fiber_mkdirat :: proc(dirfd: c.int, pathname: cstring,  mode: mode_t) -> c.int ---
	acl_fiber_pread :: proc(fd: c.int, buf: [^]u8,  count: c.size_t,  offset: c.longlong) -> c.ssize_t  ---

    
}