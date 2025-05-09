#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <errno.h>
#include <string.h>
#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <signal.h>
#endif
#include "lib_acl.h"
#include "fiber/libfiber.h"
#include "stamp.h"
#include "../patch.h"

#if defined(_WIN32) || defined(_WIN64)
# define snprintf	_snprintf
# define CONNECT	acl_fiber_connect
# define CLOSE		acl_fiber_close
#else
# define SOCKET		int
# define INVALID_SOCKET	-1
# define CONNECT	connect
# define CLOSE		close
#endif

static char __server_ip[64];
static int  __server_port = 9001;

static long long int __total_count = 0;
static int __total_clients         = 0;
static int __total_error_clients   = 0;

static int __show_max      = 10;
static int __show_count    = 0;
static int __fiber_delay   = 0;
static int __conn_timeout  = -1;
static int __read_timeout  = -1;
static int __write_timeout = -1;
static int __max_loop      = 10000;
static int __max_fibers    = 100;
static int __left_fibers   = 100;
static int __read_data     = 1;
static int __stack_size    = 32000;
static int __stack_share   = 0;

static struct timeval __begin;

static int check_read(SOCKET fd, int timeout)
{
	struct pollfd pfd;
	int n;

	memset(&pfd, 0, sizeof(struct pollfd));
	pfd.fd = fd;
	pfd.events = POLLIN;

#if defined(_WIN32) || defined(_WIN64)
	n = acl_fiber_poll(&pfd, 1, timeout);
#else
	n = poll(&pfd, 1, timeout);
#endif
	if (n < 0) {
		printf("poll error: %s\r\n", acl_last_serror());
		return -1;
	}

	if (n == 0) {
		return 0;
	}
	if (pfd.revents & POLLIN) {
		return 1;
	} else {
		printf(">>>poll return n=%d read no ready,fd=%d, pfd=%p\n", n, (int) fd, &pfd);
		return 0;
	}
}

static int check_write(SOCKET fd, int timeout)
{
	struct pollfd pfd;
	int n;

	memset(&pfd, 0, sizeof(struct pollfd));
	pfd.fd = fd;
	pfd.events = POLLOUT;

#if defined(_WIN32) || defined(_WIN64)
	n = acl_fiber_poll(&pfd, 1, timeout);
#else
	n = poll(&pfd, 1, timeout);
#endif

	if (n < 0) {
		printf("poll error: %s\r\n", acl_last_serror());
		return -1;
	}

	if (n == 0) {
		return 0;
	}

	if (pfd.revents & POLLERR) {
		printf(">>>POLLERR, fd=%d\r\n", (int) fd);
		return -1;
	} else if (pfd.revents & POLLHUP) {
		printf(">>>POLLHUP, fd=%d\r\n", (int) fd);
		return -1;
	} else if (pfd.revents & POLLOUT) {
		return 1;
	} else {
		printf(">>>poll return n=%d write no ready,fd=%d, pfd=%p\n", n, (int) fd, &pfd);
		return 0;
	}
}

static void echo_client(SOCKET fd)
{
#define BUF_SIZE 8192
	char *buf = malloc(BUF_SIZE);
	int   ret, i;
	const char *str = "hello world\r\n";

	for (i = 0; i < __max_loop; i++) {
		if (__write_timeout > 0 && check_write(fd, __write_timeout * 1000) <= 0) {
			printf("write wait error=%s, fd=%d\r\n", acl_last_serror(), (int) fd);
			break;
		}

#if defined(_WIN32) || defined(_WIN64)
		if (acl_fiber_send(fd, str, (int) strlen(str), 0) <= 0) {
#else
		if (write(fd, str, strlen(str)) <= 0) {
#endif
			printf("write error: %s\r\n", acl_last_serror());
			break;
		}

		if (!__read_data) {
			__total_count++;
			if (i % 10000 == 0) {
				printf("fiber-%d: total %lld, curr %d\r\n",
					acl_fiber_self(), __total_count, i);
			}
			if (__total_count % 10000 == 0) {
				acl_fiber_yield();
			}
			continue;
		}

		if (__read_timeout > 0 && (ret = check_read(fd, __read_timeout * 1000)) <= 0) {
			printf("read wait error=%s, fd=%d, ret=%d\r\n", acl_last_serror(), (int) fd, ret);
			break;
		}

#if defined(_WIN32) || defined(_WIN64)
		ret = acl_fiber_recv(fd, buf, BUF_SIZE, 0);
#else
		ret = read(fd, buf, BUF_SIZE - 1);
#endif
		if (ret <= 0) {
			printf("read error: %s, fd=%d\r\n", acl_last_serror(), fd);
			break;
		}

		if (++__show_count < __show_max) {
			buf[ret] = 0;
			printf("%s", buf);
			fflush(stdout);
		}

		__total_count++;
	}

	free(buf);
#if defined(_WIN32) || defined(_WIN64)
	acl_fiber_close(fd);
#else
	close(fd);
#endif
}

static SOCKET start_connect(void)
{
	SOCKET  fd = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in sa;
	socklen_t len = (socklen_t) sizeof(sa);

	assert(fd != INVALID_SOCKET);

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_port   = htons(__server_port);
	sa.sin_addr.s_addr = inet_addr(__server_ip);

	if (__fiber_delay > 0) {
		acl_fiber_delay(__fiber_delay);
	}

	if (__conn_timeout > 0) {
		set_non_blocking(fd, 1);
	}

	int ret = CONNECT(fd, (const struct sockaddr *) &sa, len);
	if (ret == 0) {
		return fd;
	}

	printf("%s: ret=%d, errno=%d, %s\n", __FUNCTION__, ret, errno, strerror(errno));

	if (acl_fiber_last_error() != FIBER_EINPROGRESS) {
		CLOSE(fd);
		return INVALID_SOCKET;
	}

	printf("%s: WAITING FOR CONNECTING READY, fd=%d\r\n", __FUNCTION__, (int) fd);

	if (check_write(fd, __conn_timeout) <= 0) {
		CLOSE(fd);
		return INVALID_SOCKET;
	} else {
		return fd;
	}
}

static void fiber_connect(ACL_FIBER *fiber acl_unused, void *ctx acl_unused)
{
	SOCKET fd  = start_connect();

	if (fd == INVALID_SOCKET) {
		__total_error_clients++;
		printf("fiber-%d: connect %s:%d error %s\r\n",
			acl_fiber_self(), __server_ip, __server_port,
			acl_last_serror());
	} else {
		__total_clients++;
		printf("fiber-%d: connect %s:%d ok, clients: %d, fd: %d\r\n",
			acl_fiber_self(), __server_ip, __server_port,
			__total_clients, (int) fd);

		echo_client(fd);
	}

	--__left_fibers;
	printf("max_fibers: %d, left: %d\r\n", __max_fibers, __left_fibers);

	if (__left_fibers == 0) {
		double spent;
		struct timeval end;

		gettimeofday(&end, NULL);
		spent = stamp_sub(&end, &__begin);

		printf("fibers: %d, clients: %d, error: %d, count: %lld, "
			"spent: %.2f ms, speed: %.2f tps\r\n", __max_fibers,
			__total_clients, __total_error_clients,
			__total_count, spent,
			(__total_count * 1000) / (spent > 0 ? spent : 1));

		//acl_fiber_schedule_stop();
	}
}

static void fiber_main(ACL_FIBER *fiber acl_unused, void *ctx acl_unused)
{
	int i;
	ACL_FIBER_ATTR attr;

	acl_fiber_attr_init(&attr);
	acl_fiber_attr_setstacksize(&attr, __stack_size);
	acl_fiber_attr_setsharestack(&attr, __stack_share ? 1 : 0);

	sleep(1); // just waiting for the IO event fiber to run first

	for (i = 0; i < __max_fibers; i++) {
		acl_fiber_create2(&attr, fiber_connect, NULL);
	}
}

static void usage(const char *procname)
{
	printf("usage: %s -h [help]\r\n"
		" -e event_mode [kernel|select|poll|io_uring]\r\n"
		" -s server_ip\r\n"
		" -p server_port\r\n"
		" -t connt_timeout\r\n"
		" -r read_timeout\r\n"
		" -w write_timeout\r\n"
		" -c max_fibers\r\n"
		" -S [if using single IO, dafault: no]\r\n"
		" -Z [if sharing fiber stack, default: no]\r\n"
		" -d fiber_delay_ms\r\n"
		" -z stack_size\r\n"
		" -n max_loop\r\n"
		" -m show_max\r\n"
		, procname);
}

static void test_time(void)
{
	struct timeval begin, end;
	double diff;

	gettimeofday(&begin, NULL);
	//usleep(1000);
	acl_doze(1);
	gettimeofday(&end, NULL);
	diff = stamp_sub(&end, &begin);
	printf("usleep 1000 diff=%.2f\r\n", diff);
}

int main(int argc, char *argv[])
{
	int   ch, event_mode = FIBER_EVENT_KERNEL;
       
	acl_lib_init();
	acl_msg_stdout_enable(1);

#if !defined(_WIN32) && !defined(_WIN64)
	signal(SIGPIPE, SIG_IGN);
#endif

	snprintf(__server_ip, sizeof(__server_ip), "%s", "127.0.0.1");

	while ((ch = getopt(argc, argv, "hc:n:s:p:t:r:w:Sd:z:e:m:Z")) > 0) {
		switch (ch) {
		case 'h':
			usage(argv[0]);
			return 0;
		case 'c':
			__max_fibers = atoi(optarg);
			__left_fibers = __max_fibers;
			break;
		case 't':
			__conn_timeout = atoi(optarg);
			break;
		case 'r':
			__read_timeout = atoi(optarg);
			break;
		case 'w':
			__write_timeout = atoi(optarg);
			break;
		case 'n':
			__max_loop = atoi(optarg);
			break;
		case 's':
			snprintf(__server_ip, sizeof(__server_ip), "%s", optarg);
			break;
		case 'p':
			__server_port = atoi(optarg);
			break;
		case 'S':
			__read_data = 0;
			break;
		case 'd':
			__fiber_delay = atoi(optarg);
			break;
		case 'z':
			__stack_size = atoi(optarg);
			break;
		case 'm':
			__show_max = atoi(optarg);
			break;
		case 'e':
			if (strcasecmp(optarg, "select") == 0) {
				event_mode = FIBER_EVENT_SELECT;
			} else if (strcasecmp(optarg, "poll") == 0) {
				event_mode = FIBER_EVENT_POLL;
			} else if (strcasecmp(optarg, "kernel") == 0) {
				event_mode = FIBER_EVENT_KERNEL;
			} else if (strcasecmp(optarg, "io_uring") == 0) {
				event_mode = FIBER_EVENT_IO_URING;
			}
			break;
		case 'Z':
			__stack_share = 1;
			break;
		default:
			break;
		}
	}

	acl_fiber_msg_stdout_enable(1);
	gettimeofday(&__begin, NULL);

	acl_fiber_create(fiber_main, NULL, 327680);

	printf("call fiber_schedule with=%d\r\n", event_mode);

	acl_fiber_schedule_with(event_mode);

	test_time();

	return 0;
}
