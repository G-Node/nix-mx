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

    void create_data_array(const extractor &input, infusor &output);

    void create_multi_tag(const extractor &input, infusor &output);

    void create_group(const extractor &input, infusor &output);

} // namespace nixblock

#endif
