#+ build darwin,linux



package fiber


import "base:runtime"
import "core:c"
import "core:sync"
import "core:sync/chan"
import "core:sys/posix"
import "./atomic"
import "core:sys/unix"
import "core:fmt"

import "core:mem"
foreign import libfiber "libfiber.a"


Attr :: struct {
	oflag:      c.uint,
	stack_size: c.size_t,
}

Task :: struct {
    func: FiberFunc,
    data: rawptr,
    typ: u8,
    size: uint,
    
}

Option :: struct {}
pthread_t :: distinct u64

// pid_t :: distinct i32
ThreadCtx :: struct {
	thrd:        posix.pthread_t,
	mailer:      ^Mailer,
	id:          posix.pid_t,
	is_detached: u8,
}
Mailer :: struct {
	task_queue: chan.Chan(Task),
	id:         int,
}

@(private) 
 @(thread_local)   __attr_is_init: atomic.Atomic(bool)
 @(private) 
 @(thread_local) __attr: Attr 
__attr_lock: sync.Mutex
odin_func_t :: #type proc "c" (func: FiberFunc, fb: ^Fiber, data: rawptr)
cleanup_func_t :: #type proc "c" ()
init_thread_t :: #type proc "c" (func: FiberFunc, data: rawptr, option: Option)


@(private) 
cleanup_thread :: proc "c" () {
	context = runtime.default_context()
	m := get_mailer()
	chan.destroy(m.task_queue)
	mem.free(m)
	 mem.free_all(context.temp_allocator)
}


@(thread_local) __spawner :^Fiber
@(private) 
spawn_fiber_from_task_queue ::proc(fb: ^Fiber,data: rawptr) {
    __spawner = fb
    mailer := get_mailer()
    task: Task
    ok : bool
    counter: int
    for {
    if fiber_canceled(fb) || fiber_killed(fb) {
    break   
    }
    for task ,ok =chan.try_recv(mailer.task_queue); ok; {
        counter = 0
        __create(task.func,task.typ,task.data,task.size)
    }
    if fiber_number() > 2 {
        
        counter = 0
    }
    if counter == 1000000 {
    break
    }
    counter +=1
    yield()
    }
    
    __spawner = nil
    
}



@(private) 
init_thread :: proc "c" (func: FiberFunc, data: rawptr, option: Option) {

fiber_set_odin_func(run_odin_func)
	context = runtime.default_context()
	m := get_mailer()
	m.id = unix.sys_gettid()
	// create1(spawn_fiber_from_task_queue)
	create1(func.func1, data)


}


@(default_calling_convention = "c")
foreign libfiber {
    @(link_name="acl_fiber_get_mailer")
    get_mailer :: proc () -> ^Mailer ---
	fiber_set_odin_func :: proc(_: odin_func_t) ---
	acl_fiber_create4 :: proc(func: FiberFunc, arg: rawptr, size: c.size_t, typ: c.char) -> ^Fiber ---
	acl_fiber_create2 :: proc(attr: ^Attr, func: proc "c" (fb: ^Fiber, data: rawptr), arg: rawptr, ctx_typ:ContextTypeNr= .NONE, ctx: rawptr= nil) -> ^Fiber ---
	acl_fiber_create :: proc(func: proc "c" (fb: ^Fiber, data: rawptr), arg: rawptr, size: c.size_t) -> ^Fiber ---

	acl_fiber_create3 :: proc(attr: ^Attr,func: FiberFunc, arg: rawptr, typ: c.char,ctx_typ:ContextTypeNr= .NONE, ctx:  rawptr= nil) -> ^Fiber ---
	fiber_set_error_string :: proc(fb: ^Fiber, err: cstring) ---
	acl_fiber_init_odin :: proc(func: proc "c" ()) ---
	fiber_create_thread :: proc(mailer: ^Mailer, option: Option, init_func: init_thread_t, cleanup: cleanup_func_t, func: fiber_func1, data: rawptr, attr: ^posix.pthread_attr_t, event_mode: c.int, detach: u8, err: ^c.int) -> ThreadCtx ---

	fiber_get_func_typ :: proc(fb: ^Fiber) -> c.int ---
	
	 acl_fiber_set_blocking :: proc(fb:^Fiber,on: b8) ---
	
	acl_fiber_has_context :: proc(fb: ^Fiber) -> b32 ---
	acl_fiber_get_context :: proc(fb: ^Fiber) -> rawptr ---
	acl_fiber_get_context_typ :: proc( fb: ^Fiber) -> ContextTypeNr ---
	
}


DefaultThreadOption: Option : {}
MAILER_SIZE :: 20
create_thread :: proc(
	func: fiber_func1,
	data: rawptr = nil,
	event_mode: c.int = FIBER_EVENT_KERNEL,
	detach: c.char = 0,
	option: Option = DefaultThreadOption,
	allocator := context.allocator) -> (
	ThreadCtx,
	^Mailer,
) {

	fn: FiberFunc
	fn.func1 = func
	mailer := new(Mailer)
	mailer.task_queue, _ = chan.create_buffered(
		chan.Chan(Task),
		cap = MAILER_SIZE,
		allocator = allocator,
	)
	err: c.int
	return fiber_create_thread(
			mailer,
			option,
			init_thread,
			cleanup_thread,
			func,
			data,
			nil,
			event_mode,
			detach,
			&err,
		),
		mailer
}


@(private) 
init_odin :: proc "c" () {


	fiber_set_odin_func(run_odin_func)

}
DefaultStackSize :: 128000


@(private) 
__create_with_size :: proc(
	func: FiberFunc,
	typ: c.char,
	data: rawptr,
	size: c.size_t = DefaultStackSize,
) -> ^Fiber {

	return acl_fiber_create4(func, data, size, typ)

}

@(private) 
__create :: proc(
	func: FiberFunc,
	typ: c.char,
	data: rawptr,
	size: c.size_t = DefaultStackSize,
	attr: ^Attr = nil
) -> ^Fiber {
    if (!atomic.load(&__attr_is_init))  {
        atomic.store(&__attr_is_init,true)
        attr_init(&__attr)
    }
    attr := attr
    if (attr == nil) {
    attr = &__attr
    }
	return acl_fiber_create4(func, data, size, typ)

}
create1 :: proc(
	func: fiber_func1,
	data: rawptr = nil,
	size: c.size_t = DefaultStackSize,
) -> ^Fiber {
	fn: FiberFunc
	fn.func1 = func
	return __create(fn, 1, data, size)

}

create :: proc {
    create1,
}

join  :: proc(ctx:ThreadCtx) {
    if ctx.is_detached != 1 {
        posix.pthread_join(ctx.thrd)
    }
}

schedule :: proc() {

fiber_set_odin_func(run_odin_func)
_schedule()
}