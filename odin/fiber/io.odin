package fiber 



import "core:os"
import "core:fmt"
import "base:runtime"
import "core:strings"

import "core:c"

@(require_results)
open :: proc(path: string, flags: int = os.O_RDONLY, mode: int = 0o000) -> (os.Handle, os.Error) {
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	cstr := strings.clone_to_cstring(path, context.temp_allocator)
	handle := acl_fiber_open(cstr, i32(flags), i32(mode))
	if handle < 0 {
		return os.INVALID_HANDLE, os.Platform_Error(handle)
	}
	return os.Handle(handle), nil
}



close_file :: proc(fd: os.Handle) -> os.Error {
	return os.Platform_Error(acl_fiber_close(socket(fd)))
}

// If you read or write more than `SSIZE_MAX` bytes, result is implementation defined (probably an error).
// `SSIZE_MAX` is also implementation defined but usually the max of a `ssize_t` which is `max(int)` in Odin.
// In practice a read/write call would probably never read/write these big buffers all at once,
// which is why the number of bytes is returned and why there are procs that will call this in a
// loop for you.
// We set a max of 1GB to keep alignment and to be safe.
@(private)
MAX_RW :: 1 << 30

read :: proc(fd: os.Handle, data: []u8) -> (total_read: int, err: os.Error) {

if len(data) == 0 {
		return 0, nil
	}

	to_read := min(uint(len(data)), MAX_RW)

	bytes_read := int(acl_fiber_read(socket(fd), raw_data(data), to_read))
	if bytes_read < 0 {
		return -1, os.Platform_Error(int(bytes_read))
	}
	return bytes_read, nil
}


write :: proc(fd: os.Handle, data: []byte) -> (int, os.Error) {
	if len(data) == 0 {
		return 0, nil
	}

	to_write := min(uint(len(data)), MAX_RW)

	bytes_written := int(acl_fiber_write(socket(fd), raw_data(data), to_write))
	if bytes_written < 0 {
		return -1, os.Platform_Error(bytes_written)
	}
	return bytes_written, nil

} 


read_at :: proc(fd: os.Handle, data: []byte, offset: i64) -> (int, os.Error) {
	if len(data) == 0 {
		return 0, nil
	}

	to_read := min(uint(len(data)), MAX_RW)

	bytes_read := int(acl_fiber_pread(socket(fd), raw_data(data), to_read, offset))
	if bytes_read < 0 {
		return -1, os.Platform_Error(bytes_read)
	}
	return bytes_read, nil
}

write_at :: proc(fd: os.Handle, data: []byte, offset: i64) -> (int, os.Error) {
	if len(data) == 0 {
		return 0, nil
	}

	to_write := min(uint(len(data)), MAX_RW)

	bytes_written := int(__acl_fiber_write(socket(fd), raw_data(data), to_write, offset))
	if bytes_written < 0 {
		return -1, os.Platform_Error(bytes_written)
	}
	return bytes_written, nil
}

rename :: proc(old_path, new_path: string) -> os.Error {
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	old_path_cstr := strings.clone_to_cstring(old_path, context.temp_allocator)
	new_path_cstr := strings.clone_to_cstring(new_path, context.temp_allocator)
	return os.Platform_Error(acl_fiber_rename(old_path_cstr, new_path_cstr))
}

remove :: proc(path: string) -> os.Error {
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	path_cstr := strings.clone_to_cstring(path, context.temp_allocator)
	return  os.Platform_Error(acl_fiber_unlink(path_cstr))
}



@(require_results)
poll :: proc(fds: []os.pollfd, timeout: int) -> (int, os.Error) {
	result := acl_fiber_poll(raw_data(fds), c.uint(len(fds)), i32(timeout))
	if result < 0 {
		return 0, os.Platform_Error(result)
	}
	return int(result), nil
}
close :: proc {

    close_file,
    close_tcp,
    close_udp,
}