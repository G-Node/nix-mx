#ifndef NIX_MX_DATAARRAY
#define NIX_MX_DATAARRAY

#include "arguments.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da);

    void read_all(const extractor &input, infusor &output);

    void write_all(const extractor &input, infusor &output);

} // namespace nixdataarray

#endif