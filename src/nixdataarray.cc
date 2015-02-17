#include "nixdataarray.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"

namespace nixdataarray {

    void describe(const extractor &input, infusor &output)
    {
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

        for (size_t i = 0; i < ndims; i++) {
            mxArray *ca;

            switch (da_dims[i].dimensionType()) {
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

    void read_all(const extractor &input, infusor &output)
    {
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

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::DataArray currTag = input.entity<nix::DataArray>(1);
        output.set(0, nixgen::open_metadata_section(currTag.metadata()));
    }

} // namespace nixdataarray