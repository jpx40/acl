package fiber


import "core:c"

import "core:sys/posix"
foreign import libfiber "libfiber.a"

socket_t :: distinct i32

@(default_calling_convention="c")
foreign libfiber {


    
    acl_fiber_socket :: proc(domain: c.int,type: c.int,protocol: c.int) -> socket_t ---
    acl_fiber_listen :: proc(sock: socket_t,backlog: c.int) -> c.int ---
    acl_fiber_close :: proc(fd: socket_t) -> c.int ---
    acl_fiber_accept :: proc(sock: socket_t , addr :^posix.sockaddr, socklen : ^posix.socklen_t ) -> socket_t ---
    acl_fiber_connect :: proc(sock: socket_t , addr: ^posix.sockaddr ,socklen: posix.socklen_t ) -> c.int ---
    acl_fiber_read :: proc(socket_t,buf: [^]u8,count: c.size_t) -> c.ssize_t
    acl_fiber_readv :: proc(socket: socket_t,iov: posix.iovec,iovcnt: c.int) -> c.ssize_t ---
    acl_fiber_recvmsg :: proc(socket: socket_t, msg: posix.msghdr, flags:c.int)  -> c.ssize_t---


    
    
    FIBER_API ssize_t acl_fiber_write(socket_t, const void* buf, size_t count);
    FIBER_API ssize_t acl_fiber_writev(socket_t, const struct iovec* iov, int iovcnt);
    FIBER_API ssize_t acl_fiber_sendmsg(socket_t, const struct msghdr* msg, int flags);
    
    FIBER_API ssize_t acl_fiber_recv(socket_t, void* buf, size_t len, int flags);
    FIBER_API ssize_t acl_fiber_recvfrom(socket_t, void* buf, size_t len, int flags,
	struct sockaddr* src_addr, socklen_t* addrlen);
    
    FIBER_API ssize_t acl_fiber_send(socket_t, const void* buf, size_t len, int flags);
    FIBER_API ssize_t acl_fiber_sendto(socket_t, const void* buf, size_t len, int flags,
	const struct sockaddr* dest_addr, socklen_t addrlen);
    
    FIBER_API int acl_fiber_select(int nfds, fd_set *readfds, fd_set *writefds,
	fd_set *exceptfds, struct timeval *timeout);
    FIBER_API int acl_fiber_poll(struct pollfd *fds, nfds_t nfds, int timeout);
    
    FIBER_API struct hostent *acl_fiber_gethostbyname(const char *name);
    FIBER_API int acl_fiber_gethostbyname_r(const char *name, struct hostent *ent,
	char *buf, size_t buflen, struct hostent **result, int *h_errnop);
    FIBER_API int acl_fiber_getaddrinfo(const char *node, const char *service,
	const struct addrinfo* hints, struct addrinfo **res);
    FIBER_API void acl_fiber_freeaddrinfo(struct addrinfo *res);
    
    #endif
    
    FIBER_API void acl_fiber_set_sysio(socket_t fd);
}