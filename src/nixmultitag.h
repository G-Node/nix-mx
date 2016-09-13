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

    void add_reference(const extractor &input, infusor &output);

    void add_source(const extractor &input, infusor &output);

    void create_feature(const extractor &input, infusor &output);

    void retrieve_data(const extractor &input, infusor &output);

    void retrieve_feature_data(const extractor &input, infusor &output);

    void add_positions(const extractor &input, infusor &output);

} // namespace nixmultitag

#endif
