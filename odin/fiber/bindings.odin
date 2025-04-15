package fiber


import "core:c"
foreign import libfiber "libfiber.a"

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


Fiber :: distinct rawptr


fiber_func0 :: #type proc "c" (fb: ^Fiber,data: rawptr)
fiber_func1 ::#type proc(fb: ^Fiber,data: rawptr)

FiberFunc :: struct #raw_union {
    func0: fiber_func0,
    func1 : fiber_func1
    
}
@(default_calling_convention="c")
foreign libfiber {


	
			
		acl_fiber_attr_init :: proc(attr: ^Attr) ---
		acl_fiber_attr_setstacksize :: proc(attr: ^Attr,  size: c.size_t) --- 
		acl_fiber_attr_setsharestack :: proc(attr: ^Attr,  on: c.int) ---
		acl_fiber_set_non_blocking :: proc( on: c.int) ---
		acl_fiber_set_shared_stack_size :: proc( size:c.size_t) ---
		acl_fiber_get_shared_stack_size :: proc() -> c.size_t ---
		/**
 * Get the fibers count in deading status
 * @return {unsigned}
 */
 acl_fiber_ndead :: proc() -> c.uint ---

/**
 * Get the fibers count in living status
 * @return {unsigned}
 */
acl_fiber_number ::proc() -> c.uint ---

/**
 * Create one fiber in background for freeing the dead fibers, specify the
 * maximum fibers in every recycling process
 * @param max {size_t} the maximum fibers to freed in every recycling process
 */
 acl_fiber_check_timer :: proc( max : c.size_t) ---

/**
 * Get the current running fiber
 * @retur {ACL_FIBER*} if no running fiber NULL will be returned
 */
 @(link_name="acl_fiber_running")
	running :: proc() -> ^Fiber ---

/**
 * If the fiber using shared stack?
 * @param fiber {const ACL_FIBER*}
 * @return {int} return 0 if using private stack, or the shared stack was used
 */
 acl_fiber_use_share_stack :: proc( fiber: ^Fiber) -> c.int ---

/**
 * Get the fiber ID of the specified fiber
 * @param fiber {const ACL_FIBER*} the specified fiber object
 * @return {unsigned int} return the fiber ID
 */
 acl_fiber_id ::proc (fiber: ^Fiber) -> c.uint ---

/**
 * Get the current running fiber's ID
 * @return {unsigned int} the current fiber's ID
 */
 @(link_name="acl_fiber_self")
fiber_self :: proc() -> c.int ---
/**
 * Set the error number to the specified fiber object
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 *  fiber will be used
 * @param errnum {int} the error number
 */
acl_fiber_set_errno :: proc( fiber : ^Fiber,  errnum: c.int) ---

/**
 * Get the error number of associated fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} get the error number of associated fiber
 */
 acl_fiber_errno :: proc(fiber: ^Fiber)-> c.int ---

/**
 * @deprecated
 * @param fiber {ACL_FIBER*}
 * @param yesno {int}
 */
acl_fiber_keep_errno :: proc(fiber: ^Fiber, yesno: c.int) ---

/**
 * Get the associated fiber's status
 * @param fiber {ACL_FIBER*} The specified fiber, if fiber is NULL the current
 *  running fiber will be used.
 * @return {int} Return ths status defined as FIBER_STATUS_XXX.
 */
acl_fiber_status :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Get the specified fiber's waiting status, defined as FIBER_WAIT_XXX.
 * @param fiber {ACL_FIBER*} The specified fiber or the running fiber if the
 *  fiber is NULL.
 */
acl_fiber_waiting_status :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Kill the suspended fiber and notify it to exit in asynchronous mode
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 */
acl_fiber_kill :: proc(fiber: ^Fiber) ---

/**
 * Kill the suspended fiber and notify it to exit in synchronous mode
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 */
acl_fiber_kill_wait :: proc(fiber: ^Fiber) ---

/**
 * Check if the specified fiber has been killed
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been killed
 */
 acl_fiber_killed :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Check if the specified fiber has been signaled
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been signed
 */
acl_fiber_signaled :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Check if the specified fiber's socket has been closed by another fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been closed
 */
 acl_fiber_closed ::proc(fiber: ^Fiber) -> c.int ---

/**
 * Check if the specified fiber has been canceled
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been canceled
 */
acl_fiber_canceled :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Clear the fiber's flag and errnum to 0.
 * @param fiber {ACL_FIBER*}
 */
 acl_fiber_clear :: proc(fiber: ^Fiber) ---

/**
 * Wakeup the suspended fiber with the associated signal number asynchronously
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 * @param signum {int} SIGINT, SIGKILL, SIGTERM ... refer to bits/signum.h
 */
 acl_fiber_signal :: proc(fiber: ^Fiber, signum: c.int) ---

/**
 * Wakeup the suspended fiber with the associated signal number synchronously
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 * @param signum {int} SIGINT, SIGKILL, SIGTERM ... refer to bits/signum.h
 */
 acl_fiber_signal_wait :: proc(fiber: ^Fiber,signum :c.int) ---

/**
 * Get the signal number got from other fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @retur {int} the signal number got
 */
 acl_fiber_signum :: proc(fiber: ^Fiber) -> c.int ---

/**
 * Suspend the current running fiber
 * @return {int}
 */
 @(link_name="acl_fiber_yield")
		yield :: proc() -> c.int ---
/**
 * Add the suspended fiber into resuming queue
 * @param fiber {ACL_FIBER*} the fiber, NOT NULL
 */
acl_fiber_ready :: proc(fiber: ^Fiber) ---

/**
 * Suspend the current fiber and switch to run the next ready fiber
 */
acl_fiber_switch :: proc() ---
/**
 * Set the fiber schedule process with automatically, in this way, when one
 * fiber was created, the schedule process will start automatically, but only
 * the first fiber was started, so you can create the other fibers in this
 * fiber. The default schedule mode is non-automatically, you should call the
 * acl_fiber_schedule or acl_fiber_schedule_with explicit
 */
 
 @(link_name="acl_fiber_schedule_init")
schedule_init :: proc(on: c.int) ---

/**
 * Start the fiber schedule process, the fibers in the ready quque will be
 * started in sequence.
 */
 
 @(link_name="acl_fiber_schedule")
schedule :: proc() ---


acl_fiber_schedule_with :: proc(event_mode: c.int) ---

/**
 * Set the event type, the default type is FIBER_EVENT_KERNEL, this function
 * must be called before acl_fiber_schedule.
 * @param event_mode {int} the event type, defined as FIBER_EVENT_XXX
 */
acl_fiber_schedule_set_event :: proc(event_mode: c.int ) ---

/**
 * Check if the current thread is in fiber schedule status
 * @return {int} non zero returned if in fiber schedule status
 */
acl_fiber_scheduled :: proc() -> c.int ---

/**
 * Stop the fiber schedule process, all fibers will be stopped
 */
acl_fiber_schedule_stop :: proc() ---
/**
 * Let the current fiber sleep for a while
 * @param milliseconds {size_t} the milliseconds to sleep
 * @return {unsigned int} the rest milliseconds returned after wakeup
 */
  acl_fiber_delay :: proc( milliseconds: c.size_t)-> c.size_t ---

/**
 * Let the current fiber sleep for a while
 * @param seconds {size_t} the seconds to sleep
 * @return {size_t} the rest seconds returned after wakeup
 */
acl_fiber_sleep :: proc(seconds: c.size_t)-> c.size_t ---
/**
 * Set the DNS service addr
 * @param ip {const char*} ip of the DNS service
 * @param port {int} port of the DNS service
 */
 acl_fiber_set_dns :: proc(ip: cstring,port: c.int) ---

/**
 * Get the system error number of last system API calling
 * @return {int} error number
 */
 acl_fiber_last_error :: proc() -> c.int ---

/**
 * Get the error information of last system API calling
 * @return {const char*}
 */
acl_fiber_last_serror :: proc() -> cstring ---

/**
 * Convert errno to string
 * @param errnum {int}
 * @param buf {char*} hold the result
 * @param size {size_t} buf's size
 * @retur {const char*} the addr of buf
 */
acl_fiber_strerror :: proc(errnum: c.int, buf: [^]u8, size: c.size_t) -> cstring ---

/**
 * Set the system error number
 * @param errnum {int} the error number
 */
acl_fiber_set_error :: proc(errnum: c.int) ---

/**
 * Set the fd limit for the current process
 * @param limit {int} the fd limit to be set
 * @return {int} the real fd limit will be returned
 */
acl_fiber_set_fdlimit :: proc(limit: c.int) -> c.int ---
}
