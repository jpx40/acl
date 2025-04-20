
#+build darwin, linux
package fiber
import "core:net"

listen_tcp :: proc(interface_endpoint: net.Endpoint, backlog := 1000) -> (socket: net.TCP_Socket, err: Network_Error) {
	assert(backlog > 0 && backlog < int(max(i32)))

	return _listen_tcp(interface_endpoint, backlog)
}
recv_tcp :: proc(socket: net.TCP_Socket, buf: []byte) -> (bytes_read: int, err: TCP_Recv_Error) {
	return _recv_tcp(socket, buf)
}
accept_tcp :: proc(socket: net.TCP_Socket, options := net.default_tcp_options) -> (client: net.TCP_Socket, source: net.Endpoint, err: Accept_Error) {
	return _accept_tcp(socket, options)
}
recv_udp :: proc(socket: net.UDP_Socket, buf: []byte) -> (bytes_read: int, remote_endpoint: net.Endpoint, err: UDP_Recv_Error) {
	return _recv_udp(socket, buf)
}
close_tcp :: proc(sock:net.TCP_Socket) -> int {
    return int(acl_fiber_close(socket(sock)))
}


close_udp :: proc(sock:net.UDP_Socket) -> int {
    return int(acl_fiber_close(socket(sock)))
}
recv :: proc{recv_tcp, recv_udp}




/*
	Repeatedly sends data until the entire buffer is sent.
	If a send fails before all data is sent, returns the amount sent up to that point.
*/
send_tcp :: proc(socket: net.TCP_Socket, buf: []byte) -> (bytes_written: int, err: TCP_Send_Error) {
	return _send_tcp(socket, buf)
}

/*
	Sends a single UDP datagram packet.

	Datagrams are limited in size; attempting to send more than this limit at once will result in a Message_Too_Long Network_Error.
	UDP packets are not guarenteed to be received in order.
*/
send_udp :: proc(socket: net.UDP_Socket, buf: []byte, to: net.Endpoint) -> (bytes_written: int, err: UDP_Send_Error) {
	return _send_udp(socket, buf, to)
}


bind ::  proc(skt: net.Any_Socket, ep: net.Endpoint) -> (err: Bind_Error) {
return _bind(skt, ep)
}


dial_tcp_from_endpoint :: proc(endpoint: net.Endpoint, options := net.default_tcp_options) -> (net.TCP_Socket, Network_Error) {

return dial_tcp_from_endpoint(endpoint, options)
}
connect ::dial_tcp_from_endpoint
connect_tcp :: dial_tcp_from_endpoint
send :: proc{send_tcp,send_udp}