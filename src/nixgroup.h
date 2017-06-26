// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_GROUP
#define NIX_MX_GROUP

#include "arguments.h"

namespace nixgroup {

    mxArray *describe(const nix::Group &group);

    void addDataArray(const extractor &input, infusor &output);

    void addDataArrays(const extractor &input, infusor &output);

    void addSource(const extractor &input, infusor & output);

    void addSources(const extractor &input, infusor & output);

    void addTag(const extractor &input, infusor &output);

    void addTags(const extractor &input, infusor &output);

    void addMultiTag(const extractor &input, infusor &output);

    void addMultiTags(const extractor &input, infusor &output);

    void openDataArrayIdx(const extractor &input, infusor &output);

    void openTagIdx(const extractor &input, infusor &output);

    void openMultiTagIdx(const extractor &input, infusor &output);

    void openSourceIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

    void sourcesFiltered(const extractor &input, infusor &output);

} // namespace nixgroup

#endif
