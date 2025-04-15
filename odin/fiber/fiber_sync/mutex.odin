package fiber_sync






Mutex :: distinct rawptr
RWLock :: distinct rawptr
Lock :: distinct rawptr
import "core:c"

import "core:sys/posix"
foreign import libfiber "../libfiber.a"


@(default_calling_convention="c")
foreign libfiber {

acl_fiber_mutex_create :: proc( flag: c.uint) -> ^Mutex ---
acl_fiber_mutex_free :: proc(mutex: ^Mutex) ---
 acl_fiber_mutex_lock :: proc(mutex: ^Mutex) -> c.int ---
acl_fiber_mutex_trylock :: proc(mutex: ^Mutex)-> c.int ---
 acl_fiber_mutex_unlock :: proc(mutex: ^Mutex) -> c.int ---



/* Fiber locking */

/**
 * Fiber mutex, thread unsafely, one fiber mutex can only be used in the
 * same thread, otherwise the result is unpredictable
 */


/**
 * Fiber read/write mutex, thread unsafely, can only be used in the same thread
 */


/**
 * Create one fiber mutex, can only be used in the same thread
 * @return {ACL_FIBER_LOCK*} fiber mutex returned
 */
 acl_fiber_lock_create :: proc() -> ^Lock ---

/**
 * Free fiber mutex created by acl_fiber_lock_create
 * @param l {ACL_FIBER_LOCK*} created by acl_fiber_lock_create
 */
acl_fiber_lock_free :: proc(l: ^Lock) ---

/**
 * Lock the specified fiber mutex, return immediately when locked, or will
 * wait until the mutex can be used
 * @param l {ACL_FIBER_LOCK*} created by acl_fiber_lock_create
 * @return {int} successful when return 0, or error return -1
 */
 acl_fiber_lock_lock :: proc(l: ^Lock) -> c.int ---

/**
 * Try lock the specified fiber mutex, return immediately no matter the mutex
 * can be locked.
 * @param l {ACL_FIBER_LOCK*} created by acl_fiber_lock_create
 * @return {int} 0 returned when locking successfully, -1 when locking failed
 */
 acl_fiber_lock_trylock  :: proc(l: ^Lock) -> c.int ---

/**
 * The fiber mutex be unlock by its owner fiber, fatal will happen when others
 * release the fiber mutex
 * @param l {ACL_FIBER_LOCK*} created by acl_fiber_lock_create
 */
 acl_fiber_lock_unlock  :: proc(l: ^Lock)  ---

/****************************************************************************/

/**
 * Create one fiber rwlock, can only be operated in the same thread
 * @return {ACL_FIBER_RWLOCK*}
 */
acl_fiber_rwlock_create :: proc() -> ^RWLock ---

/**
 * Free rw mutex created by acl_fiber_rwlock_create
 * @param l {ACL_FIBER_RWLOCK*} created by acl_fiber_rwlock_create
 */
acl_fiber_rwlock_free :: proc(l: ^RWLock) ---

/**
 * Lock the rwlock, if there is no any write locking on it, the
 * function will return immediately; otherwise, the caller will wait for all
 * write locking be released. Read lock on it will successful when returning
 * @param l {ACL_FIBER_RWLOCK*} created by acl_fiber_rwlock_create
 * @return {int} successful when return 0, or error if return -1
 */
 acl_fiber_rwlock_rlock :: proc(l: ^RWLock) -> c.int ---

/**
 * Try to locking the Readonly lock, return immediately no matter locking
 * is successful.
 * @param l {ACL_FIBER_RWLOCK*} crated by acl_fiber_rwlock_create
 * @retur {int} 0 returned when successfully locked, or -1 returned if locking
 *  operation is failed.
 */
 acl_fiber_rwlock_tryrlock  :: proc(l: ^RWLock) -> c.int ---

/**
 * Lock the rwlock in Write Lock mode, return until no any one locking it
 * @param l {ACL_FIBER_RWLOCK*} created by acl_fiber_rwlock_create
 * @return {int} return 0 if successful, -1 if error.
 */
acl_fiber_rwlock_wlock  :: proc(l: ^RWLock) -> c.int ---

/**
 * Try to lock the rwlock in Write Lock mode. return immediately no matter
 * locking is successful.
 * @param l {ACL_FIBER_RWLOCK*} created by acl_fiber_rwlock_create
 * @return {int} 0 returned when locking successfully, or -1 returned when
 *  locking failed
 */
 acl_fiber_rwlock_trywlock  :: proc(l: ^RWLock) -> c.int ---
/**
 * The rwlock's Read-Lock owner unlock the rwlock
 * @param l {ACL_FIBER_RWLOCK*} crated by acl_fiber_rwlock_create
 */
 acl_fiber_rwlock_runlock  :: proc(l: ^RWLock)  ---

/**
 * The rwlock's Write-Lock owner unlock the rwlock
 * @param l {ACL_FIBER_RWLOCK*} created by acl_fiber_rwlock_create
 */
 acl_fiber_rwlock_wunlock  :: proc(l: ^RWLock)  ---
}