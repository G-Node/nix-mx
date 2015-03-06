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
        mxArray *data = nixgen::dataset_read_all(da);
        output.set(0, data);
    }

    void write_all(const extractor &input, infusor &output)
    {
        nix::DataArray da = input.entity<nix::DataArray>(1);

        nix::DataType dtype = input.dtype(2);
        nix::NDSize count = input.ndsize(2);
        nix::NDSize offset(0);
        double *ptr = input.get_raw(2);

        da.setData(dtype, ptr, count, offset);
    }

} // namespace nixdataarray