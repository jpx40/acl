package rc
import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:reflect"
import "core:sync"
Rc :: struct($T: typeid) {
	inner: ^RcInner(T),
}


RcInner :: struct($T: typeid) {
	data:    T,
	cleanup: Maybe(proc(_: rawptr) -> runtime.Allocator_Error),
	count:   u32,
}


cleanup_proc :: #type proc(_: rawptr) -> runtime.Allocator_Error  
init_with_data_and_cleanup ::proc( 	data: $T,
	cleanup:cleanup_proc,
 	allocator := context.allocator,)-> (
		Rc(T),
		runtime.Allocator_Error,
) {

		rc: Rc(T)
		inner, err := new(RcInner(T))
		if err != nil {
			if inner != nil {
				runtime.free(inner, allocator = allocator)
			}

			return rc, err
		}
		inner.data = data
		inner.count = 1
		inner.cleanup = cleanup
		rc.inner = inner
		return rc, nil
}
init_with_data :: proc(
	data: $T,
	allocator := context.allocator,

) -> (
	Rc(T),
	runtime.Allocator_Error,
) {

	rc: Rc(T)
	inner, err := new(RcInner(T))
	if err != nil {
		if inner != nil {
			free(inner, allocator = allocator)
		}

		return rc, err
	}
	inner.data = data
	inner.count = 1
	inner.cleanup = nil
	rc.inner = inner
	return rc, nil
}

get :: proc( rc: ^Rc($T)  ) -> (v: T,b: bool) {

    if rc.inner != nil {
        v = rc.inner.data
        b = true
        return 
    
    
    }
    return 

}
get_ptr :: proc( rc: ^Rc($T)  ) -> (v: ^T,b: bool) {

    if rc.inner != nil {
        v = &rc.inner.data
        b = true
        return 
    
    
    }
    return 

}

clone :: proc(rc: ^Rc($T)) -> Rc(T) {
	a: Rc(T)
	if rc.inner != nil {
		rc.inner.count += 1
		a = rc^
		return a
	}
	return a
}

delete ::free
free :: proc(rc: ^Rc($T),allocator := context.allocator) {
	if rc.inner != nil {

		rc.inner.count -= 1
		if 0 == rc.inner.count {

			switch func in rc.inner.cleanup {
			case proc(_: rawptr) -> runtime.Allocator_Error:
				{

					// if reflect.is_pointer(type_info_of(rc.inner.data)) {
					// 	func(rawptr(rc.inner.data))
					// 	runtime.mem_free(rc.inner, allocator = allocator)
					// 	return
					// }
						if rc.inner != nil {
					func(rawptr( &rc.inner.data))
					runtime.mem_free(rc.inner , allocator = allocator)
					}
					return

				}
			case nil:
				if rc.inner != nil {
			    runtime.mem_free(rc.inner)
							}
				return
			}
		}

	}
}
