package fiber





Errno :: __Errno

Error :: union {
    int,
    Errno,
    CustomError
}

CustomError :: struct {
  text: string,
    code: int,
  
}

code_to_errno :: proc(nr:int) -> Errno {
    return Errno(nr)
}


last_fiber_error :: proc() -> Errno {

return Errno(acl_fiber_last_error())

}
CError :: struct {
   text: CStr,
   code: int
}

error_from_cerror:: proc(err: CError) -> CustomError {
return CustomError{text =string_from_cstr(err.text) ,code =err.code}
}

fiber_get_error :: proc(fb: ^Fiber) -> Error {
    return  error_from_cerror(acl_fiber_get_cerror(fb))
}