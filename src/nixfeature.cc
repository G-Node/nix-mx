// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixfeature.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat) {
        struct_builder sb({ 1 }, { "id", "linkType" });
        sb.set(feat.id());
        sb.set(feat.linkType());
        return sb.array();
    }

    void setLinkType(const extractor &input, infusor &output) {
        nix::Feature feat = input.entity<nix::Feature>(1);

        feat.linkType(input.ltype(2));
    }

} // namespace nixfeature
