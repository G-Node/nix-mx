#include "nixdataarray.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da)
    {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "label",
            "shape", "unit", "polynom_coefficients" });

        sb.set(da.id());
        sb.set(da.type());
        sb.set(da.name());
        sb.set(da.definition());
        sb.set(da.label());
        sb.set(da.dataExtent());
        sb.set(da.unit());
        sb.set(da.polynomCoefficients());

        return sb.array();
    }

    void add_source(const extractor &input, infusor &output)
    {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        currObj.addSource(input.str(2));
    }

    void remove_source(const extractor &input, infusor &output)
    {
        nix::DataArray currObj = input.entity<nix::DataArray>(1);
        output.set(0, currObj.removeSource(input.str(2)));
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