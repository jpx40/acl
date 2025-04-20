package fiber_sync

import "../atomic"

import "core:sync"
import "core:fmt"
import "../../fiber"
import "core:mem"
 WaitGroup :: struct {
 waiter: u32,
 counter: u32,
 started: u8,
	state: atomic.Atomic(u64),
	sema:  ^Sem,
}



 WaitGroupShared :: struct {
waiter: u32,
counter: u32,
started: u8,
 state: atomic.Atomic(u64),
	sema:  ^Cond,
	mu: ^Mutex
}
add_single :: proc(wg: ^WaitGroup, delta: int) {
if (wg == nil) {
return
}
    if delta < 0 {
			// Synchronize decrements with Wait.

		 post(wg.sema)

		}
    // state:= atomic.load(&wg.state)
    // atomic.store(&wg.state,u64(delta << 32))
    sync.atomic_store(&wg.counter, u32(int(sync.atomic_load(&wg.counter)) + delta))
    c := sync.atomic_load(&wg.counter)
    w := sync.atomic_load(&wg.waiter)
    
      if  delta > 0 && int(c) == delta && sync.atomic_load(&wg.started) == 0 {
    
		
		   sem_post(wg.sema)
	}
	
	if w != 0 && delta > 0 && int(c) == int(w) {
			panic("sync: WaitGroup misuse: Add called concurrently with Wait")
		}
		
	if c > 0 || w == 0 {
		return
	}
	// fmt.println(3)
	 sync.atomic_store(&wg.waiter,0)	
	// 	fmt.println(1)
}
add :: proc {add_single}


done :: proc(wg: ^WaitGroup)  { 
    add(wg, -1)
}
wait_single :: proc(wg: ^WaitGroup) {
if wg == nil {
return
}
    	for { 
     // state := atomic.load(&wg.state)
     // c := (int(state>> 32))
     // w := u32(state)
     c := sync.atomic_load(&wg.counter)
        w := sync.atomic_load(&wg.waiter)
        if c == 0 && sync.atomic_load(&wg.started) == 0 { 
               
                sem_wait(wg.sema)
                sync.atomic_store(&wg.started, 1)
               }
              
        if    sync.atomic_load(&wg.started) == 1 {
        

        } 
               
               if waiter , ok :=sync.atomic_compare_exchange_strong(&wg.waiter,w, w +1); waiter == w {
               
				// Wait must be synchronized with the first Add.
				// Need to model this is as a write to race with the read in Add.
				// As a consequence, can do the write only for the first waiter,
				// otherwise concurrent Waits will race with each other.
				sem_wait(wg.sema)

			if c == 0 {
	
						return
				}
               }
         fiber.yield()
     }
 free_wait_group(wg)
}
free_wait_group :: proc(wg: ^WaitGroup) {
sem_free(wg.sema)
mem.free(wg)
}
create_wait_group :: proc() -> ^WaitGroup{

 wg := new(WaitGroup)
 wg.sema = sem_create(1)
 return wg
}
wait_shared :: proc(wg: ^WaitGroupShared) {}