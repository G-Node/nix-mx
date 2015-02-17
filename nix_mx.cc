#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

#include "nixfile.h"
#include "nixblock.h"
#include "nixdataarray.h"
#include "nixsource.h"
#include "nixfeature.h"
#include "nixtag.h"
#include "nixmultitag.h"

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    handle h = input.hdl(1);
    h.destroy();
}

static nix::NDSize mx_array_to_ndsize(const mxArray *arr) {

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

static mxArray *nmCreateScalar(uint32_t val) {
    mxArray *arr = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    void *data = mxGetData(arr);
    memcpy(data, &val, sizeof(uint32_t));
    return arr;
}


// *** ***

typedef void (*fn_t)(const extractor &input, infusor &output);

struct fendpoint {

fendpoint(std::string name, fn_t fn) : name(name), fn(fn) {}

    std::string name;
    fn_t fn;
};

const std::vector<fendpoint> funcs = {
        { "Entity::destroy", entity_destroy },
        { "File::open", nixfile::open },
        { "File::describe", nixfile::describe },
        { "File::listBlocks", nixfile::list_blocks },
        { "File::openBlock", nixfile::open_block },
        { "File::listSections", nixfile::list_sections },
        { "File::openSection", nixfile::open_section },
        { "Block::describe", nixblock::describe },
        { "Block::listDataArrays", nixblock::list_data_arrays },
        { "Block::openDataArray", nixblock::open_data_array },
        { "Block::listSources", nixblock::list_sources },
        { "Block::openSource", nixblock::open_source },
        { "Block::hasTag", nixblock::has_tag },
        { "Block::listTags", nixblock::list_tags },
        { "Block::openTag", nixblock::open_tag },
        { "Block::hasMultiTag", nixblock::has_multi_tag },
        { "Block::listMultiTags", nixblock::list_multi_tags },
        { "Block::openMultiTag", nixblock::open_multi_tag },
        { "Block::openMetadataSection", nixblock::open_metadata_section },
        { "DataArray::describe", nixdataarray::describe },
        { "DataArray::readAll", nixdataarray::read_all },
        { "DataArray::openMetadataSection", nixdataarray::open_metadata_section },
        { "Tag::describe", nixtag::describe },
        { "Tag::listReferences", nixtag::list_references_array },
        { "Tag::listFeatures", nixtag::list_features },
        { "Tag::listSources", nixtag::list_sources },
        { "Tag::openReferenceDataArray", nixtag::open_data_array },
        { "Tag::openFeature", nixtag::open_feature },
        { "Tag::openSource", nixtag::open_source },
        { "Tag::openMetadataSection", nixtag::open_metadata_section },
        { "MultiTag::describe", nixmultitag::describe },
        { "MultiTag::listReferences", nixmultitag::list_references_array },
        { "MultiTag::listFeatures", nixmultitag::list_features },
        { "MultiTag::listSources", nixmultitag::list_sources },
        { "MultiTag::hasPositions", nixmultitag::has_positions },
        { "MultiTag::openPositions", nixmultitag::open_positions },
        { "MultiTag::openExtents", nixmultitag::open_extents },
        { "MultiTag::openReferences", nixmultitag::open_references },
        { "MultiTag::openFeature", nixmultitag::open_features },
        { "MultiTag::openSource", nixmultitag::open_source },
        { "MultiTag::openMetadataSection", nixmultitag::open_metadata_section },
        { "Source::describe", nixsource::describe },
        { "Source::listSources", nixsource::list_sources },
        { "Source::openSource", nixsource::open_source },
        { "Source::openMetadataSection", nixsource::open_metadata_section },
        { "Feature::describe", nixfeature::describe },
        { "Feature::linkType", nixfeature::link_type },
        { "Feature::openData", nixfeature::open_data }
};

// main entry point
void mexFunction(int            nlhs,
                 mxArray       *lhs[],
                 int            nrhs,
                 const mxArray *rhs[])
{
    extractor input(rhs, nrhs);
    infusor   output(lhs, nlhs);

    std::string cmd = input.str(0);

    //mexPrintf("[F] %s\n", cmd.c_str());

    bool processed = false;
    for (const auto &fn : funcs) {
        if (fn.name == cmd) {
            try {
                fn.fn(input, output);
            } catch (const std::invalid_argument &e) {
                mexErrMsgIdAndTxt("nix:arg:inval", e.what());
            } catch (const std::exception &e) {
                mexErrMsgIdAndTxt("nix:arg:dispatch", e.what());
            } catch (...) {
                mexErrMsgIdAndTxt("nix:arg:dispatch", "unkown exception");
            }
            processed = true;
            break;
        }
    }

    if (!processed) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "Unkown command");
    }
}

