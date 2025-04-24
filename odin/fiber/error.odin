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
cerror_from_customerror :: proc( err: CustomError) -> CError {
return CError{code = err.code, text = cstr_from_string(err.text)}
}
cerror_from_error ::proc( err: Error) -> CError{
switch t in  err {
 case int: return {code = err.(int)}
 case Errno: return {code =int(err.(Errno)) }
 case CustomError: return cerror_from_customerror(err.(CustomError))

}
return {}
}

fiber_get_error :: proc(fb: ^Fiber) -> Error {
    return  error_from_cerror(acl_fiber_get_cerror(fb))
}

fiber_set_error :: proc(fb: ^Fiber, err: Error) {
acl_fiber_set_cerror(fb,cerror_from_error(err))
}