package main

import "../fiber"
import "core:c/libc"


main :: proc() {
    attr: fiber.Attr 
    fiber.acl_fiber_attr_init(&attr)
    fiber.acl_fiber_create2(&attr,proc "cdecl" (fb: ^fiber.Fiber, data: rawptr) {
        u :cstring = "fffffffff"
        for i in 0..<10 {
       
        libc.printf("%d\n",10)
        fiber.yield()
        }

    }, &attr)
    fiber.acl_fiber_create(proc "cdecl" (fb: ^fiber.Fiber, data: rawptr) {
     
    }, &attr, 1000000)
    fiber.schedule()
}