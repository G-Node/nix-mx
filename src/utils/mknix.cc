// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include <map>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "datatypes.h"

// helpers

void check_arg_type(const mxArray *arr, nix::DataType dtype) {
    if (dtype_mex2nix(arr) != dtype) {
        throw std::invalid_argument("wrong type");
    }
}

// extractors

nix::NDSize mx_to_ndsize(const mxArray *arr) {

    size_t m = mxGetM(arr);
    size_t n = mxGetN(arr);

    //if (m != 1 && n != 1)

    size_t k = std::max(n, m);
    nix::NDSize size(k);

    double *data = mxGetPr(arr);
    for (size_t i = 0; i < size.size(); i++) {
        size[i] = static_cast<nix::NDSize::value_type>(data[i]);
    }

    return size;
}

std::vector<std::string> mx_to_strings(const mxArray *arr) {
    /*
    To convert to a string vector we actually expect a cell
    array of strings. It's a logical representation since matlab
    arrays require that elements have equal length.
    */
    std::vector<std::string> res;
    const mxArray *el_ptr;
    if (arr == nullptr) {
      return res;
    }

    mwSize length = mxGetNumberOfElements(arr);
    mwIndex index;

    for (index = 0; index < length; index++)  {
        el_ptr = mxGetCell(arr, index);

        if (!mxIsChar(el_ptr)) {
            throw std::invalid_argument("All elements of a cell array should be of a string type");
        }

        char *tmp = mxArrayToString(el_ptr);
        std::string the_string(tmp);
        res.push_back(the_string);
        mxFree(tmp);
    }

    return res;
}

nix::LinkType mx_to_linktype(const mxArray *arr) {
    const uint8_t link_type = mx_to_num<uint8_t>(arr);
    nix::LinkType retLinkType;

    switch (link_type) {
    case 0: retLinkType = nix::LinkType::Tagged; break;
    case 1: retLinkType = nix::LinkType::Untagged; break;
    case 2: retLinkType = nix::LinkType::Indexed; break;
    default: throw std::invalid_argument("unkown link type");
    }

    return retLinkType;
}

std::string mx_to_str(const mxArray *arr) {
    check_arg_type(arr, nix::DataType::String);

    std::string the_string = mxArrayToString(arr);
    return the_string;
}

bool mx_to_bool(const mxArray *arr) {
    check_arg_type(arr, nix::DataType::Bool);

    const mxLogical *l = mxGetLogicals(arr);
    return l[0];
}

nix::Value mx_to_value_from_scalar(const mxArray *arr) {
    /*
    Assuming arr is a scalar mxArray.
    */
    nix::Value val;

    switch (mxGetClassID(arr)) {
    case mxLOGICAL_CLASS: val.set(mx_to_bool(arr)); break;
    case mxCHAR_CLASS: val.set(mx_to_str(arr)); break;
    case mxDOUBLE_CLASS: val.set(mx_to_num<double>(arr)); break;
    case mxUINT32_CLASS: val.set(mx_to_num<uint32_t>(arr)); break;
    case mxINT32_CLASS:  val.set(mx_to_num<int32_t>(arr)); break;
    case mxUINT64_CLASS: val.set(mx_to_num<uint64_t>(arr)); break;
    case mxINT64_CLASS:  val.set(mx_to_num<int64_t>(arr)); break;

    case mxSINGLE_CLASS: throw std::invalid_argument("Element type is not supported");
    case mxUINT8_CLASS:  throw std::invalid_argument("Element type is not supported");
    case mxINT8_CLASS:   throw std::invalid_argument("Element type is not supported");
    case mxUINT16_CLASS: throw std::invalid_argument("Element type is not supported");
    case mxINT16_CLASS:  throw std::invalid_argument("Element type is not supported");

    default: throw std::invalid_argument("Element type is not recognized");
    }

    return val;
}

nix::Value mx_to_value_from_struct(const mxArray *arr) {
    /*
    Assuming arr is a struct mxArray.
    */
    static std::map<std::string, int> arg_map = {
        { "value", 0 },
        { "uncertainty", 1 },
        { "checksum", 2 },
        { "encoder", 3 },
        { "filename", 4 },
        { "reference", 5 }
    };

    nix::Value val;

    int number_of_fields = mxGetNumberOfFields(arr);
    for (int idx = 0; idx < number_of_fields; idx++)  {
        const char  *field_name = mxGetFieldNameByNumber(arr, idx);
        const mxArray *field_array_ptr = mxGetFieldByNumber(arr, 0, idx);

        std::string arg_name = field_name;
        switch (arg_map[arg_name]) {
        case 0: val = mx_to_value_from_scalar(field_array_ptr); break;
        case 1: val.uncertainty = mx_to_num<double>(field_array_ptr); break;
        case 2: val.checksum = mx_to_str(field_array_ptr); break;
        case 3: val.encoder = mx_to_str(field_array_ptr); break;
        case 4: val.filename = mx_to_str(field_array_ptr); break;
        case 5: val.reference = mx_to_str(field_array_ptr); break;
        default: throw std::invalid_argument(std::string("Field is not supported: ") + std::string(field_name));
        }
    }

    return val;
}

std::vector<nix::Value> mx_to_values(const mxArray *arr) {
    /*
    To convert to a vector of Values we actually expect either
    - a cell array with scalar values, or
    - a cell array with structs each having Value attrs
    (uncertainty, checksum etc.) as fields
    */
    std::vector<nix::Value> vals;
    const mxArray *cell_element_ptr;

    if (mxGetClassID(arr) == mxCELL_CLASS) {

        mwSize size = mxGetNumberOfElements(arr);
        for (mwIndex index = 0; index < size; index++)  {
            cell_element_ptr = mxGetCell(arr, index);

            if (mxGetClassID(cell_element_ptr) == mxSTRUCT_CLASS) {
                // assume values are given as matlab structs
                vals.push_back(mx_to_value_from_struct(cell_element_ptr));
            } else {
                // assume just a scalar value given
                vals.push_back(mx_to_value_from_scalar(cell_element_ptr));
            }
        }
    } else {
        throw std::invalid_argument("Values must be given as cell array");
    }

    return vals;
}
