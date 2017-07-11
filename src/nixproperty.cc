// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixproperty.h"
#include "mex.h"
#include "datatypes.h"
#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixproperty {

    mxArray *describe(const nix::Property &prop) {
        struct_builder sb({ 1 }, { "id", "name", "definition", "unit", "mapping", "datatype" });

        sb.set(prop.id());
        sb.set(prop.name());
        sb.set(prop.definition());
        sb.set(prop.unit());
        sb.set(prop.mapping());
        sb.set(string_nix2mex(prop.dataType()));

        return sb.array();
    }

    void values(const extractor &input, infusor &output) {
        nix::Property prop = input.entity<nix::Property>(1);
        std::vector<nix::Value> vals = prop.values();

        const mwSize size = static_cast<mwSize>(vals.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < vals.size(); i++) {

            nix::Value pr = vals[i];

            struct_builder sb({ 1 }, { "value", "uncertainty" });

            sb.set(make_mx_array(pr));
            sb.set(pr.uncertainty);

            mxSetCell(lst, i, sb.array());
        }

        output.set(0, lst);
    }

    void updateValues(const extractor &input, infusor &output) {
        nix::Property prop = input.entity<nix::Property>(1);
        prop.deleteValues();

        std::vector<nix::Value> getVals = input.vec(2);
        prop.values(getVals);
    }

    void deleteValues(const extractor &input, infusor &output) {
        nix::Property prop = input.entity<nix::Property>(1);
        prop.deleteValues();
    }

    void compare(const extractor &input, infusor &output) {
        nix::Property pm = input.entity<nix::Property>(1);
        nix::Property pc = input.entity<nix::Property>(2);
        output.set(0, pm.compare(pc));
    }

} // namespace nixproperty
