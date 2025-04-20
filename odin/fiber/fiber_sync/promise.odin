package fiber_sync


import "../../fiber"

import "base:runtime"

import "core:mem"
PromiseState :: enum (i8) {
	UnReseolved,
	Resolved,
	Error,
}

Promise :: struct($T: typeid) {
	_raw: ^RawPromise(T),
}
@(private)
RawPromise :: struct($T: typeid) {
	mu:    ^Mutex,
	data:  T,
	error: fiber.Error,
	state: PromiseState,
}

promise_send :: proc(p: Promise($T), data: T) -> bool {
	if p._raw != nil {
		for {
			if ok := mutex_trylock(p._raw.mu); ok {


				switch p._raw.state {
				case .UnResolved:
					{
						p._raw.data = data

						p._raw.state = .Resolved
						mutex_unlock(p._raw.mu)
						return true
					}
				case _:
					{

						mutex_unlock(p._raw.mu)
						return false
					}

				}
			}
			fiber.yield()
		}
	}
	return false
}

promise_error :: proc(p: Promise($T), err: fiber.Error) -> bool where err != nil {
	if p._raw != nil {
		for {
			if ok := mutex_trylock(p._raw.mu); ok {


				switch p._raw.state {
				case .UnResolved:
					{
						p._raw.error = err
						p._raw.state = .Error
						mutex_unlock(p._raw.mu)

						return true
					}
				case _:
					{

						mutex_unlock(p._raw.mu)
						return false
					}

				}
			}
			fiber.yield()
		}
	}
	return false
}

promise_get_data :: proc(p: Promise($T)) -> (data: T, err: fiber.Error) {
	if p._raw != nil {
		for {
			if ok := mutex_trylock(p._raw.mu); ok {


				switch p._raw.state {
				case .Resolved:
					{
						data = p._raw.data
						mutex_unlock(p._raw.mu)
						return
					}
				case .Error:
					{

						mutex_unlock(p._raw.mu)
						err = p._raw.error
						return
					}
				case .UnResolved:
					{

						mutex_unlock(p._raw.mu)

					}

				}
			}
			fiber.yield()
		}
	}
	return
}
promise_free :: proc(p: Promise($T)) {
	if p._raw != nil {
		if p._raw.mu != nil {
			mutex_free(p._raw.mu)
			mem.free(p._raw)
		}
	}


}
promise_get_and_free :: proc(p: Promise($T)) -> (data: T, err: fiber.Error) {


	data, err = promise_get_data(p)
	promise_free(p)
	return

}


promise_get :: promise_get_and_free

