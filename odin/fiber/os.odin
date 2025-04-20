package fiber
import "core:io"
import "core:os"
import "core:strconv"
import "core:unicode/utf8"
OS :: ODIN_OS
ARCH :: ODIN_ARCH
ENDIAN :: ODIN_ENDIAN

SEEK_SET :: 0
SEEK_CUR :: 1
SEEK_END :: 2
write_string :: proc(fd: os.Handle, str: string) -> (int, os.Error) {
	return write(fd, transmute([]byte)str)
}

write_byte :: proc(fd: os.Handle, b: byte) -> (int, os.Error) {
	return write(fd, []byte{b})
}

write_rune :: proc(fd: os.Handle, r: rune) -> (int, os.Error) {
	if r < utf8.RUNE_SELF {
		return write_byte(fd, byte(r))
	}

	b, n := utf8.encode_rune(r)
	return write(fd, b[:n])
}

write_encoded_rune :: proc(f: os.Handle, r: rune) -> (n: int, err: os.Error) {
	wrap :: proc(m: int, merr: os.Error, n: ^int, err: ^os.Error) -> bool {
		n^ += m
		if merr != nil {
			err^ = merr
			return true
		}
		return false
	}

	if wrap(write_byte(f, '\''), &n, &err) { return }

	switch r {
	case '\a': if wrap(write_string(f, "\\a"), &n, &err) { return }
	case '\b': if wrap(write_string(f, "\\b"), &n, &err) { return }
	case '\e': if wrap(write_string(f, "\\e"), &n, &err) { return }
	case '\f': if wrap(write_string(f, "\\f"), &n, &err) { return }
	case '\n': if wrap(write_string(f, "\\n"), &n, &err) { return }
	case '\r': if wrap(write_string(f, "\\r"), &n, &err) { return }
	case '\t': if wrap(write_string(f, "\\t"), &n, &err) { return }
	case '\v': if wrap(write_string(f, "\\v"), &n, &err) { return }
	case:
		if r < 32 {
			if wrap(write_string(f, "\\x"), &n, &err) { return }
			b: [2]byte
			s := strconv.append_bits(b[:], u64(r), 16, true, 64, strconv.digits, nil)
			switch len(s) {
			case 0: if wrap(write_string(f, "00"), &n, &err) { return }
			case 1: if wrap(write_rune(f, '0'), &n, &err)    { return }
			case 2: if wrap(write_string(f, s), &n, &err)    { return }
			}
		} else {
			if wrap(write_rune(f, r), &n, &err) { return }
		}
	}
	_ = wrap(write_byte(f, '\''), &n, &err)
	return
}

read_at_least :: proc(fd: os.Handle, buf: []byte, min: int) -> (n: int, err: os.Error) {
	if len(buf) < min {
		return 0, io.Error.Short_Buffer
	}
	nn := max(int)
	for nn > 0 && n < min && err == nil {
		nn, err = read(fd, buf[n:])
		n += nn
	}
	if n >= min {
		err = nil
	}
	return
}

read_full :: proc(fd: os.Handle, buf: []byte) -> (n: int, err: os.Error) {
	return read_at_least(fd, buf, len(buf))
}


@(require_results)
read_entire_file_from_filename :: proc(name: string, allocator := context.allocator, loc := #caller_location) -> (data: []byte, success: bool) {
	err: os.Error
	data, err = read_entire_file_from_filename_or_err(name, allocator, loc)
	success = err == nil
	return
}

@(require_results)
read_entire_file_from_handle :: proc(fd: os.Handle, allocator := context.allocator, loc := #caller_location) -> (data: []byte, success: bool) {
	err: os.Error
	data, err = read_entire_file_from_handle_or_err(fd, allocator, loc)
	success = err == nil
	return
}

read_entire_file :: proc {
	read_entire_file_from_filename,
	read_entire_file_from_handle,
}

@(require_results)
read_entire_file_from_filename_or_err :: proc(name: string, allocator := context.allocator, loc := #caller_location) -> (data: []byte, err: os.Error) {
	context.allocator = allocator

	fd := open(name, os.O_RDONLY, 0) or_return
	defer close(fd)

	return read_entire_file_from_handle_or_err(fd, allocator, loc)
}

@(require_results)
read_entire_file_from_handle_or_err :: proc(fd: os.Handle, allocator := context.allocator, loc := #caller_location) -> (data: []byte, err: os.Error) {
	context.allocator = allocator

	length := os.file_size(fd) or_return
	if length <= 0 {
		return nil, nil
	}

	data = make([]byte, int(length), allocator, loc) or_return
	if data == nil {
		return nil, nil
	}
	defer if err != nil {
		delete(data, allocator)
	}

	bytes_read := read_full(fd, data) or_return
	data = data[:bytes_read]
	return
}

read_entire_file_or_err :: proc {
	read_entire_file_from_filename_or_err,
	read_entire_file_from_handle_or_err,
}


write_entire_file :: proc(name: string, data: []byte, truncate := true) -> (success: bool) {
	return write_entire_file_or_err(name, data, truncate) == nil
}

@(require_results)
write_entire_file_or_err :: proc(name: string, data: []byte, truncate := true) -> os.Error {
	flags: int = os.O_WRONLY|os.O_CREATE
	if truncate {
		flags |= os.O_TRUNC
	}

	mode: int = 0
	when OS == .Linux || OS == .Darwin {
		// NOTE(justasd): 644 (owner read, write; group read; others read)
		mode = os.S_IRUSR | os.S_IWUSR |os.S_IRGRP | os.S_IROTH
	}

	fd := open(name, flags, mode) or_return
	defer close(fd)

	for n := 0; n < len(data); {
		n += write(fd, data[n:]) or_return
	}
	return nil
}

write_ptr :: proc(fd: os.Handle, data: rawptr, len: int) -> (int, os.Error) {
	return write(fd, ([^]byte)(data)[:len])
}

read_ptr :: proc(fd: os.Handle, data: rawptr, len: int) -> (int, os.Error) {
	return read(fd, ([^]byte)(data)[:len])
}