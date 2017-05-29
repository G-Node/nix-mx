// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixgroup.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixgroup {

    mxArray *describe(const nix::Group &group) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });

        sb.set(group.id());
        sb.set(group.type());
        sb.set(group.name());
        sb.set(group.definition());

        return sb.array();
    }
    
    void addDataArray(const extractor &input, infusor &output) {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addDataArray(input.str(2));
    }

    void addSource(const extractor &input, infusor & output) {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addSource(input.str(2));
    }

    void addTag(const extractor &input, infusor &output) {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addTag(input.str(2));
    }

    void addMultiTag(const extractor &input, infusor &output) {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addMultiTag(input.str(2));
    }

} // namespace nixgroup
