package fiber_sync



free :: proc {
    sem_free,
    cond_free,
    mutex_free,
    rwlock_free,
    lock_free,
    stream_free,
    promise_free,
}


lock :: proc {
   
    mutex_lock,
    lock_lock,

}

unlock :: proc {
   
    mutex_unlock,
    lock_unlock,

}
wait :: proc {
    sem_wait,
    cond_wait,
}
trywait :: proc {
    sem_trywait,
}

post :: proc {
sem_post,
cond_signal,
}

signal :: proc {
sem_post,
cond_signal,
}