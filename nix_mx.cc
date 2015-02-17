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
#include "nix2mx.h"

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

    struct_builder sb({ 1 }, { "name", "id", "type", "sourceCount", "dataArrayCount", "tagCount", "multiTagCount" });

    sb.set(block.name());
    sb.set(block.id());
    sb.set(block.type());
    sb.set(block.sourceCount());
    sb.set(block.dataArrayCount());
    sb.set(block.tagCount());
    sb.set(block.multiTagCount());

    output.set(0, sb.array());
}

static handle gen_open_data_array(nix::DataArray inDa){
    nix::DataArray da = inDa;
    handle h = handle(da);
    return h;
}

static void open_data_array(const extractor &input, infusor &output)
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

static void multi_tag_open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_data_array\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_data_array(currMTag.getReference(input.str(2))));
}

static mxArray* gen_list_data_arrays(std::vector<nix::DataArray> daIn){
    std::vector<nix::DataArray> arr = daIn;

    struct_builder sb({ arr.size() }, { "name", "id", "type" });

    for (const auto &da : arr) {
        sb.set(da.name());
        sb.set(da.id());
        sb.set(da.type());

        sb.next();
    }
    return sb.array();
}

static void block_list_data_arrays(const extractor &input, infusor &output)
{
    mexPrintf("[+] list_data_arrays\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, gen_list_data_arrays(block.dataArrays()));
}

static void tag_list_references_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_data_array_references\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_list_data_arrays(currTag.references()));
}

static void multi_tag_list_references_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_list_references\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_list_data_arrays(currMTag.references()));
}




static void has_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_has_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, has_entity(block.hasTag(input.str(2)), { "hasTag" }));
}

static void has_multi_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_has_multi_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    output.set(0, has_entity(block.hasMultiTag(input.str(2)), { "hasMultiTags" }));
}


static void open_tag(const extractor &input, infusor &output)
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

    struct_builder sb({ arr.size() }, { "name", "id", "type", "definition", "position", "extent", "units" });

    for (const auto &da : arr) {
        sb.set(da.name());
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.definition());
        sb.set(da.position());
        sb.set(da.extent());
        sb.set(da.units());

        sb.next();
    }
    output.set(0, sb.array());
}

static void open_multi_tag(const extractor &input, infusor &output)
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

    struct_builder sb({ arr.size() }, { "name", "id", "type", "definition", "units" });

    for (const auto &da : arr) {
        sb.set(da.name());
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.definition());
        sb.set(da.units());

        sb.next();
    }
    output.set(0, sb.array());
}

static void data_array_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_describe_data_array\n");
    nix::DataArray da = input.entity<nix::DataArray>(1);

    struct_builder sb({1}, {"name", "id", "shape",  "unit", "dimensions", "label",
                "polynom_coefficients"});

    sb.set(da.name());
    sb.set(da.id());
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
    sb.set(da.label());
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

    struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "units", "extent", "featuresCount", "sourcesCount", "dataArrayReferenceCount" });

    sb.set(currTag.id());
    sb.set(currTag.type());
    sb.set(currTag.name());
    sb.set(currTag.definition());
    sb.set(currTag.position());
    sb.set(currTag.units());
    sb.set(currTag.extent());
    sb.set(currTag.featureCount());
    sb.set(currTag.sourceCount());
    sb.set(currTag.referenceCount());

    output.set(0, sb.array());
}


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

static void tag_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_sources\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    output.set(0, gen_list_sources(currTag.sources()));
}

// return list of all sources referenced by the current multitag
static void multi_tag_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_list_sources\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_list_sources(currMTag.sources()));
}

static handle gen_open_source(nix::Source sourceIn){
    nix::Source currSource = sourceIn;
    handle currSourceHandle = handle(currSource);
    return currSourceHandle;
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

static void multi_tag_open_feature(const extractor &input, infusor &output)
{
    mexPrintf("[+] multi_tag_open_feature\n");
    nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
    output.set(0, gen_open_feature(currMTag.getFeature(input.str(2))));
}


static handle gen_open_metadata_section(nix::Section secIn){
    nix::Section currMDSec = secIn;
    handle currTagMDSecHandle = handle(currMDSec);
    return currTagMDSecHandle;
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

    struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units", "featuresCount", "sourcesCount", "dataArrayReferenceCount" });

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
        {"Entity::destroy", entity_destroy},
        { "File::open", nixfile::open },
        { "File::describe", nixfile::describe },
        { "File::listBlocks", nixfile::list_blocks },
        { "File::openBlock", nixfile::open_block },
        { "File::listSections", nixfile::list_sections },
        { "File::openSection", nixfile::open_section },
        {"Block::describe", block_describe},
        {"Block::openDataArray", open_data_array},
        {"Block::listDataArrays", block_list_data_arrays},
        {"Block::hasTag", has_tag},
        {"Block::openTag", open_tag},
        {"Block::listTags", block_list_tags},
        {"Block::hasMultiTag", has_multi_tag},
        {"Block::openMultiTag", open_multi_tag},
        {"Block::listMultiTags", block_list_multi_tags},
        {"DataArray::describe", data_array_describe},
        {"DataArray::readAll", data_array_read_all},
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
        {"MultiTag::openReferenceDataArray", multi_tag_open_data_array},
        {"MultiTag::openFeature", multi_tag_open_feature},
        {"MultiTag::openSource", multi_tag_open_source},
        {"MultiTag::openMetadataSection", multi_tag_open_metadata_section}
        //TODO: implement handling of multitag positions and extents
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

