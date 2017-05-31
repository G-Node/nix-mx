// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixdataarray.h"
#include "mkarray.h"
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "mknix.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "label",
            "shape", "unit", "polynom_coefficients" });

        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.label());
        sb.set(da.dataExtent());
        sb.set(da.unit());
        sb.set(da.polynomCoefficients());

        return sb.array();
    }

    void addSource(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        currObj.addSource(input.str(2));
    }

    void removeSource(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        output.set(0, currObj.removeSource(input.str(2)));
    }

    void hasSource(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        output.set(0, currObj.hasSource(input.str(2)));
    }

    void getSource(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        output.set(0, currObj.getSource(input.str(2)));
    }

    void sourceCount(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        output.set(0, currObj.sourceCount());
    }

    void readAll(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        mxArray *data = make_mx_array_from_ds(da);
        output.set(0, data);
    }

    void writeAll(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        nix::DataType dtype = input.dtype(2);

        const mxArray *arr = input.get_mx_array(2);

        mwSize ndims = mxGetNumberOfDimensions(arr);
        const mwSize *dims = mxGetDimensions(arr);
        
        mwSize tmp = ndims;
        
        // Quick fix for writing data arrays that have exactly one row.
        // This fix does not resolve more complex arrays that have a 
        // last dimension of exactly one row.
        if (dims[ndims-1] == 1) {
            ndims--;
        }
        nix::NDSize count(ndims);

        for (mwSize i = 0; i < ndims; i++) {
            count[(ndims - i) - 1] = static_cast<nix::ndsize_t>(dims[i]);
        }

        nix::NDSize offset(count.size(), 0);
        double *ptr = input.get_raw(2);
        
        if (dtype == nix::DataType::String) {
            throw std::domain_error("Writing Strings to DataArrays is not supported as of yet.");
        } else {
            da.setData(dtype, ptr, count, offset);
        }
    }

    void deleteDimensions(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);

        bool res = da.deleteDimensions();

        output.set(0, res);
    }

    void dimensionCount(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        output.set(0, da.dimensionCount());
    }

} // namespace nixdataarray
