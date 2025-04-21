package main

import "../fiber/fiber_sync"
import "../fiber"
import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:slice"
import "base:runtime"



main :: proc() {
    attr: fiber.Attr 
    fiber.attr_init(&attr)
    t ,m := fiber.create_thread( proc(fb:^fiber.Fiber, data: rawptr) {
    using fiber_sync
    
    st := fiber_sync.stream_create(string)
     fiber.create1(proc(fb:^fiber.Fiber,data: rawptr) {
     using fiber_sync
     st :=cast(^Stream(string))data
     stream_send_ptr(st,"hello")
     
     },&st) 
       data,_ :=  stream_recv(st)
       fmt.println(data)
    fiber.yield()
    })
    

    
    fiber.schedule()
    
    fiber.join(t)
}