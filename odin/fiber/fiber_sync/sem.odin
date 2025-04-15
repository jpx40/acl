package fiber_sync








import "core:c"

import "core:sys/posix"
foreign import libfiber "../libfiber.a"


Sem :: distinct rawptr

@(default_calling_convention="c")
foreign libfiber { 


/* Fiber semaphore, thread unsafely, one semaphore can only be used in one
 * thread, if used in different threads, result is unpredictable */


/**
 * Create one fiber semaphore, and binding it with the current thread
 * @param num {int} the initial value of the semaphore, must >= 0
 * @param flags {unsigned} the flags defined as ACL_FIBER_SEM_F_XXX
 * @return {ACL_FIBER_SEM *}
 */
acl_fiber_sem_create2 :: proc(num: c.int, flags: c.uint)-> ^Sem ---

/**
 * Create one fiber semaphore with the specified buff count and flags.
 * @param num {int} the initial value of the semaphore, must >= 0
 * @param buf {int} the buffed count before signal the waiters.
 * @param flags {unsigned} the flags defined as ACL_FIBER_SEM_F_XXX
 */
acl_fiber_sem_create3 :: proc( num: c.int,buf: c.int,  flags: c.int) -> ^Sem ---

acl_fiber_sem_create :: proc(num: c.int) ---

/**
 * Free fiber semaphore
 * @param {ACL_FIBER_SEM *}
 */
acl_fiber_sem_free :: proc( sem: ^Sem) ---

/**
 * Get the thread binding the specified fiber sem
 * @param sem {ACL_FIBER_SEM*} created by acl_fiber_sem_create
 * @return {unsigned long} thread ID of the thread binding the semaphore
 */
 acl_fiber_sem_get_tid :: proc(sem: ^Sem) -> c.ulong ---

/**
 * Set the thread ID the semaphore belongs to, changing the owner of the fiber
 * semaphore, when this function was called, the value of the semaphore must
 * be zero, otherwise fatal will happen.
 * @param sem {ACL_FIBER_SEM*} created by acl_fiber_sem_create
 * @param {unsigned long} the thread ID to be specified with the semaphore
 */
 acl_fiber_sem_set_tid :: proc(sem: ^Sem,tid: c.ulong) ---

/**
 * Wait for semaphore until > 0, semaphore will be -1 when returned
 * @param sem {ACL_FIBER_SEM *} created by acl_fiber_sem_create
 * @return {int} the semaphore value returned, if the caller's thread isn't
 *  same as the semaphore owner's thread, -1 will be returned
 */
acl_fiber_sem_wait :: proc(sem:^Sem) -> c.int ---

/**
 * Try to wait semaphore until > 0, if semaphore is 0, -1 returned immediately,
 * otherwise semaphore will be decreased 1 and the semaphore's value is returned
 * @param sem {ACL_FIBER_SEM *} created by acl_fiber_sem_create
 * @return {int} value(>=0) returned when waiting ok, otherwise -1 will be
 *  returned if the caller's thread isn't same as the semaphore thread or the
 *  semaphore's value is 0
 */
acl_fiber_sem_trywait :: proc(sem: ^Sem) -> c.int ---

/**
 * Wait for semaphore until > 0 or the timer arriving.
 * @param sem {ACL_FIBER_SEM *} created by acl_fiber_sem_create
 * @param milliseconds {int} specify the timeout to wait
 * @return {int} return >= 0 if waiting successfully, or -1 if waiting timed out.
 */
acl_fiber_sem_timed_wait :: proc(sem: ^Sem, milliseconds: c.int)  -> c.int ---

/**
 * Add 1 to the semaphore, if there are other fibers waiting for semaphore,
 * one waiter will be wakeup
 * @param sem {ACL_FIBER_SEM *} created by acl_fiber_sem_create
 * @return {int} the current semaphore value returned, -1 returned if the
 *  current thread ID is not same as the semaphore's owner ID
 */
 acl_fiber_sem_post  :: proc(sem: ^Sem) -> c.int ---

/**
 * Get the specificed semaphore's value
 * @param sem {ACL_FIBER_SEM*} created by acl_fiber_sem_create
 * @return {int} current semaphore's value returned
 */
acl_fiber_sem_num  :: proc(sem: ^Sem) -> c.int ---

/**
 * Get the number of the waiters for the semaphore.
 * @param sem {ACL_FIBER_SEM*} created by acl_fiber_sem_create
 * @return {int} the waiters' number.
 */
acl_fiber_sem_waiters_num  :: proc(sem: ^Sem) -> c.int ---
}