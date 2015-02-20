#ifndef NIX_MX_MK_ARRAY
#define NIX_MX_MK_ARRAY

#include <nix/NDSize.hpp>

#include <boost/optional.hpp>

#include <cstring>
#include <vector>
#include <cstdint>

#include <mex.h>

#include "handle.h"
#include "datatypes.h"

inline mxArray* make_mx_array(const std::string &s)
{
	return mxCreateString(s.c_str());
}

mxArray *make_mx_array(const nix::Value &value);

mxArray* make_mx_array(const nix::NDSize &size);

mxArray *make_mx_array(const nix::DataSet &da);

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

template<>
inline mxArray* make_mx_array(const std::vector<nix::Value> &v) {
	if (v.empty()) {
		return nullptr;
	}

	nix::DataType ntype = v[0].type();
	mxArray *data;
	if (ntype == nix::DataType::Nothing) {
		data = nullptr; //fixme: something else?
	} else {
		data = mxCreateCellMatrix(1, v.size());
		for (size_t i = 0; i < v.size(); i++) {
			mxSetCell(data, i, make_mx_array(v[i]));
		}
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

inline mxArray* make_mx_array(const handle &h)
{
	return make_mx_array(h.address());
}

#endif
