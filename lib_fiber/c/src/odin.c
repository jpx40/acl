#include "fiber.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#include "event.h"
#include "memory.h"


   __thread   void(*cleanup_thread )() =NULL;

   void(*odin_func )(void(*)(ACL_FIBER* fb,void* data),ACL_FIBER* fb,void* data) =NULL;

   void(*odin_func2 )(void(*)()) =NULL;

typedef struct Option_t {}  Option_t;


  char fiber_get_func_typ(ACL_FIBER* fb) {
    return fb->typ;
}


void acl_fiber_set_context(ACL_FIBER* fb,void* ctx,signed char type) {
    fb->ctx =ctx;
    fb->ctx_typ=type;    
}
int acl_fiber_has_context(ACL_FIBER* fb) {
    return fb->ctx != NULL;    
}
void* acl_fiber_get_context(ACL_FIBER* fb) {
    return fb->ctx;
}
signed char acl_fiber_get_context_typ(ACL_FIBER* fb) {
    return fb->ctx_typ;
}
void acl_fiber_set_blocking(ACL_FIBER* fb,char on) {
    fb->non_blocking = on;
    
}
 ACL_FIBER *acl_fiber_create3(const ACL_FIBER_ATTR *attr,
	void (*fn)(ACL_FIBER *, void *), void *arg, char typ, signed char ctx_typ, void* ctx) {
ACL_FIBER* fb =	acl_fiber_create2(attr,fn,arg);
	fb->typ = typ;
		if (ctx != NULL){
 fb->ctx = ctx;
}
fb->ctx_typ = ctx_typ;
	return fb;
	}
	
  pthread_once_t __once_control = PTHREAD_ONCE_INIT;
	
  void acl_fiber_init_odin(void(*init_func)(void)) {
    if (pthread_once(&__once_control,init_func) != 0) {
        
        abort();
    }
    
    
}
  void fiber_set_odin_func( void(*func )(void(*)(ACL_FIBER* fb,void* data),ACL_FIBER* fb,void* data) ) {
    
    
    if (odin_func == NULL) {

        odin_func = func;
    }


}
  ACL_FIBER *acl_fiber_create4(void (*fn)(ACL_FIBER *, void *),
	void *arg, size_t size,char typ, signed char ctx_typ, void* ctx) {
	
	  ACL_FIBER *fb=  acl_fiber_create(fn,arg,size);
		fb->typ = typ;
		if (ctx != NULL){
		    fb->ctx = ctx;
		}
		fb->ctx_typ = ctx_typ;
	return fb;
	}
  void fiber_set_error_string(ACL_FIBER* fb,char * err) {
    fb->errstring = err;
    
}
  char *fiber_get_error_string(ACL_FIBER* fb) {
    return fb->errstring;    
}

typedef struct ThreadCtx {
    pthread_t thrd;
    Mailer* mailer;
    pid_t id;
    char is_detached;
}ThreadCtx;
 
// DWORD WINAPI ThreadFunc(void* data) {
//   // Do stuff.  This will be the first function called on the new thread.
//   // When this function returns, the thread goes away.  See MSDN for more details.
//   return 0;
// }

// int main() {
//   HANDLE thread = CreateThread(NULL, 0, ThreadFunc, NULL, 0, NULL);
//   if (thread) {
//     // Optionally do stuff, such as wait on the thread.
//   }
// }

typedef struct Payload {
 void(*init)(  void(*)(ACL_FIBER*, void*) ,void*, Option_t);
 void(*func)(ACL_FIBER*,void*);
 void(*cleanup)(void*);
 Mailer* mailer;
 void* data;
 int event_mode;
 Option_t option;
}   Payload;

  void *fiber_thread_init_func(void* data) {
      
    Payload* p = (Payload*)data;
    
    if(p->mailer != NULL) {
  
      fiber_set_mailer(p->mailer);
  }
    if (p->init !=NULL) {
      if (p->data !=NULL) {
          
          p->init(p->func,p->data,p->option);
      }  else {
          p->init(p->func,NULL,p->option);
      }
    } 
  
  
   acl_fiber_schedule_set_event(p->event_mode);
   
   acl_fiber_schedule(); 
   // if (p->cleanup!=NULL) {
       
   //     p->cleanup(p);
   // }
   cleanup_thread = p->cleanup;
    if (p != NULL) {
        mem_free(p);
    }
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
         
     if (fb->typ != 0) {
        if (odin_func != NULL) {
            odin_func(func,fb,data);
        } else {
            func(fb,data);
        }
     return;   
     } 
         
        func(fb,data);
     
 }
  
void fiber_run_odin_func2(void(*func)()) {
    if (odin_func2 != NULL) {
        
        odin_func2(func);
        
    } else {
        func();
    }
     
}
void fiber_run_cleanup() {
      if (cleanup_thread != NULL) {
          cleanup_thread();
      }
  }
  ThreadCtx fiber_create_thread(Mailer* mailer,  Option_t option ,  void(*init)(  void(*)(ACL_FIBER*, void*) ,void*,Option_t),    void(*cleanup)(void*),  void(*func)(ACL_FIBER*,void*),  void* data,    pthread_attr_t* attr,int event_mode ,char detach,int* err) {


    ThreadCtx ctx ;
    ctx.mailer = mailer;
    Payload pl = {};
    pl.event_mode = event_mode;
    pl.init = init;
    pl.data = data;
    pl.mailer = mailer;
    pl.func = func;
    pl.cleanup= cleanup;
    pl.option = option;
    Payload* p=   (Payload*)mem_malloc(sizeof(Payload));
    *p = pl;
if( attr == NULL) {
    *err = pthread_create(&ctx.thrd, NULL, fiber_thread_init_func, p);
} else {
    
    *err = pthread_create(&ctx.thrd, attr, fiber_thread_init_func, p);
    
}
if (detach == 1) {
    ctx.is_detached = 1;
   *err = pthread_detach(ctx.thrd);
}

  return ctx;

}
