// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixtag.h"

#include "mex.h"

#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "mkarray.h"
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

    void sourcesFiltered(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        std::vector<nix::Source> res = filterFullEntity<nix::Source>(input,
                                            [currObj](const nix::util::Filter<nix::Source>::type &filter) {
            return currObj.sources(filter);
        });
        output.set(0, res);
    }

    void referencesFiltered(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        std::vector<nix::DataArray> res = filterFullEntity<nix::DataArray>(input,
                                            [currObj](const nix::util::Filter<nix::DataArray>::type &filter) {
            return currObj.references(filter);
        });
        output.set(0, res);
    }

    void featuresFiltered(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        std::vector<nix::Feature> res = filterEntity<nix::Feature>(input,
                                            [currObj](const nix::util::Filter<nix::Feature>::type &filter) {
            return currObj.features(filter);
        });
        output.set(0, res);
    }

    void retrieveDataIdx(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveData(idx));
        output.set(0, data);
    }

} // namespace nixtag
