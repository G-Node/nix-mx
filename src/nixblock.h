// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_BLOCK
#define NIX_MX_BLOCK

#include "arguments.h"

namespace nixblock {

    mxArray *describe(const nix::Block &block);

    void createDataArray(const extractor &input, infusor &output);

    void createMultiTag(const extractor &input, infusor &output);

    void createGroup(const extractor &input, infusor &output);

    void openGroupIdx(const extractor &input, infusor &output);

    void openDataArrayIdx(const extractor &input, infusor &output);

    void openTagIdx(const extractor &input, infusor &output);

    void openMultiTagIdx(const extractor &input, infusor &output);

    void openSourceIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

    void sourcesFiltered(const extractor &input, infusor &output);

    void tagsFiltered(const extractor &input, infusor &output);

} // namespace nixblock

#endif
