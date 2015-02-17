#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"


mxArray* has_entity(bool boolIn, std::vector<const char *> currLabel){
    uint8_t currHas = boolIn ? 1 : 0;
    struct_builder sb({ 1 }, currLabel);
    sb.set(currHas);
    return sb.array();
}

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

/*
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
*/
