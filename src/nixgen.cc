#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixgen {

    handle open_data_array(nix::DataArray inDa)
    {
        nix::DataArray da = inDa;
        handle h = handle(da);
        return h;
    }

    mxArray* list_data_arrays(std::vector<nix::DataArray> daIn)
    {
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

    mxArray* list_features(std::vector<nix::Feature> featIn)
    {
        std::vector<nix::Feature> arr = featIn;
        struct_builder sb({ arr.size() }, { "id" });
        for (const auto &da : arr) {
            sb.set(da.id());
            sb.next();
        }
        return sb.array();
    }

    mxArray* list_sources(std::vector<nix::Source> sourceIn)
    {
        std::vector<nix::Source> arr = sourceIn;
        struct_builder sb({ arr.size() }, { "id", "type", "name", "definition" });
        for (const auto &da : arr) {
            sb.set(da.id());
            sb.set(da.type());
            sb.set(da.name());
            sb.set(da.definition());
            sb.next();
        }
        return sb.array();
    }

    handle open_source(nix::Source sourceIn)
    {
        nix::Source currSource = sourceIn;
        handle currSourceHandle = handle(currSource);
        return currSourceHandle;
    }

    handle open_feature(nix::Feature featIn)
    {
        nix::Feature currFeat = featIn;
        handle currTagFeatHandle = handle(currFeat);
        return currTagFeatHandle;
    }


mxArray *dataset_read_all(const nix::DataSet &da) {
    nix::NDSize size = da.dataExtent();
    const size_t len = size.size();
    std::vector<mwSize> dims(len);

    //NB: matlab is column-major, while HDF5 is row-major
    //    data is correct with this, but dimensions don't
    //    agree with the file anymore. Transpose it in matlab
    //    (DataArray.read_all)
    for (size_t i = 0; i < len; i++) {
        dims[len - (i + 1)] = static_cast<mwSize>(size[i]);
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

    return data;
}

} // namespace nixgen
