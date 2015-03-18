#ifndef NIX_MX_NIX2MX_H
#define NIX_MX_NIX2MX_H

#include "mex.h"
#include <nix.hpp>
#include "datatypes.h"

void check_arg_type(const mxArray *arr, nix::DataType dtype);

nix::NDSize mx_array_to_ndsize(const mxArray *arr);

std::string mx_array_to_str(const mxArray *arr);

template<typename T>
T mx_array_to_num(const mxArray *arr);

bool mx_array_to_bool(const mxArray *arr);

nix::Value mx_array_to_value(const mxArray *arr);

mxArray *nmCreateScalar(uint32_t val);

#endif