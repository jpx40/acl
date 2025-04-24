package fiber


import "core:strings"

CStr :: struct {
   buf: [^]u8,
   len: int
}



string_from_cstr :: proc(str: CStr) -> string {
   return strings.string_from_ptr(str.buf,str.len)
}
cstr_from_string :: proc(str: string) -> CStr {
   return CStr{buf= raw_data(transmute([]u8)str), len = len(str)}
}



