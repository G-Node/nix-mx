#ifndef NIX_MX_MK_ARRAY
#define NIX_MX_MK_ARRAY

#include <nix/NDSize.hpp>

#include <boost/optional.hpp>

#include <cstring>
#include <vector>
#include <cstdint>

#include "handle.h" // will include nix.h, mex.h
#include "datatypes.h"

inline mxArray* make_mx_array(const std::string &s)
{
	return mxCreateString(s.c_str());
}

mxArray* make_mx_array_from_ds(const nix::DataSet &da);

mxArray* make_mx_array(const nix::Value &value);

mxArray* make_mx_array(const nix::NDSize &size);

mxArray* make_mx_array(const nix::LinkType &ltype);

mxArray* make_mx_array(const nix::DimensionType &dtype);

template<typename T, nix::DataType dt = nix::to_data_type<T>::value>
mxArray* make_mx_array(const std::vector<T> &v) {
	DType2 dtype = dtype_nix2mex(dt);
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

template<typename T, typename std::enable_if<entity_to_id<T>::is_valid>::type* = nullptr>
inline mxArray *make_mx_array(const T& entity) {

	if(!entity) {
		return make_mx_array(uint64_t(0));
	}

	handle hdl = handle(entity);
	return make_mx_array(hdl.address());
}

template<typename T, int EntityId = entity_to_id<T>::value>
inline mxArray *make_mx_array(const std::vector<T> &v) {
	const mwSize size = static_cast<mwSize>(v.size());
	mxArray *lst = mxCreateCellArray(1, &size);

	for (size_t i = 0; i < v.size(); i++) {
		handle hdl = handle(v[i]);
		mxSetCell(lst, i, make_mx_array(hdl));
	}

	return lst;
}

inline mxArray* make_mx_array(const std::vector<nix::Dimension> &dims) {
    const char *field_names[] = { "dtype", "dimension" };
    mwSize dim_arr[2] = {1, dims.size()};
    nix::DimensionType dt;

    mxArray *data = mxCreateStructArray(2, dim_arr, 2, field_names);
    for (size_t i = 0; i < dims.size(); i++) {
        dt = dims[i].dimensionType();

        switch (dt) {
        case nix::DimensionType::Set: 
            mxSetFieldByNumber(data, i, 0, mxCreateString("set"));
            mxSetFieldByNumber(data, i, 1, make_mx_array(dims[i].asSetDimension()));
            break;
        case nix::DimensionType::Range:
            mxSetFieldByNumber(data, i, 0, mxCreateString("range"));
            mxSetFieldByNumber(data, i, 1, make_mx_array(dims[i].asRangeDimension()));
            break;
        case nix::DimensionType::Sample:
            mxSetFieldByNumber(data, i, 0, mxCreateString("sample"));
            mxSetFieldByNumber(data, i, 1, make_mx_array(dims[i].asSampledDimension()));
            break;
        default: throw std::invalid_argument("Encountered unknown dimension type");
            break;
        }
    }

    return data;
}

template<typename T>
mxArray* make_mx_array(const boost::optional<T> &opt) {
    if (opt) {
        return make_mx_array(*opt);
    }
    else {
        return nullptr;
    }
}


#endif
