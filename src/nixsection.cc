// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixsection.h"

#include "mex.h"
#include <nix.hpp>

#include "arguments.h"
#include "filters.h"
#include "handle.h"
#include "mknix.h"
#include "struct.h"

namespace nixsection {

    mxArray *describe(const nix::Section &section) {
        struct_builder sb({ 1 }, { 
            "name", "id", "type", "definition", "repository", "mapping"
        });

        sb.set(section.name());
        sb.set(section.id());
        sb.set(section.type());
        sb.set(section.definition());
        sb.set(section.repository());
        sb.set(section.mapping());

        return sb.array();
    }

    void properties(const extractor &input, infusor &output) {
        nix::Section section = input.entity<nix::Section>(1);
        std::vector<nix::Property> properties = section.properties();

        const mwSize size = static_cast<mwSize>(properties.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < properties.size(); i++) {

            nix::Property pr = properties[i];
            std::vector<nix::Value> values = pr.values();

            mxArray *mx_values = make_mx_array(values);

            struct_builder sb({ 1 }, {
                "name", "id", "definition", "mapping", "unit", "values"
            });

            sb.set(pr.name());
            sb.set(pr.id());
            sb.set(pr.definition());
            sb.set(pr.mapping());
            sb.set(pr.unit());
            sb.set(mx_values);

            mxSetCell(lst, i, sb.array());
        }

        output.set(0, lst);
    }

    void createProperty(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);

        nix::DataType dtype = nix::string_to_data_type(input.str(3));

        nix::Property p = currObj.createProperty(input.str(2), dtype);
        output.set(0, handle(p));
    }

    void createPropertyWithValue(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);

        std::vector<nix::Value> vals = input.vec(3);
        nix::Property p = currObj.createProperty(input.str(2), vals);
        output.set(0, handle(p));
    }

    void referringBlockSources(const extractor &input, infusor &output) {
        nix::Section currSec = input.entity<nix::Section>(1);
        nix::Block currBlock = input.entity<nix::Block>(2);
        output.set(0, currSec.referringSources(currBlock));
    }

    void referringBlockTags(const extractor &input, infusor &output) {
        nix::Section currSec = input.entity<nix::Section>(1);
        nix::Block currBlock = input.entity<nix::Block>(2);
        output.set(0, currSec.referringTags(currBlock));
    }

    void referringBlockMultiTags(const extractor &input, infusor &output) {
        nix::Section currSec = input.entity<nix::Section>(1);
        nix::Block currBlock = input.entity<nix::Block>(2);
        output.set(0, currSec.referringMultiTags(currBlock));
    }

    void referringBlockDataArrays(const extractor &input, infusor &output) {
        nix::Section currSec = input.entity<nix::Section>(1);
        nix::Block currBlock = input.entity<nix::Block>(2);
        output.set(0, currSec.referringDataArrays(currBlock));
    }

    void openSectionIdx(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSection(idx));
    }

    void openPropertyIdx(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getProperty(idx));
    }

    void compare(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);
        nix::Section other = input.entity<nix::Section>(2);
        output.set(0, currObj.compare(other));
    }

    void sectionsFiltered(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);
        std::vector<nix::Section> res = filterNameTypeEntity<nix::Section>(input,
                                            [currObj](const nix::util::Filter<nix::Section>::type &filter) {
            return currObj.sections(filter);
        });
        output.set(0, res);
    }

    void propertiesFiltered(const extractor &input, infusor &output) {
        nix::Section currObj = input.entity<nix::Section>(1);
        std::vector<nix::Property> res = filterNamedEntity<nix::Property>(input,
                                            [currObj](const nix::util::Filter<nix::Property>::type &filter) {
            return currObj.properties(filter);
        });
        output.set(0, res);
    }

} // namespace nixsection
