package fiber_sync








import "core:c"

import "core:sys/posix"
foreign import libfiber "../libfiber.a"


/**
 * Fiber_cond object look like pthread_cond_t which is used between threads
 * and fibers
 */
Cond :: distinct rawptr
@(default_calling_convention="c")
foreign libfiber {




/**
 * Create fiber cond which can be used in fibers more or threads mode
 * @param flag {unsigned} current not used, just for the future extend
 * @return {ACL_FIBER_COND *}
 */
 @(link_name="acl_fiber_cond_create")
cond_create :: proc( flag: c.uint) -> ^Cond---

/**
 * Free cond created by acl_fiber_cond_create
 * @param cond {ACL_FIBER_COND *}
 */
  @(link_name="acl_fiber_cond_free")
 cond_free :: proc(cond: ^Cond ) ---

/**
 * Wait for cond event to be signaled
 * @param cond {ACL_FIBER_COND *}
 * @param mutex {ACL_FIBER_MUTEX *} must be owned by the current caller
 * @return {int} return 0 if ok or return error value
 */
  @(link_name="acl_fiber_cond_wait")
cond_wait :: proc(cond: ^Cond, mutex: ^Mutex)-> c.int ---

/**
 * Wait for cond event to be signaled with the specified timeout
 * @param cond {ACL_FIBER_COND *}
 * @param mutex {ACL_FIBER_MUTEX *} must be owned by the current caller
 * @param delay_ms {int}
 * @return {int} return 0 if ok or return error value, when timeout ETIMEDOUT
 *  will be returned
 */
  @(link_name="acl_fiber_cond_timedwait")
 cond_timedwait :: proc(cond: ^Cond, mutex: ^Mutex,delay_ms: c.int) -> c.int ---

/**
 * Signal the cond which will wakeup one waiter for the cond to be signaled
 * @param cond {ACL_FIBER_COND *}
 * @return {int} return 0 if ok or return error value
 */
  @(link_name="acl_fiber_cond_signal")
cond_signal :: proc(cond: ^Cond) -> c.int ---
}