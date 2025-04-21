package fiber_sync

import "base:intrinsics"
import "core:sync"
import "core:mem/virtual"
import "core:mem"
import "core:container/queue"
import "core:container/intrusive/list"
import "../../fiber"
Ok :: struct($T: typeid) {
    val: T

}
Error :: struct($T: typeid) {
    val: T

}
Result :: union($T,$D :typeid) {
    
    Ok(T),
    Error(D)

}


Waiter :: struct($T: typeid) {
using node: list.Node,
// Atomic
finished : bool,
enqueue : Result(T,fiber.Error)

}

WaiterList :: struct {
    arena: mem.Dynamic_Arena,
    waiters: list.List
}

get_waiter :: proc(node: ^list.Node, $T: typeid) -> ^Waiter(T) {
    if node == nil {
		return nil
	}
	offset := offset_of_by_string(Waiter(T), "node")
	return (^Waiter(T))(uintptr(node) - offset)
}

add_waiter :: proc(wl:  ^WaiterList, n: $T ) -> ^Waiter(T) {
   w ,_  := new(Waiter(T),mem.dynamic_arena_allocator(&wl.arena))
   
return w

}
add_waiter_clone :: proc(wl:  ^WaiterList, n: Waiter($T) ) -> ^Waiter(T) {
   w ,_  := new_clone(n,mem.dynamic_arena_allocator(&wl.arena))
   
return w

}