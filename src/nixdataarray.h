// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_DATAARRAY
#define NIX_MX_DATAARRAY

#include "arguments.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da);

    void addSource(const extractor &input, infusor &output);

    void addSources(const extractor &input, infusor &output);

    void removeSource(const extractor &input, infusor &output);

    void hasSource(const extractor &input, infusor &output);

    void getSource(const extractor &input, infusor &output);

    void sourceCount(const extractor &input, infusor &output);

    void readAll(const extractor &input, infusor &output);

    void writeAll(const extractor &input, infusor &output);

    void deleteDimensions(const extractor &input, infusor &output);

    void dimensionCount(const extractor &input, infusor &output);

    void polynomCoefficients(const extractor &input, infusor &output);

    void dataType(const extractor &input, infusor &output);

    void setDataExtent(const extractor &input, infusor &output);

    void openSourceIdx(const extractor &input, infusor &output);

    void openDimensionIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

} // namespace nixdataarray

#endif
