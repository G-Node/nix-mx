// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_DIMENSIONS
#define NIX_MX_DIMENSIONS

#include "arguments.h"

namespace nixdimensions {

    mxArray *describe(const nix::SetDimension &dim);

    mxArray *describe(const nix::SampledDimension &dim);

    mxArray *describe(const nix::RangeDimension &dim);

    void sampledPositionAt(const extractor &input, infusor &output);

    void sampledAxis(const extractor &input, infusor &output);

    void sampledIndexOf(const extractor &input, infusor &output);

    void rangeTickAt(const extractor &input, infusor &output);

    void rangeAxis(const extractor &input, infusor &output);

    void rangeIndexOf(const extractor &input, infusor &output);


} // namespace nixdimensions

#endif
