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

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    mexPrintf("[+] entity_destroy\n");
    handle h = input.hdl(1);
    h.destroy();
}

static void block_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_describe\n");
    nix::Block block = input.entity<nix::Block>(1);

    struct_builder sb({ 1 }, { "id", "type", "name", "sourceCount", "dataArrayCount", "tagCount", "multiTagCount" });

    sb.set(block.id());
    sb.set(block.type());
    sb.set(block.name());
    sb.set(block.sourceCount());
    sb.set(block.dataArrayCount());
    sb.set(block.tagCount());
    sb.set(block.multiTagCount());

    output.set(0, sb.array());
}


// handle open data array
static handle gen_open_data_array(nix::DataArray inDa){
    nix::DataArray da = inDa;
    handle h = handle(da);
    return h;
}

static void block_open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_data_array\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, gen_open_data_array(block.getDataArray(input.str(2))));
}

static void tag_open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_data_array\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_open_data_array(currTag.getReference(input.str(2))));
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

static void feature_open_data(const extractor &input, infusor &output)
{
    mexPrintf("[+] feature_open_data\n");
    nix::Feature currFeat = input.entity < nix::Feature > (1);
    output.set(0, gen_open_data_array(currFeat.data()));
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

static void block_list_data_arrays(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_list_data_arrays\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, gen_list_data_arrays(block.dataArrays()));
}

static void tag_list_references_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_references\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_list_data_arrays(currTag.references()));
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

static void block_has_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_has_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, gen_has_entity(block.hasTag(input.str(2)), { "hasTag" }));
}

static void block_has_multi_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_has_multi_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, gen_has_entity(block.hasMultiTag(input.str(2)), { "hasMultiTags" }));
}

static void multi_tag_has_positions(const extractor &input, infusor &output){
    mexPrintf("[+] multi_tag_has_positions\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_has_entity(currMTag.hasPositions(), { "hasPositions" }));
}

static void block_open_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    nix::Tag currTag = block.getTag(input.str(2));
    handle currBlockTagHandle = handle(currTag);
    output.set(0, currBlockTagHandle);
}

static void block_list_tags(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_list_tags\n");

    nix::Block block = input.entity<nix::Block>(1);
    std::vector<nix::Tag> arr = block.tags();

    struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "position", "extent", "units" });

    for (const auto &da : arr) {
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.position());
        sb.set(da.extent());
        sb.set(da.units());

        sb.next();
    }
    output.set(0, sb.array());
}

static void block_open_multi_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_multi_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    nix::MultiTag currMultiTag = block.getMultiTag(input.str(2));
    handle currBlockMultiTagHandle = handle(currMultiTag);
    output.set(0, currBlockMultiTagHandle);
}

static void block_list_multi_tags(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_list_multi_tags\n");

    nix::Block block = input.entity<nix::Block>(1);
    std::vector<nix::MultiTag> arr = block.multiTags();

    struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "units" });

    for (const auto &da : arr) {
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.units());

        sb.next();
    }
    output.set(0, sb.array());
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

static mxArray *dim_to_struct(nix::SetDimension dim) {

    struct_builder sb({1}, { "type", "type_id", "labels" });

    sb.set("set");
    sb.set(1);
    sb.set(dim.labels());

    return sb.array();
}

static mxArray *dim_to_struct(nix::SampledDimension dim) {

    struct_builder sb({1}, {"type", "type_id", "interval", "label", "unit"});

    sb.set("sampled");
    sb.set(2);
    sb.set(dim.samplingInterval());
    sb.set(dim.label());
    sb.set(dim.unit());

    return sb.array();
}

static mxArray *dim_to_struct(nix::RangeDimension dim) {

    struct_builder sb({1}, {"type", "type_id", "ticks", "unit"});

    sb.set("range");
    sb.set(3);
    sb.set(dim.ticks());
    sb.set(dim.unit());

    return sb.array();
}

static void data_array_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_describe_data_array\n");
    nix::DataArray da = input.entity<nix::DataArray>(1);

    struct_builder sb({ 1 }, { "id", "type", "name", "definition", "label", 
            "shape", "unit", "dimensions", "polynom_coefficients" });

    sb.set(da.id());
    sb.set(da.type());
    sb.set(da.name());
    sb.set(da.definition());
    sb.set(da.label());
    sb.set(da.dataExtent());
    sb.set(da.unit());

    size_t ndims = da.dimensionCount();

    mxArray *dims = mxCreateCellMatrix(1, ndims);
    std::vector<nix::Dimension> da_dims = da.dimensions();

    for(size_t i = 0; i < ndims; i++) {
        mxArray *ca;

        switch(da_dims[i].dimensionType()) {
            case nix::DimensionType::Set:
                ca = dim_to_struct(da_dims[i].asSetDimension());
                break;
            case nix::DimensionType::Range:
                ca = dim_to_struct(da_dims[i].asRangeDimension());
                break;
            case nix::DimensionType::Sample:
                ca = dim_to_struct(da_dims[i].asSampledDimension());
                break;
        }

        mxSetCell(dims, i, ca);
    }

    sb.set(dims);
    sb.set(da.polynomCoefficients());

    output.set(0, sb.array());
}

static void data_array_read_all(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_describe_data_array\n");
    nix::DataArray da = input.entity<nix::DataArray>(1);

    nix::NDSize size = da.dataExtent();
    std::vector<mwSize> dims(size.size());

    for (size_t i = 0; i < size.size(); i++) {
        dims[i] = static_cast<mwSize>(size[i]);
    }

    nix::DataType da_type = da.dataType();
    DType2 dtype = dtype_nix2mex(da_type);

    if (!dtype.is_valid) {
        throw std::domain_error("Unsupported data type");
    }

    mxArray *data = mxCreateNumericArray(dims.size(), dims.data(), dtype.cid, dtype.clx);
    double *ptr = mxGetPr(data);

    nix::NDSize offset(size.size(), 0);
    da.getData(da_type, ptr, size, offset);

    output.set(0, data);
}

// handle tag entity
static void tag_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_describe\n");

    nix::Tag currTag = input.entity<nix::Tag>(1);

    struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "extent", 
                    "units", "featureCount", "sourceCount", "referenceCount" });

    sb.set(currTag.id());
    sb.set(currTag.type());
    sb.set(currTag.name());
    sb.set(currTag.definition());
    sb.set(currTag.position());
    sb.set(currTag.extent());
    sb.set(currTag.units());
    sb.set(currTag.featureCount());
    sb.set(currTag.sourceCount());
    sb.set(currTag.referenceCount());

    output.set(0, sb.array());
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

static void tag_list_features(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_features\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_list_features(currTag.features()));
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

static void block_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_list_sources\n");
    nix::Block currSource = input.entity<nix::Block>(1);
    output.set(0, gen_list_sources(currSource.sources()));
}

static void source_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] source_list_sources\n");
    nix::Source currSource = input.entity<nix::Source>(1);
    output.set(0, gen_list_sources(currSource.sources()));
}

static void tag_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_sources\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_list_sources(currTag.sources()));
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

static void block_open_source(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_source\n");
    nix::Block currSource = input.entity<nix::Block>(1);
    output.set(0, gen_open_source(currSource.getSource(input.str(2))));
}

static void source_open_source(const extractor &input, infusor &output)
{
    mexPrintf("[+] source_open_source\n");
    nix::Source currSource = input.entity<nix::Source>(1);
    output.set(0, gen_open_source(currSource.getSource(input.str(2))));
}

static void tag_open_source(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_source\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_open_source(currTag.getSource(input.str(2))));
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

static void tag_open_feature(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_feature\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_open_feature(currTag.getFeature(input.str(2))));
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

static void block_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_metadata_section\n");
    nix::Block currTag = input.entity<nix::Block>(1);
    output.set(0, gen_open_metadata_section(currTag.metadata()));
}

static void data_array_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] data_array_open_metadata_section\n");
    nix::DataArray currTag = input.entity<nix::DataArray>(1);
    output.set(0, gen_open_metadata_section(currTag.metadata()));
}

static void source_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] source_open_metadata_section\n");
    nix::Source currTag = input.entity<nix::Source>(1);
    output.set(0, gen_open_metadata_section(currTag.metadata()));
}

static void tag_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_metadata_section\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_open_metadata_section(currTag.metadata()));
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


// handle source entity
static void source_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] source_describe\n");
    nix::Source currSource = input.entity<nix::Source>(1);
    struct_builder sb({ 1 }, {"id", "type", "name", "definition", "sourceCount"});
    sb.set(currSource.id());
    sb.set(currSource.type());
    sb.set(currSource.name());
    sb.set(currSource.definition());
    sb.set(currSource.sourceCount());
    output.set(0, sb.array());
}


//handle feature entity
static void feature_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] feature_describe\n");
    nix::Feature currFeat = input.entity<nix::Feature>(1);
    struct_builder sb({ 1 }, {"id"});
    sb.set(currFeat.id());
    output.set(0, sb.array());
}

static void feature_link_type(const extractor &input, infusor &output)
{
    mexPrintf("[+] feature_link_type\n");
    nix::Feature currFeat = input.entity<nix::Feature>(1);
    //TODO properly implement link type
    struct_builder sb({ 1 }, { "linkType" });
    sb.set("linkType");
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
        {"Entity::destroy", entity_destroy},
        { "File::open", nixfile::open },
        { "File::describe", nixfile::describe },
        { "File::listBlocks", nixfile::list_blocks },
        { "File::openBlock", nixfile::open_block },
        { "File::listSections", nixfile::list_sections },
        { "File::openSection", nixfile::open_section },
        {"Block::describe", block_describe},
        {"Block::listDataArrays", block_list_data_arrays},
        {"Block::openDataArray", block_open_data_array},
        {"Block::listSources", block_list_sources},
        {"Block::openSource", block_open_source},
        {"Block::hasTag", block_has_tag},
        {"Block::listTags", block_list_tags},
        {"Block::openTag", block_open_tag},
        {"Block::hasMultiTag", block_has_multi_tag},
        {"Block::listMultiTags", block_list_multi_tags},
        {"Block::openMultiTag", block_open_multi_tag},
        {"Block::openMetadataSection", block_open_metadata_section},
        {"DataArray::describe", data_array_describe},
        {"DataArray::readAll", data_array_read_all},
        {"DataArray::openMetadataSection", data_array_open_metadata_section},
        // TODO implement dimensions
        {"Tag::describe", tag_describe},
        {"Tag::listReferences", tag_list_references_array},
        {"Tag::listFeatures", tag_list_features},
        {"Tag::listSources", tag_list_sources},
        {"Tag::openReferenceDataArray", tag_open_data_array},
        {"Tag::openFeature", tag_open_feature},
        {"Tag::openSource", tag_open_source},
        {"Tag::openMetadataSection", tag_open_metadata_section},
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
        {"Source::describe", source_describe},
        {"Source::listSources", source_list_sources},
        {"Source::openSource", source_open_source},
        {"Source::openMetadataSection", source_open_metadata_section},
        {"Feature::describe", feature_describe},
        {"Feature::linkType", feature_link_type},
        {"Feature::openData", feature_open_data}
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

