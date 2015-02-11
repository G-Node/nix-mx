#ifndef NIX_MX_MK_ARRAY
#define NIX_MX_MK_ARRAY

#include <nix/NDSize.hpp>

#include <boost/optional.hpp>

#include <string>
#include <vector>
#include <cstdint>

#include <mex.h>

template<typename T>
struct to_mx_class_id {

	static std::pair<mxClassID, mxComplexity> value() {
		nix::DataType dtype = nix::to_data_type<T>::value;
		switch (dtype) {
		case nix::DataType::Double:
			return std::make_pair(mxDOUBLE_CLASS, mxREAL);

		case nix::DataType::Int64:
			return std::make_pair(mxINT64_CLASS, mxREAL);

		case nix::DataType::Int32:
			return std::make_pair(mxINT32_CLASS, mxREAL);

		default:
			mexErrMsgIdAndTxt("nix:toclassid:notimplemented", "Implement me!");
			return std::make_pair(mxVOID_CLASS, mxREAL);
		}
	}

};


inline mxArray* make_mx_array(const std::string &s)
{
	return mxCreateString(s.c_str());
}

template<typename T>
mxArray* make_mx_array(const std::vector<T> &v) {
	std::pair<mxClassID, mxComplexity> klass = to_mx_class_id<T>::value();
	mxArray *data = mxCreateNumericMatrix(1, v.size(), klass.first, klass.second);
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
mxArray* make_mx_array(T val, typename std::enable_if<std::is_arithmetic<T>::value >::type* = nullptr) {
	std::pair<mxClassID, mxComplexity> klass = to_mx_class_id<T>::value();
	mxArray *arr = mxCreateNumericMatrix(1, 1, klass.first, klass.second);
	void *data = mxGetData(arr);
	memcpy(data, &val, sizeof(T));
	return arr;
}

mxArray* make_mx_array(const nix::NDSize &size);

#endif