#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"

// *** datatype converter

struct struct_builder {

    struct_builder(std::vector<size_t> dims, std::vector<const char *> f)
        : n(0), pos(0), fields(f) {
        sa = mxCreateStructArray(dims.size(), dims.data(), fields.size(), fields.data());
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

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    mexPrintf("[+] entity_destroy\n");
    handle h = input.hdl(1);
    h.destroy();
}

static void open_file(const extractor &input, infusor &output)
{
    mexPrintf("[+] open_file\n");

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

static void list_blocks(const extractor &input, infusor &output)
{
    mexPrintf("[+] list_blocks\n");
    nix::File fd = input.entity<nix::File>(1);

    std::vector<nix::Block> blocks = fd.blocks();

    struct_builder sb({blocks.size()}, {"name", "id", "type"});

    for (const auto &b : blocks) {
        sb.set(b.name());
        sb.set(b.id());
        sb.set(b.type());

        sb.next();
    }

    output.set(0, sb.array());
}

static void open_block(const extractor &input, infusor &output)
{
    mexPrintf("[+] list_data_arrays\n");
    nix::File nf = input.entity<nix::File>(1);
    nix::Block block = nf.getBlock(input.str(2));
    handle bb = handle(block);
    output.set(0, bb);
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

static void open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_open_data_array\n");
    nix::Block block = input.entity<nix::Block>(1);
    nix::DataArray da = block.getDataArray(input.str(2));
    handle bd = handle(da);
    output.set(0, bd);
}

static void tag_open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_data_array\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    nix::DataArray da = currTag.getReference(input.str(2));
    handle currDAHandle = handle(da);
    output.set(0, currDAHandle);
}

static void block_list_data_arrays(const extractor &input, infusor &output)
{
    mexPrintf("[+] list_data_arrays\n");

    nix::Block block = input.entity<nix::Block>(1);
    std::vector<nix::DataArray> arr = block.dataArrays();

    struct_builder sb({arr.size()}, {"name", "id", "type"});

    for (const auto &da : arr) {
        sb.set(da.name());
        sb.set(da.id());
        sb.set(da.type());

        sb.next();
    }

    output.set(0, sb.array());
}

static void has_tag(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_has_tag\n");
    nix::Block block = input.entity<nix::Block>(1);
    uint8_t currHasTag = block.hasTag(input.str(2)) ? 1 : 0;
    struct_builder sb({ 1 }, { "hasTag" });
    sb.set(currHasTag);
    output.set(0, sb.array());
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

// return list of all data arrays referenced by the current tag
static void tag_list_references_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_references\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);

    std::vector<nix::DataArray> arr = currTag.references();

    struct_builder sb({ arr.size() }, { "name", "id", "type" });

    for (const auto &da : arr) {
        sb.set(da.name());
        sb.set(da.id());
        sb.set(da.type());

        sb.next();
    }

    output.set(0, sb.array());

}

static void tag_list_features(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_features\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);

    std::vector<nix::Feature> arr = currTag.features();

    struct_builder sb({ arr.size() }, { "id" });

    for (const auto &da : arr) {
        sb.set(da.id());

        sb.next();
    }

    output.set(0, sb.array());
}

static void tag_list_sources(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_list_sources\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);

    std::vector<nix::Source> arr = currTag.sources();

    struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "sourceCount" });

    for (const auto &da : arr) {
        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.sourceCount());

        sb.next();
    }
    output.set(0, sb.array());
}

static void tag_open_source(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_source\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    nix::Source currSource = currTag.getSource(input.str(2));
    handle currTagSourceHandle = handle(currSource);
    output.set(0, currTagSourceHandle);
}

static void tag_open_feature(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_feature\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    nix::Feature currFeat = currTag.getFeature(input.str(2));
    handle currTagFeatHandle = handle(currFeat);
    output.set(0, currTagFeatHandle);
}

static void tag_open_metadata_section(const extractor &input, infusor &output)
{
    mexPrintf("[+] tag_open_metadata_section\n");
    nix::Tag currTag = input.entity<nix::Tag>(1);
    nix::Section currMDSec = currTag.metadata();
    handle currTagMDSecHandle = handle(currMDSec);
    output.set(0, currTagMDSecHandle);
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
        {"File::open", open_file},
        {"File::listBlocks", list_blocks},
        {"File::openBlock", open_block},
        {"Block::describe", block_describe},
        {"Block::openDataArray", open_data_array},
        {"Block::listDataArrays", block_list_data_arrays},
        {"Block::hasTag", has_tag},
        {"Block::openTag", open_tag},
        {"Block::listTags", block_list_tags},
        {"DataArray::describe", data_array_describe},
        {"DataArray::readAll", data_array_read_all},
        {"Tag::describe", tag_describe},
        {"Tag::listReferences", tag_list_references_array},
        {"Tag::listFeatures", tag_list_features},
        {"Tag::listSources", tag_list_sources},
        {"Tag::openSource", tag_open_source },
        {"Tag::openFeature", tag_open_feature },
        {"Tag::openReferenceDataArray", tag_open_data_array},
        {"Tag::openMetadataSection", tag_open_metadata_section}

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

