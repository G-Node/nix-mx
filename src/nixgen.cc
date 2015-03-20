#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixgen {

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

std::vector<nix::Value> extract_property_values(const extractor &input, int idx) {
    std::vector<nix::Value> currVec;

    mxClassID currID = input.class_id(idx);
    if (currID == mxCELL_CLASS) {
        const mxArray *cell_element_ptr = input.cellElemPtr(idx, 0);

        if (mxGetClassID(cell_element_ptr) == mxSTRUCT_CLASS) {
            currVec = input.extractFromStruct(idx);
        } else {
            currVec = input.vec(idx);
        }
    } else {
        mexPrintf("Unsupported data type\n");
    }

    return currVec;
}

} // namespace nixgen
