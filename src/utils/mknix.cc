#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include <map>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "datatypes.h"


void check_arg_type(const mxArray *arr, nix::DataType dtype) {
    if (dtype_mex2nix(arr) != dtype) {
        throw std::invalid_argument("wrong type");
    }
}

mxArray *nmCreateScalar(uint32_t val) {
    mxArray *arr = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    void *data = mxGetData(arr);
    memcpy(data, &val, sizeof(uint32_t));
    return arr;
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

std::string mx_array_to_str(const mxArray *arr) {
    check_arg_type(arr, nix::DataType::String);

    std::string the_string = mxArrayToString(arr);
    return the_string;
}

template<typename T>
T mx_array_to_num(const mxArray *arr) {
    check_arg_type(arr, nix::to_data_type<T>::value);

    if (mxGetNumberOfElements(arr) < 1) {
        throw std::runtime_error("array empty");
    }

    const void *data = mxGetData(arr);
    T res;
    memcpy(&res, data, sizeof(T));
    return res;
}

bool mx_array_to_bool(const mxArray *arr) {
    check_arg_type(arr, nix::DataType::Bool);

    const mxLogical *l = mxGetLogicals(arr);
    return l[0];
}


nix::Value mx_array_to_value_from_scalar(const mxArray *arr) {
    /*
    Assuming arr is a scalar mxArray.
    */
    nix::Value val;

    switch (mxGetClassID(arr)) {
    case mxLOGICAL_CLASS: val.set(mx_array_to_bool(arr)); break;
    case mxCHAR_CLASS: val.set(mx_array_to_str(arr)); break;
    case mxDOUBLE_CLASS: val.set(mx_array_to_num<double>(arr)); break;
    case mxUINT32_CLASS: val.set(mx_array_to_num<uint32_t>(arr)); break;
    case mxINT32_CLASS:  val.set(mx_array_to_num<int32_t>(arr)); break;
    case mxUINT64_CLASS: val.set(mx_array_to_num<uint64_t>(arr)); break;
    case mxINT64_CLASS:  val.set(mx_array_to_num<int64_t>(arr)); break;

    case mxSINGLE_CLASS: throw std::invalid_argument("Element type is not supported");
    case mxUINT8_CLASS:  throw std::invalid_argument("Element type is not supported");
    case mxINT8_CLASS:   throw std::invalid_argument("Element type is not supported");
    case mxUINT16_CLASS: throw std::invalid_argument("Element type is not supported");
    case mxINT16_CLASS:  throw std::invalid_argument("Element type is not supported");

    default: throw std::invalid_argument("Element type is not recognized");
    }

    return val;
}

nix::Value mx_array_to_value_from_struct(const mxArray *arr) {
    /*
    Assuming arr is a struct mxArray.
    */
    static std::map<std::string, int> arg_map = {
        { "value", 0 },
        { "uncertainty", 1 },
        { "checksum", 2 },
        { "encoder", 3 },
        { "filename", 4 },
        { "reference", 5 }
    };

    nix::Value val;
    bool has_value = false;

    int number_of_fields = mxGetNumberOfFields(arr);
    for (int idx = 0; idx < number_of_fields; idx++)  {
        const char  *field_name = mxGetFieldNameByNumber(arr, idx);
        const mxArray *field_array_ptr = mxGetFieldByNumber(arr, 0, idx);

        std::string arg_name = field_name;
        switch (arg_map[arg_name]) {
        case 0: val = mx_array_to_value_from_scalar(field_array_ptr); break;
        case 1: val.uncertainty = mx_array_to_num<double>(field_array_ptr); break;
        case 2: val.checksum = mx_array_to_str(field_array_ptr); break;
        case 3: val.encoder = mx_array_to_str(field_array_ptr); break;
        case 4: val.filename = mx_array_to_str(field_array_ptr); break;
        case 5: val.reference = mx_array_to_str(field_array_ptr); break;
        default: throw std::invalid_argument(strcat("Field is not supported: ", field_name));
        }
    }

    return val;
}