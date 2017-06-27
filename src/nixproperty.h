// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_PROPERTY
#define NIX_MX_PROPERTY

#include "arguments.h"

namespace nixproperty {

    mxArray *describe(const nix::Property &prop);

    void values(const extractor &input, infusor &output);

    void updateValues(const extractor &input, infusor &output);

    void deleteValues(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

} // namespace nixproperty

#endif
