#ifndef NIX_MX_MK_ARRAY
#define NIX_MX_MK_ARRAY

#include <nix/NDSize.hpp>

#include <boost/optional.hpp>

#include <string>
#include <vector>
#include <cstdint>

#include <mex.h>

#include "handle.h"
#include "datatypes.h"

inline mxArray* make_mx_array(const std::string &s)
{
	return mxCreateString(s.c_str());
}


template<typename T>
mxArray* make_mx_array(const std::vector<T> &v) {
	DType2 dtype = dtype_nix2mex(nix::to_data_type<T>::value);
	mxArray *data = mxCreateNumericMatrix(1, v.size(), dtype.cid, dtype.clx);
	double *ptr = mxGetPr(data);
	memcpy(ptr, v.data(), sizeof(T) * v.size());
	return data;
}

template<>
inline mxArray* make_mx_array(const std::vector<std::string> &v) {

	if (v.empty()) {
		return nullptr;
	}

	mxArray *data = mxCreateCellMatrix(1, v.size());
	for (size_t i = 0; i < v.size(); i++) {
		mxSetCell(data, i, mxCreateString(v[i].c_str()));
	}

	return data;
}

template<typename T>
mxArray* make_mx_array(const boost::optional<T> &opt) {
	if (opt) {
		make_mx_array(*opt);
	}

	return nullptr;
}

template<typename T>
typename std::enable_if<std::is_arithmetic<T>::value, mxArray>::type* make_mx_array(T val) {
	DType2 dtype = dtype_nix2mex(nix::to_data_type<T>::value);
	mxArray *arr = mxCreateNumericMatrix(1, 1, dtype.cid, dtype.clx);
	void *data = mxGetData(arr);
	memcpy(data, &val, sizeof(T));
	return arr;
}

template<>
inline mxArray* make_mx_array<bool>(bool val) {
	return mxCreateLogicalScalar(val);
}

mxArray* make_mx_array(const nix::NDSize &size);

inline mxArray* make_mx_array(const handle &h)
{
	return make_mx_array(h.address());
}

#endif