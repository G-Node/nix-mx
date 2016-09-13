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

    void add_source(const extractor &input, infusor &output);

    void remove_source(const extractor &input, infusor &output);

    void read_all(const extractor &input, infusor &output);

    void write_all(const extractor &input, infusor &output);

    void delete_dimensions(const extractor &input, infusor &output);

} // namespace nixdataarray

#endif
