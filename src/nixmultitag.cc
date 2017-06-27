// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixmultitag.h"

#include "mex.h"

#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "mkarray.h"
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

    void addReferences(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::DataArray> curr = input.entity_vec<nix::DataArray>(2);
        currObj.references(curr);
    }

    void addSource(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.addSource(input.str(2));
    }

    void addSources(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::Source> curr = input.entity_vec<nix::Source>(2);
        currObj.sources(curr);
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

    void openReferenceIdx(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getReference(idx));
    }

    void openFeatureIdx(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getFeature(idx));
    }

    void openSourceIdx(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSource(idx));
    }

    void compare(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        nix::MultiTag other = input.entity<nix::MultiTag>(2);
        output.set(0, currObj.compare(other));
    }

    void sourcesFiltered(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::Source> res = filterEntity<nix::Source>(input,
                                            [currObj](const nix::util::Filter<nix::Source>::type &filter) {
            return currObj.sources(filter);
        });
        output.set(0, res);
    }

    void referencesFiltered(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::DataArray> res = filterEntity<nix::DataArray>(input,
                                                [currObj](const nix::util::Filter<nix::DataArray>::type &filter) {
            return currObj.references(filter);
        });
        output.set(0, res);
    }

    void featuresFiltered(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::Feature> res = filterFeature<nix::Feature>(input,
                                            [currObj](const nix::util::Filter<nix::Feature>::type &filter) {
            return currObj.features(filter);
        });
        output.set(0, res);
    }

} // namespace nixmultitag
