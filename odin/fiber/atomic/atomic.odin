package atomic


import "core:c"
import "core:sync"


Atomic :: struct($T:typeid) {
    val: T 
}


new :: proc(val:$T )-> Atomic(T) {
    return Atomic(T) {val=val}
}

atomic_compare_exchange_strong :: proc(dst: ^Atomic($T), old, new: T) -> (T, bool) #optional_ok {
    return sync.atomic_compare_exchange_strong(&dst.val,old,new)

}
load :: proc(a: ^Atomic($T)) -> T {
  return  sync.atomic_load(&a.val)

}
store :: proc(a: ^Atomic($T), val: T) {
    sync.atomic_store(&a.val,val)

}