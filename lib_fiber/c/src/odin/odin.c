#include "fiber.h"
#include <bits/pthreadtypes.h>
#include <pthread.h>
#include <sys/types.h>

#include "event.h"
#include "memory.h"
static  void(*odin_func )(void(*)(ACL_FIBER* fb,void* data),ACL_FIBER* fb,void* data) =NULL;

void fiber_set_odin_func( void(*func )(void(*)(ACL_FIBER* fb,void* data),ACL_FIBER* fb,void* data) ) {
    if (odin_func != NULL) {

        odin_func = func;
    }


}


typedef struct ThreadCtx {
    pthread_t thrd;
    Mailer* mailer;
    pid_t id;
}ThreadCtx;


typedef struct Payload {
 void(*init)(  void(*)(ACL_FIBER*, void*) ,void*);
 void(*func)(ACL_FIBER*,void*);
 void* data;
 int event_mode;
}   Payload;

void *fiber_thread_init_func(void* data) {
    Payload* p = (Payload*)data;
    if (p->init !=NULL) {
      if (p->data !=NULL) {
          
          p->init(p->func,p->data);
      }  else {
          p->init(p->func,NULL);
      }
    } 
    
   if (p->event_mode!= 0) {
       
       acl_fiber_schedule_set_event(p->event_mode);
   } 
acl_fiber_schedule();    
    mem_free(p);
}

int fiber_io_uring_event_nr() {
    return EVENT_F_IO_URING;
}
int fiber_epoll_event_nr() {
    return EVENT_F_EPOLL;
}
int fiber_kqueue_event_nr() {
    return EVENT_F_KQUEUE;
}

int fiber_poll_event_nr() {
    return EVENT_F_POLL;
}
int fiber_win_event_nr() {
    return EVENT_F_IOCP;
}


 void fiber_run_odin_func(void(*func)(ACL_FIBER* fb,void* data),ACL_FIBER* fb,void* data) {
         
        if (odin_func != NULL) {
            odin_func(func,fb,data);
        } else {
            func(fb,data);
        }
     }
ThreadCtx fiber_create_thread(Mailer* mailer,     void(*init)(  void(*)(ACL_FIBER*, void*) ,void*),    void(*func)(ACL_FIBER*,void*),  void* data,    pthread_attr_t* attr,int event_mode ,char detach,int* err) {


    ThreadCtx ctx ;
    ctx.mailer = mailer;
    Payload pl = {};
    pl.event_mode = event_mode;
    pl.init = init;
    pl.data = data;
    Payload* p=   (Payload*)mem_malloc(sizeof(Payload));
    *p = pl;
if( attr == NULL) {
    *err = pthread_create(&ctx.thrd, NULL, fiber_thread_init_func, p);
} else {
    
    *err = pthread_create(&ctx.thrd, attr, fiber_thread_init_func, p);
    
}

  return ctx;

}
int fiber_get_func_typ(ACL_FIBER* fb) {
    return fb->typ;
}
