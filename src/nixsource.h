// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_SOURCE
#define NIX_MX_SOURCE

#include "arguments.h"

namespace nixsource {

    mxArray *describe(const nix::Source &source);

    void openSourceIdx(const extractor &input, infusor &output);

    void compare(const extractor &input, infusor &output);

    void sourcesFiltered(const extractor &input, infusor &output);

    void findSources(const extractor &input, infusor &output);

} // namespace nixsource

#endif
