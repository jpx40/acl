package fiber


import "core:c/libc"
import "core:c"
import "core:sync"
import "core:sync/chan"
import "core:sys/posix"
import "base:runtime"
foreign import libfiber "libfiber.a"
fiber_func0 :: #type proc "c" (fb: ^Fiber,data: rawptr)
fiber_func1 ::#type proc(fb: ^Fiber,data: rawptr)

fiber_func2 ::#type proc(fb: ^Fiber)

fiber_func3 ::#type proc(data: rawptr)

fiber_func4 ::#type proc()
FiberFunc :: struct #raw_union {
    func0: fiber_func0,
    func1 : fiber_func1,
    func2: fiber_func2,
     func3 : fiber_func3,
     func4:fiber_func4
}


/**
 * Start the fiber schedule process with the specified event type, the default
 * event type is FIBER_EVENT_KERNEL. acl_fiber_schedule using the default
 * event type. FIBER_EVENT_KERNEL is different for different OS platform:
 * Linux: epoll; BSD: kqueue; Windows: iocp.
 * @param event_mode {int} the event type, defined as FIBER_EVENT_XXX
 */
 FIBER_EVENT_KERNEL ::	0	/* epoll/kqueue/iocp	*/
 FIBER_EVENT_POLL :: 	1	/* poll			*/
 FIBER_EVENT_SELECT ::	2	/* select		*/
FIBER_EVENT_WMSG ::	3	/* win message		*/
FIBER_EVENT_IO_URING ::	4	/* io_uring of Linux5.x */

ContextState :: enum {
    Start,
    End

}
ContextTypeNr :: enum (i8) {
    NONE =0

}
// not bigger as an pointer
ContextType :: struct #raw_union {


}
@(private)
run_odin_func :: proc "c" (func: FiberFunc,fb:^Fiber, data: rawptr) {
context = runtime.default_context()
switch fiber_get_func_typ(fb) {
    case 0: {func.func0(fb,data)}
    case 1: {func.func1(fb,data)}
    case 2: {func.func2(fb)}
    case 3: {func.func3(data)}
    case 4: {func.func4()}
    }
}