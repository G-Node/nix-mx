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

mxArray* make_mx_array(const nix::Value &v)
{
	mxArray *res;
	nix::DataType dtype = v.type();

	switch (dtype) {
		case nix::DataType::Bool: res = make_mx_array(v.get<bool>()); break;
		case nix::DataType::String: res = make_mx_array(v.get<std::string>()); break;
		case nix::DataType::Double: res = make_mx_array(v.get<double>()); break;
		case nix::DataType::Int32: res = make_mx_array(v.get<std::int32_t>()); break;
		case nix::DataType::UInt32: res = make_mx_array(v.get<std::uint32_t>()); break;
		case nix::DataType::Int64: res = make_mx_array(v.get<std::int64_t>()); break;
		case nix::DataType::UInt64: res = make_mx_array(v.get<std::uint64_t>()); break;

		default: res = make_mx_array(v.get<std::string>());
	}

	return res;

}

mxArray *make_mx_array(const nix::DataSet &da) {
	nix::NDSize size = da.dataExtent();
	const size_t len = size.size();
	std::vector<mwSize> dims(len);

	//NB: matlab is column-major, while HDF5 is row-major
	//    data is correct with this, but dimensions don't
	//    agree with the file anymore. Transpose it in matlab
	//    (DataArray.read_all)
	for (size_t i = 0; i < len; i++) {
		dims[len - (i + 1)] = static_cast<mwSize>(size[i]);
	}

	nix::DataType da_type = da.dataType();
	DType2 dtype = dtype_nix2mex(da_type);

	if (!dtype.is_valid) {
		throw std::domain_error("Unsupported data type");
	}

	mxArray *data = mxCreateNumericArray(dims.size(), dims.data(), dtype.cid, dtype.clx);
	double *ptr = mxGetPr(data);

	nix::NDSize offset(size.size(), 0);
	da.getData(da_type, ptr, size, offset);

	return data;
}
