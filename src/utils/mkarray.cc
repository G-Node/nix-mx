#include "mkarray.h"

mxArray* make_mx_array(const nix::NDSize &size)
{
	mxArray *res = mxCreateNumericMatrix(1, size.size(), mxUINT64_CLASS, mxREAL);
	void *ptr = mxGetData(res);
	uint64_t *data = static_cast<uint64_t *>(ptr);

	for (size_t i = 0; i < size.size(); i++) {
		data[i] = static_cast<uint64_t>(size[i]);
	}

	return res;
}