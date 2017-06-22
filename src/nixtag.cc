// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixtag.h"
#include "mkarray.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixtag {

    mxArray *describe(const nix::Tag &tag) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "extent", "units" });

        sb.set(tag.id());
        sb.set(tag.type());
        sb.set(tag.name());
        sb.set(tag.definition());
        sb.set(tag.position());
        sb.set(tag.extent());
        sb.set(tag.units());

        return sb.array();
    }

    void addReference(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        currObj.addReference(input.str(2));
    }

    void addReferences(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        std::vector<nix::DataArray> curr = input.entity_vec<nix::DataArray>(2);
        currObj.references(curr);
    }

    void addSource(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        currObj.addSource(input.str(2));
    }

    void addSources(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        std::vector<nix::Source> curr = input.entity_vec<nix::Source>(2);
        currObj.sources(curr);
    }

    void createFeature(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);

        nix::Feature newFeat = currObj.createFeature(input.str(2), input.ltype(3));
        output.set(0, handle(newFeat));
    }

    void retrieveData(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        double index = input.num<double>(2);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveData(index));
        output.set(0, data);
    }

    void retrieveFeatureData(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        double index = input.num<double>(2);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveFeatureData(index));
        output.set(0, data);
    }

    void openReferenceIdx(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getReference(idx));
    }

    void openFeatureIdx(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getFeature(idx));
    }

    void openSourceIdx(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSource(idx));
    }

    void compare(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        nix::Tag other = input.entity<nix::Tag>(2);
        output.set(0, currObj.compare(other));
    }

} // namespace nixtag
