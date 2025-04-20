package arc


import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:reflect"
import "core:sync"
Arc :: struct($T: typeid) {
	inner: ^ArcInner(T),
}


ArcInner :: struct($T: typeid) {
	data:    T,
	cleanup: Maybe(proc(_: rawptr) -> runtime.Allocator_Error),
	count:   u32,
}


get :: proc(arc: ^Arc($T)) -> (v: T, b: bool) {

	if arc.inner != nil {
		v = arc.inner.data
		b = true
		return


	}
	return

}
get_ptr :: proc( rc: ^Arc($T)  ) -> (v: ^T,b: bool) {

    if rc.inner != nil {
        v = &rc.inner.data
        b = true
        return 
    
    
    }
    return 

}
cleanup_proc :: #type proc(_: rawptr) -> runtime.Allocator_Error  

init_with_data_and_cleanup :: proc(
	data: $T,
	cleanup: cleanup_proc ,
allocator := context.allocator)	-> (Arc(T), runtime.Allocator_Error) {

		arc: Arc(T)
		inner, err2 := new(ArcInner(T),allocator = allocator)
		if err2 != nil {
			if inner != nil {
				runtime.mem_free(inner, allocator = allocator)
			}

			return arc, err2
		}
		inner.data = data
		inner.count = 1
		inner.cleanup = cleanup
		arc.inner = inner
		return arc, nil
}
init_with_data :: proc(
	data: $T,
	allocator := context.allocator
) -> (
	Arc(T),
	runtime.Allocator_Error,
) {

	arc: Arc(T)
	inner, err := new(ArcInner(T))
	if err != nil {
		runtime.mem_free(inner, allocator = allocator)
		return arc, err
	}
	inner.data = data
	inner.count = 1
	inner.cleanup = nil
	arc.inner = inner
	return arc, nil
}


clone :: proc(arc: ^Arc($T)) -> Arc(T) {
	a: Arc(T)
	if arc.inner != nil {

		intrinsics.atomic_add(&arc.inner.count, 1)
		a = arc^
		return a
	}

	return a
}

free :: delete
delete :: proc(arc: ^Arc($T), allocator := context.allocator) {
	if arc.inner != nil {
        _  =intrinsics.atomic_sub(&arc.inner.count, 1)
		if 0 == arc.inner.count {

			switch func in arc.inner.cleanup {
			case proc(_: rawptr) -> runtime.Allocator_Error:
				{

					// if reflect.is_pointer(type_info_of(arc.inner.data)) {
					// 	func(rawptr(cast(^T)arc.inner.data))
						
					// 	runtime.mem_free(arc.inner, allocator = allocator)
					// 	return
					// }
					if arc.inner != nil {
					func(rawptr(&arc.inner.data))
		
					 runtime.free(arc.inner , allocator = allocator)
						}
					return

				}
			case nil:
				if arc.inner != nil {
						
						runtime.mem_free(arc.inner , allocator = allocator)
						}
				return
			}

		}

	}


}
