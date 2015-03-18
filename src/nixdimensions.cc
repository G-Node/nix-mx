#include "nixtag.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixdimensions {

    mxArray *describe(const nix::SetDimension &dim)
    {
        struct_builder sb({ 1 }, { "dim_type", "labels" });

        sb.set(dim.dimensionType());
        sb.set(dim.labels());

        return sb.array();
    }

    mxArray *describe(const nix::SampledDimension &dim)
    {
        struct_builder sb({ 1 }, { "dim_type", "label", "unit", "sampling_interval", "offset" });

        sb.set(dim.dimensionType());
        sb.set(dim.label());
        sb.set(dim.unit());
        sb.set(dim.samplingInterval());
        sb.set(dim.offset());

        return sb.array();
    }

    mxArray *describe(const nix::RangeDimension &dim)
    {
        struct_builder sb({ 1 }, { "dim_type", "label", "unit", "ticks" });

        sb.set(dim.dimensionType());
        sb.set(dim.label());
        sb.set(dim.unit());
        sb.set(dim.ticks());

        return sb.array();
    }
} // namespace nixtag
