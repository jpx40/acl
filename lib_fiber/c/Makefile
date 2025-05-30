SHELL = /bin/sh
CC      = gcc
#CC      = g++
CC	= ${ENV_CC}
AR      = ${ENV_AR}
ARFL    = rv
#ARFL    = cru
RANLIB  = ${ENV_RANLIB}

#JMP_CTX = USE_CONTEXT
JMP_CTX = USE_JMP_DEF
#JMP_CTX = USE_BOOST_JMP
#JMP_CTX = USE_JMP_SYS

CFLAGS = -c -g -W \
-std=gnu99 \
-fPIC \
-Wall \
-Wpointer-arith \
-Wshadow \
-D_REENTRANT \
-D_POSIX_PTHREAD_SEMANTICS \
-D_USE_FAST_MACRO \
-Wno-long-long \
-Wmissing-prototypes \
-Wcast-qual \
-DUSE_FAST_RING \
-O3 \
-DUSE_CLOCK_GETTIME \
#-DUSE_VALGRIND \
#-DDEBUG_READY \
#-DUSE_INLINE_MEMCPY\
#-DUSE_FAST_TIME \
#-Waggregate-return \
#-DDEBUG_MEM \
#-I/usr/local/include
#-DUSE_PRINTF_MACRO
#-Wno-clobbered

#-pedantic
# -Wcast-align
#CFLAGS = -c -g -W -Wall -Wcast-qual -Wcast-align \
#-Waggregate-return -Wmissing-prototypes \
#-Wpointer-arith -Werror -Wshadow -O2 \
#-D_POSIX_PTHREAD_SEMANTICS -D_USE_FAST_MACRO
###########################################################
#Check system:
#       Linux, SunOS, Solaris, BSD variants, AIX, HP-UX
SYSLIB =
CHECKSYSRES = @echo "Unknow system type!";exit 1
UNIXNAME = $(shell uname -sm)
UNIXTYPE = LINUX

###########################################################

STATIC_LIBNAME = libfiber.a
SHARED_LIBNAME = libfiber.so
STATIC_OLD_LIBNAME = lib_fiber.a
SHARED_OLD_LIBNAME = lib_fiber.so

ifeq ($(CC),)
        CC = gcc
endif

ifeq ($(AR),)
	AR = ar
endif

ifeq ($(RANLIB),)
	RANLIB = ranlib
endif

ifeq ($(findstring Alpine, $(shell uname -a)), Alpine)
	CFLAGS += -DALPINE
endif

#ifeq ($(findstring gcc, $(CC)), gcc)
#	CFLAGS += -Wstrict-prototypes
#	GCC_VERSION=$(shell gcc --version | grep ^gcc | sed 's/^.* //g')
#	GCC_MAJOR:=$(shell echo "$(GCC_VERSION)" | cut -d'.' -f1)
#	GCC_MINOR:=$(shell echo "$(GCC_VERSION)" | cut -d'.' -f2)
#	GCC_SUB:=$(shell echo "$(GCC_VERSION)" | cut -d'.' -f3)
#	GCC_VER:=$(shell [ $(GCC_MAJOR) -gt 4 -o \( $(GCC_MAJOR) -eq 4 -a $(GCC_MINOR) -gt 4 \) ] && echo true)
#	ifeq ($(GCC_VER), true)
#		CFLAGS += -Wno-implicit-fallthrough
#		CFLAGS += -Wno-absolute-value
#	endif
#endif

ifeq ($(findstring clang, $(CC)), clang)
	CFLAGS += -Wstrict-prototypes \
		  -Wno-invalid-source-encoding \
		  -Wno-invalid-offsetof
endif

ifeq ($(findstring clang++, $(CC)), clang++)
	CFLAGS += -Wno-invalid-source-encoding \
		  -Wno-invalid-offsetof
endif

ifeq ($(findstring cosmocc, $(CC)), cosmocc)
	CFLAGS += -DCOSMOCC
	CFLAGS += -Wno-implicit-fallthrough
	CFLAGS += -DLINUX2
	AR = cosmoar

endif

ifeq ($(findstring arm64, $(UNIXNAME)), arm64)
	JMP_CTX = USE_BOOST_JMP
endif

ifeq ($(findstring arm32, $(UNIXNAME)), arm32)
	JMP_CTX = USE_BOOST_JMP
endif

ifeq ($(findstring arm, $(UNIXNAME)), arm)
	JMP_CTX = USE_BOOST_JMP
endif

# For FreeBSD
ifeq ($(findstring FreeBSD, $(UNIXNAME)), FreeBSD)
	UNIXTYPE = FREEBSD
endif

# For Darwin
ifeq ($(findstring Darwin, $(UNIXNAME)), Darwin)
	UNIXTYPE = MACOSX
#	CC += -arch x86_64 -arch arm64
	CFLAGS += -DMACOSX -Wno-invalid-source-encoding \
		  -Wno-invalid-offsetof \
		  -Wno-deprecated-declarations
	SHARED_LIBNAME = libfiber.dylib
	SHARED_OLD_LIBNAME = lib_fiber.dylib
endif

# For Linux
ifeq ($(findstring Linux, $(UNIXNAME)), Linux)
	UNIXTYPE = LINUX
	CFLAGS += -DSHARE_STACK

	ifeq ($(HOOK_MMSG_UBUNTU), yes)
		CFLAGS += -DHOOK_MMSG_UBUNTU
	endif

	ifeq ($(HOOK_MMSG_CENTOS), yes)
		CFLAGS += -DHOOK_MMSG_CENTOS
	endif

# If HAS_IO_URING=yes or has_io_uring=yes has been set in environment,
# or you run "$make HAS_IO_URING=yes", the io_uring engine will be used.
# will use io_uring.
	ifeq ($(HAS_IO_URING), yes)
		CFLAGS += -DHAS_IO_URING
	endif
	ifeq ($(has_io_uring), yes)
		CFLAGS += -DHAS_IO_URING
	endif
	ifeq ($(HAS_STATX), yes)
		CFLAGS += -DHAS_STATX
	endif
	ifeq ($(HAS_RENAMEAT2), yes)
		CFLAGS += -DHAS_RENAMEAT2
	endif

	ifeq ($(DEBUG_STACK), yes)
		CFLAGS += -DDEBUG_STACK
	endif
	ifeq ($(debug_stack), yes)
		CFLAGS += -DDEBUG_STACK
	endif

	ifeq ($(USE_TCMALLOC), yes)
		CFLAGS += -DUSE_TCMALLOC
	endif
	ifeq ($(USE_TCMALLOC), YES)
		CFLAGS += -DUSE_TCMALLOC
	endif
endif

# For CYGWIN
ifeq ($(findstring CYGWIN, $(UNIXNAME)), CYGWIN)
	CFLAGS += -DLINUX2 -DMINGW
endif

# For MINGW
ifeq ($(findstring MINGW, $(UNIXNAME)), MINGW)
	CFLAGS += -DLINUX2 -DMINGW
endif

# For MSYS
ifeq ($(findstring MSYS, $(UNIXNAME)), MSYS)
	CFLAGS += -DLINUX2 -DMINGW
endif

# For SunOS
ifeq ($(findstring SunOS, $(UNIXNAME)), SunOS)
	ifeq ($(findstring 86, $(UNIXNAME)), 86)
		SYSLIB = -lsocket -lnsl -lrt
	endif
	ifeq ($(findstring sun4u, $(UNIXNAME)), sun4u)
		SYSLIB = -lsocket -lnsl -lrt
	endif
	CFLAGS += -DSUNOS5
	UNIXTYPE = SUNOS5
endif

# For HP-UX
ifeq ($(findstring HP-UX, $(UNIXNAME)), HP-UX)
	CFLAGS += -DHP_UX -DHPUX11
	UNIXTYPE = HPUX
endif

# set which jump lib should be used
CFLAGS += -D$(JMP_CTX)

#Find system type.
ifneq ($(SYSPATH),)
	CHECKSYSRES = @echo "System is $(shell uname -sm)"
endif

###########################################################

$(shell mkdir -p ../lib)

LIB_PATH_DST = ../lib
OBJ_PATH_DST = ./debug

SRC_PATH_SRC = ./src

INC_COMPILE  = -I./include -I./src -I./src/common
CFLAGS += $(INC_COMPILE)

#Project's objs
SRC = $(wildcard $(SRC_PATH_SRC)/*.c) \
      $(wildcard $(SRC_PATH_SRC)/common/*.c) \
      $(wildcard $(SRC_PATH_SRC)/dns/*.c) \
      $(wildcard $(SRC_PATH_SRC)/fiber/*.c) \
      $(wildcard $(SRC_PATH_SRC)/event/*.c) \
      $(wildcard $(SRC_PATH_SRC)/hook/*.c) \
      $(wildcard $(SRC_PATH_SRC)/sync/*.c) \
            $(wildcard $(SRC_PATH_SRC)/odin/*.c)

#ASM_OBJ=$(OBJ_PATH_DST)/setjmp.o $(OBJ_PATH_DST)/make_gas.o $(OBJ_PATH_DST)/jump_gas.o

ASM_OBJ=$(OBJ_PATH_DST)/make_gas.o $(OBJ_PATH_DST)/jump_gas.o
OBJ = $(patsubst %.c, $(OBJ_PATH_DST)/%.o, $(notdir $(SRC))) $(ASM_OBJ)

###########################################################

.PHONY = static shared clean
COMPILE = $(CC) $(CFLAGS)
COMPILE_FIBER = $(CC) $(CFLAGS) 

all: static shared
rebuild rb: clean all

$(shell mkdir -p $(OBJ_PATH_DST))

static: $(OBJ)
	@echo 'creating $(LIB_PATH_DST)/$(STATIC_LIBNAME)'
	$(AR) $(ARFL) $(LIB_PATH_DST)/$(STATIC_LIBNAME) $(OBJ)
	$(RANLIB) $(LIB_PATH_DST)/$(STATIC_LIBNAME)
	@(cd $(LIB_PATH_DST); rm -f ${STATIC_OLD_LIBNAME}; \
		ln -s $(STATIC_LIBNAME) ${STATIC_OLD_LIBNAME})
	@echo 'build $(LIB_PATH_DST)/$(STATIC_LIBNAME) ok!'

shared_ldflags = -lrt -lpthread
shared: $(OBJ)
	@echo ''
	@echo 'creating $(SHARED_LIBNAME)'
	@if test -n "$(rpath)" && test "$(UNIXTYPE)" = "LINUX"; then \
		echo "building for linux"; \
		$(CC) -shared -o $(rpath)/$(SHARED_LIBNAME) $(OBJ) \
			-L$(rpath) $(shared_ldflags) -Wl,-rpath,$(rpath); \
		echo 'build $(rpath)/$(SHARED_LIBNAME) ok!'; \
	elif test -n "$(rpath)" && test "$(UNIXTYPE)" = "SUNOS5"; then \
		echo "building for sunos5"; \
		$(CC) -shared -o $(rpath)/$(SHARED_LIBNAME) $(OBJ) \
			-R$(rpath) -L$(rpath) $(shared_ldflags); \
		echo 'build $(rpath)/$(SHARED_LIBNAME) ok!'; \
	elif test -n "$(rpath)" && test "$(UNIXTYPE)" = "MACOSX"; then \
		shared_ldflags = -lpthread; \
		echo "building for Darwin"; \
		$(CC) -shared -o $(rpath)/$(SHARED_LIBNAME) $(OBJ) \
			-R$(rpath) -L$(rpath) -lpthread; \
		echo 'build $(rpath)/$(SHARED_LIBNAME) ok!'; \
	elif test -n "$(rpath)" && test "$(UNIXTYPE)" = "FREEBSD"; then \
		echo "building for FreeBSD"; \
		$(CC) -shared -o $(rpath)/$(SHARED_LIBNAME) $(OBJ) \
			-R$(rpath) -L$(rpath) -lpthread; \
		echo 'build $(rpath)/$(SHARED_LIBNAME) ok!'; \
	else \
		echo 'skip build $(SHARED_LIBNAME); usage: make shared rpath=xxx'; \
	fi

$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/common/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/dns/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/fiber/%.c
	$(COMPILE) $< -o $@
#$(OBJ_PATH_DST)/setjmp.o: $(SRC_PATH_SRC)/fiber/exp/setjmp.S
#	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/make_gas.o: $(SRC_PATH_SRC)/fiber/boost/make_gas.S
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/jump_gas.o: $(SRC_PATH_SRC)/fiber/boost/jump_gas.S
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/event/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/hook/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/sync/%.c
	$(COMPILE) $< -o $@
$(OBJ_PATH_DST)/%.o: $(SRC_PATH_SRC)/odin/%.c
	$(COMPILE) $< -o $@
clean cl:
	rm -f $(LIB_PATH_DST)/${STATIC_LIBNAME}
	rm -f $(LIB_PATH_DST)/${SHARED_LIBNAME}
	rm -f $(LIB_PATH_DST)/${STATIC_OLD_LIBNAME}
	rm -f $(LIB_PATH_DST)/${SHARED_OLD_LIBNAME}
	rm -f $(OBJ)
