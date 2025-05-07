
#include "stdafx.hpp"
#include "fiber/fiber_tbox.hpp"
#include "fiber/wait_group.hpp"
#include <cstddef>
#include <cstdint>
#include <sys/wait.h>
extern "C"  acl::wait_group* acl_create_wait_group() {
    acl::wait_group* wg =  new acl::wait_group();
    return wg;
}


extern "C"  void acl_free_wait_group( acl::wait_group *wg) {
     delete wg;
}


extern "C"  void acl_fiber_wait_group_add( acl::wait_group *wg, int n) {
      wg->add(n);
}

extern "C"  void acl_fiber_done( acl::wait_group *wg) {
      wg->done();
}

extern "C"  void acl_fiber_wait_group_wait( acl::wait_group *wg) {
      wg->wait();
}


extern "C"  acl::fiber_tbox<uintptr_t>*  acl_fiber_create_tbox( ) {
    return new  acl::fiber_tbox<uintptr_t>();
}


extern "C" bool  acl_fiber_box_push( acl::fiber_tbox<uintptr_t> *box, uintptr_t* val, bool notify_first) {
    return  box->push(val,notify_first);
}
extern "C" uintptr_t  acl_fiber_box_pop1( acl::fiber_tbox<uintptr_t> *box,int ms = -1, bool* found = NULL) {
    return (uintptr_t) box->pop(ms,found);
}




extern "C" size_t  acl_fiber_box_pop2( acl::fiber_tbox<uintptr_t> *box, uintptr_t** out, size_t max, int ms) {
    return  box->pop(out,max,ms);
}

extern "C" size_t  acl_fiber_box_size( acl::fiber_tbox<uintptr_t> *box) {
    return  box->size();
}




extern "C" void  acl_fiber_box_free( acl::fiber_tbox<uintptr_t> *box) {
    delete box;
}





