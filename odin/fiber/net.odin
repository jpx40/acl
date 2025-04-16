package fiber
import "core:net"

listen_tcp :: proc(interface_endpoint: net.Endpoint, backlog := 1000) -> (socket: net.TCP_Socket, err: Error) {
	assert(backlog > 0 && backlog < int(max(i32)))

	return _listen_tcp(interface_endpoint, backlog)
}
recv_tcp :: proc(socket: net.TCP_Socket, buf: []byte) -> (bytes_read: int, err: Error) {
	return _recv_tcp(socket, buf)
}
accept_tcp :: proc(socket: net.TCP_Socket, options := net.default_tcp_options) -> (client: net.TCP_Socket, source: net.Endpoint, err: Error) {
	return _accept_tcp(socket, options)
}
recv_udp :: proc(socket: net.UDP_Socket, buf: []byte) -> (bytes_read: int, remote_endpoint: net.Endpoint, err: net.UDP_Recv_Error) {
	return _recv_udp(socket, buf)
}
close_tcp :: proc(sock:net.TCP_Socket) -> int {
    return int(acl_fiber_close(socket(sock)))
}


recv :: proc{recv_tcp, recv_udp}




/*
	Repeatedly sends data until the entire buffer is sent.
	If a send fails before all data is sent, returns the amount sent up to that point.
*/
send_tcp :: proc(socket: TCP_Socket, buf: []byte) -> (bytes_written: int, err: TCP_Send_Error) {
	return _send_tcp(socket, buf)
}

/*
	Sends a single UDP datagram packet.

	Datagrams are limited in size; attempting to send more than this limit at once will result in a Message_Too_Long error.
	UDP packets are not guarenteed to be received in order.
*/
send_udp :: proc(socket: UDP_Socket, buf: []byte, to: Endpoint) -> (bytes_written: int, err: UDP_Send_Error) {
	return _send_udp(socket, buf, to)
}


