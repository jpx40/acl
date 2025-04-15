package atomic


import "core:c"
import "core:sync"


Atomic :: struct($T:typeid) {
    val: T 
}


new :: (val:$T )-> Atomic(T) {
    return Atomic(T) {val=val}
}
load :: proc(a: ^Atomic($T)) -> T {
    sync.atomic_load(&a.val)

}
store :: proc(a: ^Atomic($T), val: T) {
    sync.atomic_store(&a.val,val)

}