#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

#include "MXFile.h"
#include "MXBlock.h"
#include "MXDataArray.h"
#include "MXSource.h"
#include "MXFeature.h"
#include "MXTag.h"

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    mexPrintf("[+] entity_destroy\n");
    handle h = input.hdl(1);
    h.destroy();
}

// handle open data array
static handle gen_open_data_array(nix::DataArray inDa){
    nix::DataArray da = inDa;
    handle h = handle(da);
    return h;
}

static void multi_tag_open_references(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_references\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_data_array(currMTag.getReference(input.str(2))));
}

static void multi_tag_open_positions(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_positions\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_data_array(currMTag.positions()));
}

static void multi_tag_open_extents(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_extents\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_data_array(currMTag.extents()));
}

// handle list data arrays
static mxArray* gen_list_data_arrays(std::vector<nix::DataArray> daIn){
    std::vector<nix::DataArray> arr = daIn;

    struct_builder sb({ arr.size() }, { "id", "type", "name" });

    for (const auto &da : arr) {
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());

        sb.next();
    }
    return sb.array();
}

static void multi_tag_list_references_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_list_references\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_list_data_arrays(currMTag.references()));
}



static mxArray* gen_has_entity(bool boolIn, std::vector<const char *> currLabel){
    uint8_t currHas = boolIn ? 1 : 0;
    struct_builder sb({ 1 }, currLabel);
    sb.set(currHas);
    return sb.array();
}

static void multi_tag_has_positions(const extractor &input, infusor &output){
    mexPrintf("[+] multi_tag_has_positions\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_has_entity(currMTag.hasPositions(), { "hasPositions" }));
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

// handle list features
static mxArray* gen_list_features(std::vector<nix::Feature> featIn){
    std::vector<nix::Feature> arr = featIn;
    struct_builder sb({ arr.size() }, { "id" });
    for (const auto &da : arr) {
        sb.set(da.id());
        sb.next();
    }
    return sb.array();
}

static void multi_tag_list_features(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_list_features\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_list_features(currMTag.features()));
}


// handle list sources
static mxArray* gen_list_sources(std::vector<nix::Source> sourceIn){
    std::vector<nix::Source> arr = sourceIn;
    struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "sourceCount" });
    for (const auto &da : arr) {
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.sourceCount());
        sb.next();
    }
    return sb.array();
}

static void multi_tag_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_list_sources\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_list_sources(currMTag.sources()));
}


// handling open sources
static handle gen_open_source(nix::Source sourceIn){
    nix::Source currSource = sourceIn;
    handle currSourceHandle = handle(currSource);
    return currSourceHandle;
}

static void multi_tag_open_source(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_source\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_source(currMTag.getSource(input.str(2))));
}


// handling open features
static handle gen_open_feature(nix::Feature featIn){
    nix::Feature currFeat = featIn;
    handle currTagFeatHandle = handle(currFeat);
    return currTagFeatHandle;
}

static void multi_tag_open_features(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_features\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_feature(currMTag.getFeature(input.str(2))));
}


// handle open metadata section
static handle gen_open_metadata_section(nix::Section secIn){
    nix::Section currMDSec = secIn;
    handle currTagMDSecHandle = handle(currMDSec);
    return currTagMDSecHandle;
}

static void multi_tag_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_metadata_section\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_metadata_section(currMTag.metadata()));
}


// handle multi tag entity
static void multi_tag_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_describe\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);

    struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units", "featureCount", "sourceCount", "referenceCount" });
    sb.set(currMTag.id());
    sb.set(currMTag.type());
    sb.set(currMTag.name());
    sb.set(currMTag.definition());
    sb.set(currMTag.units());
    sb.set(currMTag.featureCount());
    sb.set(currMTag.sourceCount());
    sb.set(currMTag.referenceCount());

    output.set(0, sb.array());
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
        { "DataArray::describe", nixda::describe },
        { "DataArray::readAll", nixda::read_all },
        { "DataArray::openMetadataSection", nixda::open_metadata_section },
        { "Tag::describe", nixtag::describe },
        { "Tag::listReferences", nixtag::list_references_array },
        { "Tag::listFeatures", nixtag::list_features },
        { "Tag::listSources", nixtag::list_sources },
        { "Tag::openReferenceDataArray", nixtag::open_data_array },
        { "Tag::openFeature", nixtag::open_feature },
        { "Tag::openSource", nixtag::open_source },
        { "Tag::openMetadataSection", nixtag::open_metadata_section },
        {"MultiTag::describe", multi_tag_describe},
        {"MultiTag::listReferences", multi_tag_list_references_array},
        {"MultiTag::listFeatures", multi_tag_list_features},
        {"MultiTag::listSources", multi_tag_list_sources},
        {"MultiTag::hasPositions", multi_tag_has_positions},
        {"MultiTag::openPositions", multi_tag_open_positions},
        {"MultiTag::openExtents", multi_tag_open_extents},
        {"MultiTag::openReferences", multi_tag_open_references},
        {"MultiTag::openFeature", multi_tag_open_features},
        {"MultiTag::openSource", multi_tag_open_source},
        {"MultiTag::openMetadataSection", multi_tag_open_metadata_section},
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

    mexPrintf("[F] %s\n", cmd.c_str());

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

