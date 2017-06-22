// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include "nixfile.h"

#include "mex.h"

#include <nix.hpp>
#include <nix/valid/validate.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

// helper function
mxArray *message(std::vector<nix::valid::Message> mes) {
    const mwSize size = static_cast<mwSize>(mes.size());
    mxArray *list = mxCreateCellArray(1, &size);

    for (size_t i = 0; i < mes.size(); i++) {

        nix::valid::Message curr = mes[i];

        struct_builder msb({ 1 }, { "id", "msg" });
        msb.set(curr.id);
        msb.set(curr.msg);

        mxSetCell(list, i, msb.array());
    }

    return list;
}

namespace nixfile {

    void open(const extractor &input, infusor &output) {
        std::string name = input.str(1);
        uint8_t omode = input.num<uint8_t>(2);
        nix::FileMode mode;

        switch (omode) {
        case 0: mode = nix::FileMode::ReadOnly; break;
        case 1: mode = nix::FileMode::ReadWrite; break;
        case 2: mode = nix::FileMode::Overwrite; break;
        default: throw std::invalid_argument("unkown open mode");
        }

        nix::File fn = nix::File::open(name, mode);
        handle h = handle(fn);

        output.set(0, h);
    }

    void fileMode(const extractor &input, infusor &output) {
        nix::File currObj = input.entity<nix::File>(1);
        nix::FileMode mode = currObj.fileMode();
        uint8_t omode;

        switch (mode) {
        case nix::FileMode::ReadOnly: omode = 0; break;
        case nix::FileMode::ReadWrite: omode = 1; break;
        case nix::FileMode::Overwrite: omode = 2; break;
        default: throw std::invalid_argument("unknown open mode");
        }

        output.set(0, omode);
    }

    void validate(const extractor &input, infusor &output) {
        nix::File f = input.entity<nix::File>(1);
        nix::valid::Result res = f.validate();

        std::vector<nix::valid::Message> err = res.getErrors();
        mxArray *err_list = message(err);

        std::vector<nix::valid::Message> warn = res.getWarnings();
        mxArray *warn_list = message(warn);

        struct_builder sb({ 1 }, { "ok", "hasErrors", "hasWarnings", "errors", "warnings" });
        sb.set(res.ok());
        sb.set(res.hasErrors());
        sb.set(res.hasWarnings());
        sb.set(err_list);
        sb.set(warn_list);

        output.set(0, sb.array());
    }

    mxArray *describe(const nix::File &fd) {
        struct_builder sb({ 1 }, { "format", "version", "location", "createdAt", "updatedAt" });
        sb.set(fd.format());
        sb.set(fd.version());
        sb.set(fd.location());
        sb.set(static_cast<uint64_t>(fd.createdAt()));
        sb.set(static_cast<uint64_t>(fd.updatedAt()));
        return sb.array();
    }

    void openBlockIdx(const extractor &input, infusor &output) {
        nix::File currObj = input.entity<nix::File>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getBlock(idx));
    }

    void openSectionIdx(const extractor &input, infusor &output) {
        nix::File currObj = input.entity<nix::File>(1);
        nix::ndsize_t idx = (nix::ndsize_t)input.num<double>(2);
        output.set(0, currObj.getSection(idx));
    }

} // namespace nixfile
