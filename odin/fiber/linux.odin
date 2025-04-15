#+build linux
package fiber


import "core:c"
foreign import libfiber "libfiber.a"
@(default_calling_convention="c")
foreign libfiber { 

 acl_fiber_share_epoll :: proc(yes: c.int) ---
}