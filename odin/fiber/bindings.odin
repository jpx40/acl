package fiber


import "core:c"
foreign import libfiber "libfiber.a"


Fiber :: distinct rawptr



FiberSignal :: bit_set[FiberSignal_Bits; i32]

   FiberSignal_Bits :: enum int {
	Started          = 0, 
	SaveErrno         = 1, 
	Killed    = 2, 
	Closed      = 3, 
	Signaled       = 4, 
	Canceled        = 2 | 3| 4, 
	Timer        = 5, 

}
@(default_calling_convention = "c")
foreign libfiber {
@(link_name = "acl_fiber_has_error")
fiber_has_error:: proc(fb: ^Fiber) -> b8 ---
acl_fiber_set_cerror :: proc(fb: ^Fiber, err: CError) ---

acl_fiber_get_cerror :: proc(fb: ^Fiber) -> ( err: CError) ---

	@(link_name = "acl_fiber_attr_init")
	attr_init :: proc(attr: ^Attr) ---
	acl_fiber_attr_setstacksize :: proc(attr: ^Attr, size: c.size_t) ---

	@(link_name = "acl_fiber_attr_setsharestack")
	attr_setsharestack :: proc(attr: ^Attr, on: c.int) ---

	@(link_name = "acl_fiber_set_non_blocking")
	set_non_blocking :: proc(on: c.int) ---

	@(link_name = "acl_fiber_set_shared_stack_size")
	set_shared_stack_size :: proc(size: c.size_t) ---

	@(link_name = "acl_fiber_get_shared_stack_size")
	get_shared_stack_size :: proc() -> c.size_t ---
	/**
 * Get the fibers count in deading status
 * @return {unsigned}
 */
 
	acl_fiber_ndead :: proc() -> c.uint ---

	/**
 * Get the fibers count in living status
 * @return {unsigned}
 */
 
 @(link_name = "acl_fiber_number")
	fiber_number :: proc() -> c.uint ---

	/**
 * Create one fiber in background for freeing the dead fibers, specify the
 * maximum fibers in every recycling process
 * @param max {size_t} the maximum fibers to freed in every recycling process
 */
	acl_fiber_check_timer :: proc(max: c.size_t) ---

	/**
 * Get the current running fiber
 * @retur {ACL_FIBER*} if no running fiber NULL will be returned
 */
	@(link_name = "acl_fiber_running")
	running :: proc() -> ^Fiber ---

	/**
 * If the fiber using shared stack?
 * @param fiber {const ACL_FIBER*}
 * @return {int} return 0 if using private stack, or the shared stack was used
 */
	acl_fiber_use_share_stack :: proc(fiber: ^Fiber) -> c.int ---

	/**
 * Get the fiber ID of the specified fiber
 * @param fiber {const ACL_FIBER*} the specified fiber object
 * @return {unsigned int} return the fiber ID
 */
	acl_fiber_id :: proc(fiber: ^Fiber) -> c.uint ---

	/**
 * Get the current running fiber's ID
 * @return {unsigned int} the current fiber's ID
 */
	@(link_name = "acl_fiber_self")
	fiber_self :: proc() -> c.int ---
	/**
 * Set the error number to the specified fiber object
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 *  fiber will be used
 * @param errnum {int} the error number
 */
	acl_fiber_set_errno :: proc(fiber: ^Fiber, errnum: c.int) ---

	/**
 * Get the error number of associated fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} get the error number of associated fiber
 */
	acl_fiber_errno :: proc(fiber: ^Fiber) -> c.int ---

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
 
 @(link_name = "acl_fiber_kill")
 fiber_kill :: proc(fiber: ^Fiber) ---

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
 
    @(link_name = "acl_fiber_killed")
	fiber_killed :: proc(fiber: ^Fiber) -> b32 ---

	/**
 * Check if the specified fiber has been signaled
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been signed
 */
 
 @(link_name = "acl_fiber_signaled")
fiber_signaled :: proc(fiber: ^Fiber) -> b32 ---

	/**
 * Check if the specified fiber's socket has been closed by another fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been closed
 */
 
 @(link_name = "acl_fiber_closed")
	fiber_closed :: proc(fiber: ^Fiber) -> b32 ---

	/**
 * Check if the specified fiber has been canceled
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @return {int} non zero returned if been canceled
 */
 
 @(link_name = "acl_fiber_canceled")
fiber_canceled :: proc(fiber: ^Fiber) -> b32 ---

	/**
 * Clear the fiber's flag and errnum to 0.
 * @param fiber {ACL_FIBER*}
 */
 
 @(link_name = "acl_fiber_clear")
fiber_clear :: proc(fiber: ^Fiber) ---

	/**
 * Wakeup the suspended fiber with the associated signal number asynchronously
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 * @param signum {int} SIGINT, SIGKILL, SIGTERM ... refer to bits/signum.h
 */
 
 @(link_name = "acl_fiber_signal")
	fiber_signal :: proc(fiber: ^Fiber, signum: FiberSignal) ---

	/**
 * Wakeup the suspended fiber with the associated signal number synchronously
 * @param fiber {const ACL_FIBER*} the specified fiber, NOT NULL
 * @param signum {int} SIGINT, SIGKILL, SIGTERM ... refer to bits/signum.h
 */
 
 @(link_name = "acl_fiber_signal_wait")
	signal_wait :: proc(fiber: ^Fiber, signum: c.int) ---

	/**
 * Get the signal number got from other fiber
 * @param fiber {ACL_FIBER*} the specified fiber, if NULL the current running
 * @retur {int} the signal number got
 */
 
 @(link_name = "acl_fiber_signum")
	signum :: proc(fiber: ^Fiber) -> FiberSignal ---

	/**
 * Suspend the current running fiber
 * @return {int}
 */
	@(link_name = "acl_fiber_yield")
	yield :: proc() -> c.int ---
	/**
 * Add the suspended fiber into resuming queue
 * @param fiber {ACL_FIBER*} the fiber, NOT NULL
 */
 
 @(link_name = "acl_fiber_ready")
	fiber_ready :: proc(fiber: ^Fiber) ---

	/**
 * Suspend the current fiber and switch to run the next ready fiber
 */
 
 @(link_name = "acl_fiber_switch")
	fiber_switch :: proc() ---
	/**
 * Set the fiber schedule process with automatically, in this way, when one
 * fiber was created, the schedule process will start automatically, but only
 * the first fiber was started, so you can create the other fibers in this
 * fiber. The default schedule mode is non-automatically, you should call the
 * acl_fiber_schedule or acl_fiber_schedule_with explicit
 */

	@(link_name = "acl_fiber_schedule_init")
	schedule_init :: proc(on: c.int) ---

	/**
 * Start the fiber schedule process, the fibers in the ready quque will be
 * started in sequence.
 */

	@(link_name = "acl_fiber_schedule")
	_schedule :: proc() ---


	acl_fiber_schedule_with :: proc(event_mode: c.int) ---

	/**
 * Set the event type, the default type is FIBER_EVENT_KERNEL, this function
 * must be called before acl_fiber_schedule.
 * @param event_mode {int} the event type, defined as FIBER_EVENT_XXX
 */
	acl_fiber_schedule_set_event :: proc(event_mode: c.int) ---

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
 
 @(link_name = "acl_fiber_delay")
	fiber_delay :: proc(milliseconds: c.size_t) -> c.size_t ---

	/**
 * Let the current fiber sleep for a while
 * @param seconds {size_t} the seconds to sleep
 * @return {size_t} the rest seconds returned after wakeup
 */
 
 @(link_name = "acl_fiber_sleep")
	fiber_sleep :: proc(seconds: c.size_t) -> c.size_t ---
	/**
 * Set the DNS service addr
 * @param ip {const char*} ip of the DNS service
 * @param port {int} port of the DNS service
 */
 
 @(link_name = "acl_fiber_set_dns")
fiber_set_dns :: proc(ip: cstring, port: c.int) ---

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
