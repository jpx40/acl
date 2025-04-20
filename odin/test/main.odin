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
 
    fiber.yield()
    })
    
    fiber.schedule()
    
    fiber.join(t)
}