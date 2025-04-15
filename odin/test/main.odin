package main

import "../fiber"
import "core:c/libc"


main :: proc() {
    attr: fiber.Attr 
    fiber.acl_fiber_attr_init(&attr)
    fiber.acl_fiber_create2(&attr,proc "c" (fb: ^fiber.Fiber, data: rawptr) {
        u := "fffffffff"
        libc.printf("test\n")
    }, nil)
    fiber.schedule()
}