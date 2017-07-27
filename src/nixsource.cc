// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixsource.h"

#include "mex.h"

#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "struct.h"

namespace nixsource {

    mxArray *describe(const nix::Source &source) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });
        sb.set(source.id());
        sb.set(source.type());
        sb.set(source.name());
        sb.set(source.definition());
        return sb.array();
    }

    void openSourceIdx(const extractor &input, infusor &output) {
        nix::Source currObj = input.entity<nix::Source>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSource(idx));
    }

    void compare(const extractor &input, infusor &output) {
        nix::Source currObj = input.entity<nix::Source>(1);
        nix::Source other = input.entity<nix::Source>(2);
        output.set(0, currObj.compare(other));
    }

    void sourcesFiltered(const extractor &input, infusor &output) {
        nix::Source currObj = input.entity<nix::Source>(1);
        std::vector<nix::Source> res = filterFullEntity<nix::Source>(input,
                                            [currObj](const nix::util::Filter<nix::Source>::type &filter) {
            return currObj.sources(filter);
        });
        output.set(0, res);
    }

} // namespace nixsource
