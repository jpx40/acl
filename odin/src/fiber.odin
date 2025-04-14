package fiber


import "core:c"
import "core:sync"


Attr :: struct {
    oflag: c.uint,
    stack_size: c.size_t
}


__attr_is_init :bool = false
__attr : Attr = {}
__attr_lock :  sync.Mutex

