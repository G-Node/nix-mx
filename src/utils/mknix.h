#ifndef NIX_MX_MKNIX_H
#define NIX_MX_MKNIX_H

#include "mex.h"
#include <nix.hpp>
#include "datatypes.h"

void check_arg_type(const mxArray *arr, nix::DataType dtype);

nix::NDSize mx_to_ndsize(const mxArray *arr);

std::vector<std::string> mx_to_strings(const mxArray *arr);

nix::LinkType mx_to_linktype(const mxArray *arr);

std::string mx_to_str(const mxArray *arr);

template<typename T>
T mx_to_num(const mxArray *arr) {
    check_arg_type(arr, nix::to_data_type<T>::value);

    if (mxGetNumberOfElements(arr) < 1) {
        throw std::runtime_error("array empty");
    }

    const void *data = mxGetData(arr);
    T res;
    memcpy(&res, data, sizeof(T));
    return res;
}

template<typename T>
std::vector<T> mx_to_vector(const mxArray *arr) {
    std::vector<T> res;

    void *vp = mxGetData(arr);
    mwSize input_size = mxGetNumberOfElements(arr);

    //TODO: check for size > 0
    res.resize(static_cast<size_t>(input_size));
    memcpy(res.data(), vp, sizeof(T)*res.size());

    /* alternative implementation using loop
    T *pr;
    void *voidp = mxGetData(arr);
    assert(sizeof(pr) == sizeof(voidp));
    memcpy(&pr, &voidp, sizeof(pr));

    mwSize input_size = mxGetNumberOfElements(arr);
    for (mwSize index = 0; index < input_size; index++)  {
    res.push_back(*pr++);
    }
    */

    return res;
}

bool mx_to_bool(const mxArray *arr);

nix::Value mx_to_value_from_scalar(const mxArray *arr);

nix::Value mx_to_value_from_struct(const mxArray *arr);

std::vector<nix::Value> mx_to_values(const mxArray *arr);

#endif
