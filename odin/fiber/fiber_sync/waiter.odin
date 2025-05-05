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
enqueue :proc(Result(T,fiber.Error)) 

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

add_waiter :: proc(wl:  ^WaiterList, $T: typeid ) -> ^Waiter(T) {
   w ,_  := new(Waiter(T),mem.dynamic_arena_allocator(&wl.arena))
   list.push_back(wl,w.node)
return w

}
add_waiter_clone :: proc(wl:  ^WaiterList, n: Waiter($T) ) -> ^Waiter(T) {
   w ,_  := new_clone(n,mem.dynamic_arena_allocator(&wl.arena))
   
return w

}

wake ::proc(waiter: ^Waiter($T),data: T) -> bool {
    if sync.atomic_compare_exchange_strong(&waiter.finished,false,true) {
       waiter.enqueue(Ok(T) {data} )
       return true
    }
    return false
    
}

wake_all :: proc(wl: ^WaiterList,data: $T)  {
    iter := list.iterator_head(wl.waiters,Waiter(T), "node")
    
    for w in list.iterate_next(&iter) {
        wake(w,data)
    }

}

WaiterError ::  enum {
 Empty,
 Ok
}
wake_one :: proc(wl: ^WaiterList,data: $T) -> WaiterError {
    for {
        if list.is_empty(wl.waiters) {
            return .Empty
        }
        n:= list.pop_front(wl.waiters)       
        w :=get_waiter(n,T)
       if !wake(w,data) {
            list.push_back(wl.waiters,w.node)
            continue
       } else {
       
       return .Ok
       }
    }
    return .Empty

}
 
await_internal :: proc(mu: ^Mutex,wl :^WaiterList , $T:typeid, ctx: rawptr, enqueue:proc(res: Result(T,fiber.Error) )) {

    resolved_waiter: ^Waiter(T)
    finished: bool
    resolved_waiter.finished = false
    resolved_waiter.enqueue = enqueue
    if mutex != nil  {
    
     add_waiter_clone(resolved_waiter)
     mutex_unlock(mu)
    } else {
    add_waiter_clone(resolved_waiter)
 
}
WaiterCtx :: struct($T: typeid) {
mu: ^Mutex,
wl: ^WaiterList,
func: proc(res: Result(T,fiber.Error))
}
await ::proc(ctx :^WaiterCtx($T)) {

fb := fiber.create(proc(fb:fiber.Fiber, data: rawptr) {

    
},ctx)


return
}