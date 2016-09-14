// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_FEATURE
#define NIX_MX_FEATURE

#include "arguments.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat);

    void setLinkType(const extractor &input, infusor &output);

} // namespace nixfeature

#endif
