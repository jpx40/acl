#pragma once
#include "fiber_cpp_define.hpp"

#include "acl_cpp/stdlib/atomic.hpp"

namespace acl {

template<typename T> class fiber_tbox;

class FIBER_CPP_API wait_group {
public:
	wait_group();
	~wait_group();

	void add(int n);
	void done();
	void wait();

private:
	atomic_long state_;
	fiber_tbox<unsigned long>* box_;
};

} // namespace acl
