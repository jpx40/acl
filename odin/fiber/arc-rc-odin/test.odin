package main

import "base:runtime"
import arc "./rc"
import "core:fmt"
main :: proc() {

  arc1, err :=  arc.init_with_data_and_cleanup("test", 
  proc(data: rawptr) -> runtime.Allocator_Error {
  
  s := cast(^string)data
  fmt.println(s^)
  return nil
  }
  )
  
  arc2  := arc.clone(&arc1)
  arc.delete(&arc1)
    arc.delete(&arc1)
  data,_ := arc.get_ptr(&arc2)
  


  arc.delete(&arc2)
  // fmt.println(arc2.inner.count)
}