#+ build windows


package fiber


import "core:c"
import "core:sync"
import "core:sync/chan"
import "base:runtime"
foreign import libfiber "libfiber.a"



// odin_func_t :: #type proc "c" (func:FiberFunc,fb: ^Fiber,data: rawptr)
// cleanup_func_t :: #type proc "c" () 
// init_thread_t :: #type proc "c" (func:FiberFunc,data: rawptr)


// cleanup_thread :: proc "c" () {
//     context = runtime.default_context()
    
//     free_all(context.temp_allocator)
// }
// @(default_calling_convention="c")
// foreign libfiber { 
    
//  fiber_set_odin_func :: proc( odin_func_t ) ---
// acl_fiber_create4 :: proc(func:FiberFunc, arg: rawptr, size: c.size_t,typ: c.int) -> ^Fiber ---
// acl_fiber_create2 :: proc(attr: ^Attr,func: proc "c" (fb: ^Fiber,data: rawptr), arg: rawptr) -> ^Fiber ---
// acl_fiber_create :: proc(func: proc "c" (fb: ^Fiber,data: rawptr), arg: rawptr, size: c.size_t) -> ^Fiber ---

// acl_fiber_create3 :: proc(func:FiberFunc, arg: rawptr, typ: c.int) -> ^Fiber ---
//  fiber_set_error_string :: proc(fb:^Fiber,err: cstring) ---

// fiber_create_thread :: proc( mailer: ^Mailer, init_func:  init_thread_t,   cleanup: cleanup_func_t,func: fiber_func1,  data: rawptr, attr :   ^posix.pthread_attr_t, event_mode: c.int , detach: u8, err: ^c.int) -> ThreadCtx ---

//  fiber_get_func_typ :: proc( fb: ^Fiber) -> c.int ---
// }