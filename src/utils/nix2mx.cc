#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "datatypes.h"


mxArray *nmCreateScalar(uint32_t val) {
    mxArray *arr = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    void *data = mxGetData(arr);
    memcpy(data, &val, sizeof(uint32_t));
    return arr;
}

mxArray *dim_to_struct(nix::SetDimension dim) {

    struct_builder sb({ 1 }, { "type", "type_id", "labels" });

    sb.set("set");
    sb.set(1);
    sb.set(dim.labels());

    return sb.array();
}

mxArray *dim_to_struct(nix::SampledDimension dim) {

    struct_builder sb({ 1 }, { "type", "type_id", "interval", "label", "unit" });

    sb.set("sampled");
    sb.set(2);
    sb.set(dim.samplingInterval());
    sb.set(dim.label());
    sb.set(dim.unit());

    return sb.array();
}

mxArray *dim_to_struct(nix::RangeDimension dim) {

    struct_builder sb({ 1 }, { "type", "type_id", "ticks", "unit" });

    sb.set("range");
    sb.set(3);
    sb.set(dim.ticks());
    sb.set(dim.unit());

    return sb.array();
}

nix::NDSize mx_array_to_ndsize(const mxArray *arr) {

    size_t m = mxGetM(arr);
    size_t n = mxGetN(arr);

    //if (m != 1 && n != 1)

    size_t k = std::max(n, m);
    nix::NDSize size(k);

    double *data = mxGetPr(arr);
    for (size_t i = 0; i < size.size(); i++) {
        size[i] = static_cast<nix::NDSize::value_type>(data[i]);
    }

    return size;
}

template<typename T>
T mx_array_to_num(const mxArray *arr) {
    nix::DataType dtype = nix::to_data_type<T>::value;
    
    if (dtype_mex2nix(arr) != dtype) {
        throw std::invalid_argument("wrong type");
    }

    if (mxGetNumberOfElements(arr) < 1) {
        throw std::runtime_error("array empty");
    }

    const void *data = mxGetData(arr);
    T res;
    memcpy(&res, data, sizeof(T));
    return res;
}

nix::Value mx_array_to_value(const mxArray *arr) {
    nix::Value val;

    switch (mxGetClassID(arr)) {
    case mxLOGICAL_CLASS: val.set(mx_array_to_num<bool>(arr)); break;

    case mxCHAR_CLASS: val.set(mx_array_to_num<std::string>(arr)); break;

    case mxDOUBLE_CLASS: val.set(mx_array_to_num<double>(arr)); break;
    case mxSINGLE_CLASS: val.set(mx_array_to_num<float>(arr)); break;

    case mxUINT8_CLASS:  val.set(mx_array_to_num<uint8_t>(arr)); break;
    case mxINT8_CLASS:   val.set(mx_array_to_num<int8_t>(arr)); break;
    case mxUINT16_CLASS: val.set(mx_array_to_num<uint16_t>(arr)); break;
    case mxINT16_CLASS:  val.set(mx_array_to_num<int16_t>(arr)); break;
    case mxUINT32_CLASS: val.set(mx_array_to_num<uint32_t>(arr)); break;
    case mxINT32_CLASS:  val.set(mx_array_to_num<int32_t>(arr)); break;
    case mxUINT64_CLASS: val.set(mx_array_to_num<uint64_t>(arr)); break;
    case mxINT64_CLASS:  val.set(mx_array_to_num<int64_t>(arr)); break;

    default: throw std::invalid_argument("Element type is not recognized");
    }

    return val;
}

