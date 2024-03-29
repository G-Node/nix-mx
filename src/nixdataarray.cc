// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixdataarray.h"
#include "nixdimensions.h"

#include "mex.h"

#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "mkarray.h"
#include "mknix.h"
#include "struct.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "label",
            "dataExtent", "unit", "expansionOrigin", "polynomCoefficients" });

        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.label());
        sb.set(da.dataExtent());
        sb.set(da.unit());
        sb.set(da.expansionOrigin());
        sb.set(da.polynomCoefficients());

        return sb.array();
    }

    void addSource(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        currObj.addSource(input.str(2));
    }

    void addSources(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        std::vector<nix::Source> sv = input.entity_vec<nix::Source>(2);
        currObj.sources(sv);
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

    void polynomCoefficients(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        std::vector<double> pc = input.vec<double>(2);
        da.polynomCoefficients(pc);
    }

    void dataType(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        output.set(0, string_nix2mex(da.dataType()));
    }

    void setDataExtent(const extractor &input, infusor &output) {
        nix::DataArray da = input.entity<nix::DataArray>(1);
        nix::NDSize size = input.ndsize(2);
        da.dataExtent(size);
    }

    void openSourceIdx(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSource(idx));
    }

    void openDimensionIdx(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);

        nix::Dimension d = currObj.getDimension(idx);

        struct_builder sb({ 1 }, { "dimensionType", "handle" });

        switch (d.dimensionType()) {
        case nix::DimensionType::Set:
            sb.set("set");
            sb.set(d.asSetDimension());
            break;
        case nix::DimensionType::Sample:
            sb.set("sampled");
            sb.set(d.asSampledDimension());
            break;
        case nix::DimensionType::Range:
            sb.set("range");
            sb.set(d.asRangeDimension());
            break;
        default: throw std::invalid_argument("unkown dimension type");
        }

        output.set(0, sb.array());
    }

    void compare(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        nix::DataArray other = input.entity<nix::DataArray>(2);
        output.set(0, currObj.compare(other));
    }

    void sourcesFiltered(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        std::vector<nix::Source> res = filterFullEntity<nix::Source>(input,
                                            [currObj](const nix::util::Filter<nix::Source>::type &filter) {
            return currObj.sources(filter);
        });
        output.set(0, res);
    }

    void arrayAppendSampledDimension(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        double si = static_cast<double>(input.num<double>(2));
        nix::SampledDimension d = currObj.appendSampledDimension(si);
        output.set(0, d);
    }

    void arrayAppendSetDimension(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        nix::SetDimension d = currObj.appendSetDimension();
        output.set(0, d);
    }

    void arrayAppendRangeDimension(const extractor &input, infusor &output) {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        std::vector<double> ticks = input.vec<double>(2);
        nix::RangeDimension d = currObj.appendRangeDimension(ticks);
        output.set(0, d);
    }
} // namespace nixdataarray
