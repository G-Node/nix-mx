// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixblock.h"

#include "mex.h"

#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "struct.h"

namespace nixblock {

    mxArray *describe(const nix::Block &block) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });

        sb.set(block.id());
        sb.set(block.type());
        sb.set(block.name());
        sb.set(block.definition());

        return sb.array();
    }

    void createDataArray(const extractor &input, infusor &output) {
        nix::Block block = input.entity<nix::Block>(1);

        std::string name = input.str(2);
        std::string type = input.str(3);
        nix::DataType dtype = nix::string_to_data_type(input.str(4));
        nix::NDSize size = input.ndsize(5);

        nix::DataArray dt = block.createDataArray(name, type, dtype, size);
        output.set(0, dt);
    }

    void createMultiTag(const extractor &input, infusor &output) {
        nix::Block block = input.entity<nix::Block>(1);
        std::string name = input.str(2);
        std::string type = input.str(3);
        nix::DataArray positions = block.getDataArray(input.str(4));

        nix::MultiTag mTag = block.createMultiTag(name, type, positions);
        output.set(0, mTag);
    }

    void createGroup(const extractor &input, infusor &output) {
        nix::Block block = input.entity<nix::Block>(1);
        std::string name = input.str(2);
        std::string type = input.str(3);

        nix::Group group = block.createGroup(name, type);
        output.set(0, group);
    }

    void openGroupIdx(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getGroup(idx));
    }

    void openDataArrayIdx(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getDataArray(idx));
    }

    void openTagIdx(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getTag(idx));
    }

    void openMultiTagIdx(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getMultiTag(idx));
    }

    void openSourceIdx(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSource(idx));
    }

    void compare(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        nix::Block other = input.entity<nix::Block>(2);
        output.set(0, currObj.compare(other));
    }

    void sourcesFiltered(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        std::vector<nix::Source> res = filterEntity<nix::Source>(input,
                                            [currObj](const nix::util::Filter<nix::Source>::type &filter) {
            return currObj.sources(filter);
        });
        output.set(0, res);
    }

    void groupsFiltered(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        std::vector<nix::Group> res = filterEntity<nix::Group>(input,
                                            [currObj](const nix::util::Filter<nix::Group>::type &filter) {
            return currObj.groups(filter);
        });
        output.set(0, res);
    }

    void tagsFiltered(const extractor &input, infusor &output) {
        nix::Block currObj = input.entity<nix::Block>(1);
        std::vector<nix::Tag> res = filterEntity<nix::Tag>(input,
                                        [currObj](const nix::util::Filter<nix::Tag>::type &filter) {
            return currObj.tags(filter);
        });
        output.set(0, res);
    }

} // namespace nixblock
