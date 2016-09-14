// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "mkarray.h"
#include "mex.h"
#include <nix.hpp>

mxArray* make_mx_array_from_ds(const nix::DataSet &da) {
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

    mxArray *data;
    if (dtype.cid == mxCHAR_CLASS) {
        throw std::domain_error("String DataArrays are not supported as of yet.");
    } else {
        data = mxCreateNumericArray(dims.size(), dims.data(), dtype.cid, dtype.clx);
        double *ptr = mxGetPr(data);
        nix::NDSize offset(size.size(), 0);
        da.getData(da_type, ptr, size, offset);
    }

    return data;
}

mxArray* make_mx_array(const nix::NDSize &size) {
    mxArray *res = mxCreateNumericMatrix(1, size.size(), mxUINT64_CLASS, mxREAL);
    void *ptr = mxGetData(res);
    uint64_t *data = static_cast<uint64_t *>(ptr);

    for (size_t i = 0; i < size.size(); i++) {
        data[i] = static_cast<uint64_t>(size[i]);
    }

    return res;
}

mxArray* make_mx_array(const nix::LinkType &ltype) {
    uint8_t link_type;

    switch (ltype) {
        case nix::LinkType::Tagged: link_type = 0; break;
        case nix::LinkType::Untagged: link_type = 1; break;
        case nix::LinkType::Indexed: link_type = 2; break;
        default: throw std::invalid_argument("unkown link type");
    }
    mxArray *data = mxCreateDoubleScalar(link_type);

    return data;
}

mxArray* make_mx_array(const nix::DimensionType &dtype) {
    const char *d_type;

    switch (dtype) {
    case nix::DimensionType::Set: d_type = "set"; break;
    case nix::DimensionType::Sample: d_type = "sample"; break;
    case nix::DimensionType::Range: d_type = "range"; break;
    default: throw std::invalid_argument("unkown dimension type");
    }
    mxArray *data = mxCreateString(d_type);

    return data;
}

mxArray* make_mx_array(const nix::Value &v) {
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
