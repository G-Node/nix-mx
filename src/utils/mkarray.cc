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