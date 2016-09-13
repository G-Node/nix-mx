// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixmultitag.h"
#include "mkarray.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixmultitag {

    mxArray *describe(const nix::MultiTag &multitag) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units" });

        sb.set(multitag.id());
        sb.set(multitag.type());
        sb.set(multitag.name());
        sb.set(multitag.definition());
        sb.set(multitag.units());

        return sb.array();
    }

    void addReference(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.addReference(input.str(2));
    }

    void addSource(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.addSource(input.str(2));
    }

    void createFeature(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);

        nix::Feature newFeat = currObj.createFeature(input.str(2), input.ltype(3));
        output.set(0, handle(newFeat));
    }

    void retrieveData(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveData(p_index, f_index));
        output.set(0, data);
    }

    void retrieveFeatureData(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveFeatureData(p_index, f_index));
        output.set(0, data);
    }

    void addPositions(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.positions(input.str(2));
    }

} // namespace nixmultitag
