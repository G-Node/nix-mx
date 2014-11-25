#include <iostream>
#include <math.h>
#include <string>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"

// *** datatype converter

template<typename T>
struct to_mx_class_id {

    static std::pair<mxClassID, mxComplexity> value() {
        nix::DataType dtype = nix::to_data_type<T>::value;
        switch (dtype) {
            case nix::DataType::Double:
                return std::make_pair(mxDOUBLE_CLASS, mxREAL);

            case nix::DataType::Int64:
                return std::make_pair(mxINT64_CLASS, mxREAL);

            case nix::DataType::Int32:
                return std::make_pair(mxINT32_CLASS, mxREAL);


            default:
                mexErrMsgIdAndTxt("nix:toclassid:notimplemented", "Implement me!");
                return std::make_pair(mxVOID_CLASS, mxREAL);
        }
    }

};


mxArray* make_mx_array(const std::string &s)
{
    return mxCreateString(s.c_str());
}


mxArray* make_mx_array(uint32_t val)
{
    mxArray *arr = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    void *data = mxGetData(arr);
    memcpy(data, &val, sizeof(uint32_t));
    return arr;
}

template<typename T>
mxArray* make_mx_array(const std::vector<T> &v) {
    std::pair<mxClassID, mxComplexity> klass = to_mx_class_id<T>::value();
    mxArray *data = mxCreateNumericMatrix(1, v.size(), klass.first, klass.second);
    double *ptr = mxGetPr(data);
    memcpy(ptr, v.data(), sizeof(T) * v.size());
    return data;
}

template<>
mxArray* make_mx_array(const std::vector<std::string> &v) {

    if (v.empty()) {
        return nullptr;
    }

    mxArray *data = mxCreateCellMatrix(1, v.size());
    for (size_t i = 0; i < v.size(); i++) {
        mxSetCell(data, i, mxCreateString(v[i].c_str()));
    }

    return data;
}

template<typename T>
mxArray* make_mx_array(const boost::optional<T> &opt) {
    if (opt) {
        make_mx_array(*opt);
    }

    return nullptr;
}

template<typename T>
mxArray* make_mx_array(T val, typename std::enable_if<std::is_arithmetic<T>::value >::type* = nullptr) {
    std::pair<mxClassID, mxComplexity> klass = to_mx_class_id<T>::value();
    mxArray *arr = mxCreateNumericMatrix(1, 1, klass.first, klass.second);
    void *data = mxGetData(arr);
    memcpy(data, &val, sizeof(T));
    return arr;
}

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
        mxSetFieldByNumber(sa, struct_idx, field_idx, make_mx_array(std::forward<T>(value)));
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

static void entity_destory(const extractor &input, infusor &output)
{
    mexPrintf("[+] entity_destory\n");
    handle h = input.hdl(1);
    h.destroy();
}

static void open_file(const extractor &input, infusor &output)
{
    input.require_arguments({mxCHAR_CLASS, mxCHAR_CLASS}, true);
    mexPrintf("[+] open_file\n");

    std::string name = input.str(1);

    nix::File fn = nix::File::open(name, nix::FileMode::ReadWrite);
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

static void open_data_array(const extractor &input, infusor &output)
{
    mexPrintf("[+] list_data_arrays\n");
    nix::Block block = input.entity<nix::Block>(1);
    nix::DataArray da = block.getDataArray(input.str(2));
    handle bd = handle(da);
    output.set(0, bd);
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



static mxArray * ndsize_to_mxarray(const nix::NDSize &size)
{
    mxArray *res = mxCreateNumericMatrix(1, size.size(), mxUINT64_CLASS, mxREAL);
    void *ptr = mxGetData(res);
    uint64_t *data = static_cast<uint64_t *>(ptr);

    for (size_t i = 0; i < size.size(); i++) {
        data[i] = static_cast<uint64_t>(size[i]);
    }

    return res;
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

    std::vector<const char *> fields = { "type", "type_id", "ticks", "unit"};
    mxArray *sa =  mxCreateStructMatrix(1, 1, fields.size(), fields.data());

    mxSetFieldByNumber(sa, 0, 0, mxCreateString("range"));
    mxSetFieldByNumber(sa, 0, 1, nmCreateScalar(3));

    std::vector<double> ticks = dim.ticks();
    mxSetFieldByNumber(sa, 0, 2, make_mx_array(ticks));

    boost::optional<std::string> unit = dim.unit();
    if (unit) {
        mxSetFieldByNumber(sa, 0, 3, mxCreateString(unit->c_str()));
    }

    return sa;
}

static void data_array_describe(const extractor &input, infusor &output)
{
    mexPrintf("[+] block_describe_data_array\n");
    nix::DataArray da = input.entity<nix::DataArray>(1);

    std::vector<const char *> fields = { "name", "id", "shape",  "unit", "dimensions", "label",
                                         "polynom_coefficients"};
    mxArray *sa =  mxCreateStructMatrix(1, 1, fields.size(), fields.data());

    mxSetFieldByNumber(sa, 0, 0, mxCreateString(da.name().c_str()));
    mxSetFieldByNumber(sa, 0, 1, mxCreateString(da.id().c_str()));
    mxSetFieldByNumber(sa, 0, 2, ndsize_to_mxarray(da.dataExtent()));

    boost::optional<std::string> unit = da.unit();
    if (unit) {
        mxSetFieldByNumber(sa, 0, 3, mxCreateString(unit->c_str()));
    }

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

    mxSetFieldByNumber(sa, 0, 4, dims);


    boost::optional<std::string> label = da.label();
    if (unit) {
        mxSetFieldByNumber(sa, 0, 5, mxCreateString(label->c_str()));
    }

    std::vector<double> pc = da.polynomCoefficients();

    if (!pc.empty()) {
        mxSetFieldByNumber(sa, 0, 6, make_mx_array(pc));
    }

    output.set(0, sa);
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

    mxArray *data = mxCreateNumericArray(size.size(), dims.data(), mxDOUBLE_CLASS, mxREAL);
    double *ptr = mxGetPr(data);

    nix::NDSize offset(size.size(), 0);
    da.getData(nix::DataType::Double , ptr, size, offset);

    output.set(0, data);
}

// *** ***

typedef void (*fn_t)(const extractor &input, infusor &output);

struct fendpoint {

fendpoint(std::string name, fn_t fn) : name(name), fn(fn) {}

    std::string name;
    fn_t fn;
};

const std::vector<fendpoint> funcs = {
        {"Entity::destroy", entity_destory},
        {"File::open", open_file},
        {"File::listBlocks", list_blocks},
        {"File::openBlock", open_block},
        {"Block::openDataArray", open_data_array},
        {"Block::listDataArrays", block_list_data_arrays},
        {"DataArray::describe", data_array_describe},
        {"DataArray::readAll", data_array_read_all}
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
            } catch (std::exception &e) {
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

