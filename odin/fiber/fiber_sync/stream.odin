package fiber_sync


import "../../fiber"
import "core:mem"
import "core:sync/chan"

import "../atomic"
Stream :: struct($T: typeid) {
	_stream: ^RawStream(T),
}
StreamError :: union {
	StreamErrorReason,
}

StreamErrorReason :: enum {
	None,
	Closed,
}

@(private)
RawStream :: struct($T: typeid) {
	_mu:     ^Mutex,
	_chan:   chan.Chan(T),
	_arena:  mem.Arena,
	_error:  fiber.Error,
	_open:   atomic.Atomic(bool),
	_waiter: atomic.Atomic(int),
}


stream_create :: proc($T: typeid, size: uint = 10, allocator := context.allocator) -> Stream(T) {
	arena: mem.Arena
	data := make_slice(
		[]byte,
		len = int((size_of(T) * size + size_of(1000 + size_of(RawStream(T)))) * 110) /
		100,
		allocator = allocator,
	)
	mem.arena_init(&arena, data)
	raw := new(RawStream(T), allocator = mem.arena_allocator(&arena))
	raw._chan,_ = chan.create_buffered(chan.Chan(T), cap = size, allocator = mem.arena_allocator(&arena))
	raw._arena = arena

	atomic.store(&raw._open, true)
	return Stream(T){raw}
}

stream_is_open :: proc(s: $S/Stream($T)) -> bool {
	if s._stream == nil {
		return false
	}
	return atomic.load(&s._stream._open)


}


stream_close_ptr :: proc(s: $S/^Stream($T)) {


	if s._stream != nil {
		for {

			if s._stream != nil {
				if atomic.load(&s._stream._waiter) <= 0 {
					atomic.store(&s._stream._open, false)
					return
				}
			} else {
				return
			}
			fiber.yield()
		}


	}



	}
stream_close :: proc(s: $S/Stream($T)) {


	if s._stream != nil {
		for {

			if s._stream != nil {
				if atomic.load(&s._stream._waiter) <= 0 {
					atomic.store(&s._stream._open, false)
					return
				}
			} else {
				return
			}
			fiber.yield()
		}


	}



	}
	stream_free :: proc(s: $S/Stream($T)) {
			if (s._stream != nil) {

				for {
					if (!stream_is_open(s)) {
						if (s._stream._mu != nil) {
							mutex_free(s._stream._mu)
						}

						mem.arena_free_all(&s._stream._arena)
						return
					}
					stream_close(s)
				}
			}


		}
		
		stream_free_ptr :: proc(s: $S/^Stream($T)) {
				if (s._stream != nil) {

					for {
						if (!stream_is_open(s)) {
							if (s._stream._mu != nil) {
								mutex_free(s._stream._mu)
							}

							mem.arena_free_all(&s._stream._arena)
							return
						}
						stream_close(s)
					}
				}


			}
		
		
			stream_send :: proc(s: $S/Stream($T), data: T) -> StreamError {
				if stream_is_open(s) {
					atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) + 1)

					for {

						if stream_is_open(s) {
							if ok := chan.try_send(s._stream._chan, data); ok {

								atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
								return nil
							} else {
								fiber.yield()
							}

						} else {

							atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
							return .Closed
						}}

				}
				return .Closed


			}
			stream_send_ptr :: proc(s: $S/^Stream($T), data: T) -> StreamError {
							if stream_is_open(s^) {
								atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) + 1)

								for {

									if stream_is_open(s^) {
										if ok := chan.try_send(s._stream._chan, data); ok {

											atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
											return nil
										} else {
											fiber.yield()
										}

									} else {

										atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
										return .Closed
									}}

							}
							return .Closed


						}

	
			
			
			stream_recv_ptr :: proc(s: $S/Stream($T)) -> (data: T, err: StreamError) {
					if stream_is_open(s) {

						atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) + 1)
						for {

							if stream_is_open(s^) {
								if d, ok := chan.try_recv(s._stream._chan); ok {
									data = d

									atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
									return
								} else {
									fiber.yield()
								}

							} else {

								atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
								err = .Closed
								return
							}}

					}

					err = .Closed
					return


				}
				
				
				stream_recv :: proc(s: $S/Stream($T)) -> (data: T, err: StreamError) {
						if stream_is_open(s) {

							atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) + 1)
							for {

								if stream_is_open(s) {
									if d, ok := chan.try_recv(s._stream._chan); ok {
										data = d

										atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
										return
									} else {
										fiber.yield()
									}

								} else {

									atomic.store(&s._stream._waiter, atomic.load(&s._stream._waiter) - 1)
									err = .Closed
									return
								}}

						}

						err = .Closed
						return


					}