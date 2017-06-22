// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_FILE
#define NIX_MX_FILE

#include "arguments.h"

namespace nixfile {

    void open(const extractor &input, infusor &output);

    void fileMode(const extractor &input, infusor &output);

    void validate(const extractor &input, infusor &output);

    mxArray *describe(const nix::File &f);

    void openBlockIdx(const extractor &input, infusor &output);

    void openSectionIdx(const extractor &input, infusor &output);

} // namespace nixfile

#endif
