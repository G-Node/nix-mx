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

#include "handle.h"
#include "arguments.h"
#include "struct.h"

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

    mxArray *describe(const nix::File &fd) {
        struct_builder sb({ 1 }, { "format", "version", "location", "createdAt", "updatedAt" });
        sb.set(fd.format());
        sb.set(fd.version());
        sb.set(fd.location());
        sb.set(static_cast<uint64_t>(fd.createdAt()));
        sb.set(static_cast<uint64_t>(fd.updatedAt()));
        return sb.array();
    }

} // namespace nixfile
