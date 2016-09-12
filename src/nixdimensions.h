#ifndef NIX_MX_DIMENSIONS
#define NIX_MX_DIMENSIONS

#include "arguments.h"

namespace nixdimensions {

    mxArray *describe(const nix::SetDimension &dim);

    mxArray *describe(const nix::SampledDimension &dim);

    mxArray *describe(const nix::RangeDimension &dim);

    void sampled_axis(const extractor &input, infusor &output);

    void range_tick_at(const extractor &input, infusor &output);

    void range_axis(const extractor &input, infusor &output);

} // namespace nixdimensions

#endif
