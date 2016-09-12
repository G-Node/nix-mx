#include <nix.hpp>
#include "mex.h"
#include "arguments.h"
#include "struct.h"

namespace nixdimensions {

    mxArray *describe(const nix::SetDimension &dim)
    {
        struct_builder sb({ 1 }, { "dimensionType", "labels" });

        sb.set(dim.dimensionType());
        sb.set(dim.labels());

        return sb.array();
    }

    mxArray *describe(const nix::SampledDimension &dim)
    {
        struct_builder sb({ 1 }, { "dimensionType", "label", "unit", "samplingInterval", "offset" });

        sb.set(dim.dimensionType());
        sb.set(dim.label());
        sb.set(dim.unit());
        sb.set(dim.samplingInterval());
        sb.set(dim.offset());

        return sb.array();
    }

    mxArray *describe(const nix::RangeDimension &dim)
    {
        struct_builder sb({ 1 }, { "dimensionType", "isAlias", "label", "unit", "ticks" });

        sb.set(dim.dimensionType());
        sb.set(dim.alias());
        sb.set(dim.label());
        sb.set(dim.unit());
        sb.set(dim.ticks());

        return sb.array();
    }

    void sampled_axis(const extractor &input, infusor &output) {
        nix::SampledDimension dim = input.entity<nix::SampledDimension>(1);
        const mwSize count = static_cast<mwSize>(input.num<double>(2));
        const mwSize startIndex = static_cast<mwSize>(input.num<double>(3));

        std::vector<double> a = dim.axis(count, startIndex);
        mxArray *axis = mxCreateDoubleMatrix(1, a.size(), mxREAL);
        std::copy(a.begin(), a.end(), mxGetPr(axis));

        output.set(0, axis);
    }

    void range_tick_at(const extractor &input, infusor &output) {
        nix::RangeDimension dim = input.entity<nix::RangeDimension>(1);
        const mwSize index = static_cast<mwSize>(input.num<double>(2));

        double tick = dim.tickAt(index);
        output.set(0, tick);
    }

    void range_axis(const extractor &input, infusor &output) {
        nix::RangeDimension dim = input.entity<nix::RangeDimension>(1);
        const mwSize count = static_cast<mwSize>(input.num<double>(2));
        const mwSize startIndex = static_cast<mwSize>(input.num<double>(3));

        std::vector<double> a = dim.axis(count, startIndex);
        mxArray *axis = mxCreateDoubleMatrix(1, a.size(), mxREAL);
        std::copy(a.begin(), a.end(), mxGetPr(axis));

        output.set(0, axis);
    }

} // namespace nixdimensions
