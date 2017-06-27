// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_TAG
#define NIX_MX_TAG

#include "arguments.h"

namespace nixtag {

    mxArray *describe(const nix::Tag &tag);

    void addReference(const extractor &input, infusor &output);

    void addReferences(const extractor &input, infusor &output);

    void addSource(const extractor &input, infusor &output);

    void addSources(const extractor &input, infusor &output);

    void createFeature(const extractor &input, infusor &output);

    void retrieveData(const extractor &input, infusor &output);

    void retrieveFeatureData(const extractor &input, infusor &output);

} // namespace nixtag

#endif
