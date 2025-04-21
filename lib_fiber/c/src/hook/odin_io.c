




#include <stdio.h>
#include <sys/fcntl.h>
#include <sys/stat.h>

#include <unistd.h>
  int acl_fiber_open(const char * pathname, int flags, ...) {
    
    return    open(pathname, flags);

}

int acl_fiber_unlink(const char *pathname) {
    
    return unlink(pathname);
}
ssize_t __acl_fiber_pwrite(int fd, const void *buf, size_t count, off_t offset) {
    
    return pwrite(fd, buf,count,  offset);
}

  int acl_fiber_openat(int dirfd, const char * pathname, int flags, ...) {
    
    return    openat(dirfd,pathname, flags);

}

#ifdef HAS_RENAMEAT2
  int acl_fiber_renameat2(int olddirfd, const char *oldpath,
	int newdirfd, const char *newpath, unsigned int flags) {
	
	return renameat2(olddirfd, oldpath,
	 newdirfd, newpath, flags);
	}

	int acl_fiber_renameat(int olddirfd, const char *oldpath, int newdirfd, const char *newpath)
{
		return renameat2(olddirfd, oldpath, newdirfd, newpath, 0);
}
#endif

  int acl_fiber_rename(const char *oldpath, const char *newpath)
{
	return renameat(AT_FDCWD, oldpath, AT_FDCWD, newpath);
}


  int acl_fiber_mkdirat(int dirfd, const char *pathname, mode_t mode) {
    
   return mkdirat(dirfd,pathname, mode);
    
}
  ssize_t  acl_fiber_pread(int fd, void *buf, size_t count, off_t offset) {
    
    return pread(fd, buf,  count,  offset);
}
