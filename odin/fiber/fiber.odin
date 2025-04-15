package fiber


import "core:c"
import "core:sync"
import "core:sync/chan"
import "core:sys/posix"
foreign import libfiber "libfiber.a"

Attr :: struct {
    oflag: c.uint,
    stack_size: c.size_t
}

Task :: struct {

}

pthread_t :: distinct u64

pid_t :: distinct i32
   ThreadCtx :: struct  {
     thrd : posix.pthread_t,
     mailer: ^Mailer,
    id: posix.pid_t,
    is_detached: u8,
};
 Mailer :: struct {
    task_queue: chan.Chan(Task),
    id: posix.pid_t
};
__attr_is_init :bool = false
__attr : Attr = {}
__attr_lock :  sync.Mutex


odin_func_t :: #type proc "c" (func:FiberFunc,fb: ^Fiber,data: rawptr)
cleanup_func_t :: #type proc "c" () 
init_thread_t :: #type proc "c" (func:FiberFunc,data: rawptr)
@(default_calling_convention="c")
foreign libfiber { 
    
 fiber_set_odin_func :: proc( odin_func_t ) ---
acl_fiber_create4 :: proc(func:FiberFunc, arg: rawptr, size: c.size_t,typ: c.int) -> ^Fiber ---

acl_fiber_create3 :: proc(func:FiberFunc, arg: rawptr, typ: c.int) -> ^Fiber ---
 fiber_set_error_string :: proc(fb:^Fiber,err: cstring) ---

fiber_create_thread :: proc( mailer: ^Mailer, init_func:  init_thread_t,   cleanup: cleanup_func_t,func: fiber_func1,  data: rawptr, attr :   ^posix.pthread_attr_t, event_mode: c.int , detach: u8, err: ^c.int) -> ThreadCtx ---

 fiber_get_func_typ :: proc( fb: ^Fiber) -> c.int ---
}