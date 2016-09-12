#ifndef NIX_MX_DIMENSIONS
#define NIX_MX_DIMENSIONS

#include "arguments.h"

namespace nixdimensions {

    mxArray *describe(const nix::SetDimension &dim);

    mxArray *describe(const nix::SampledDimension &dim);

    mxArray *describe(const nix::RangeDimension &dim);

    void range_axis(const extractor &input, infusor &output);

} // namespace nixdimensions

#endif
