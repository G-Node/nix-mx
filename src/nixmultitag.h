// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_MULTITAG
#define NIX_MX_MULTITAG

#include "arguments.h"

namespace nixmultitag {

    mxArray *describe(const nix::MultiTag &multitag);

    void addReference(const extractor &input, infusor &output);

    void addSource(const extractor &input, infusor &output);

    void createFeature(const extractor &input, infusor &output);

    void retrieveData(const extractor &input, infusor &output);

    void retrieveFeatureData(const extractor &input, infusor &output);

    void addPositions(const extractor &input, infusor &output);

} // namespace nixmultitag

#endif
