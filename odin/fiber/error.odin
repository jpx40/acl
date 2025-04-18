package fiber





Errno :: __Errno

Error :: union {
    int,
    Errno
    
}


nr_to_errno :: proc(nr:int) -> Errno {
    return Errno(nr)
}


last_fiber_error :: proc() -> Errno {

return Errno(acl_fiber_last_error)

}