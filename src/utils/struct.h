// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_STRUCT_H
#define NIX_MX_STRUCT_H

#include "mkarray.h"
#include "mex.h"

#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"

// *** datatype converter

struct struct_builder {

    struct_builder(std::vector<size_t> dims, std::vector<const char *> f)
        : n(0), pos(0), fields(f) {

#ifdef HAVE_OCTAVE
        std::vector<mwSize> dims_mw(dims.size());
        int f_size = static_cast<int>(f.size());
        mwSize dims_size = static_cast<mwSize>(dims.size());
        std::transform(dims.cbegin(), dims.cend(), dims_mw.begin(), [](const size_t v){
            return static_cast<mwSize>(v);
        });

        sa = mxCreateStructArray(dims_size, dims_mw.data(), f_size, f.data());
#else
        if (dims.size() > static_cast<size_t>(std::numeric_limits<int>::max())) {
            throw std::invalid_argument(std::string("Dimension size is larger than supported."));
        }
        else if (fields.size() > static_cast<size_t>(std::numeric_limits<int>::max())) {
            throw std::invalid_argument(std::string("Field size is larger than supported."));
        }
        else {
            sa = mxCreateStructArray(static_cast<int>(dims.size()), dims.data(), static_cast<int>(fields.size()), fields.data());
        }
#endif
    }

    template<typename T>
    void set(T&& value) {
        set(pos++, std::forward<T>(value));
    }

    template<typename T>
    void set(const std::string &key, T&& value) {
        mxSetFieldByNumber(sa, n, pos++, std::forward<T>(value));
    }

    template<typename T>
    void set(const int field_idx, T&& value) {
        set(n, field_idx, std::forward<T>(value));
    }

    template<typename T>
    void set(const mwIndex struct_idx, const int field_idx, T&& value) {
        set(struct_idx, field_idx, make_mx_array(std::forward<T>(value)));
    }

    void set(const mwIndex struct_idx, const int field_idx, mxArray *value) {
        mxSetFieldByNumber(sa, struct_idx, field_idx, value);
    }

    mwIndex next() {
        pos = 0;
        return ++n;
    }

    int skip() {
        return ++pos;
    }

    mxArray *array() {
        return sa;
    }

private:
    mxArray *sa;
    mwIndex n;
    int pos;

    std::vector<const char *> fields;
};

#endif
