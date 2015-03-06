#ifndef NIX_MX_NIX2MX_H
#define NIX_MX_NIX2MX_H

#include "mex.h"
#include <nix.hpp>

nix::NDSize mx_array_to_ndsize(const mxArray *arr);

mxArray *nmCreateScalar(uint32_t val);

mxArray *dim_to_struct(nix::SetDimension dim);

mxArray *dim_to_struct(nix::SampledDimension dim);

mxArray *dim_to_struct(nix::RangeDimension dim);

#endif