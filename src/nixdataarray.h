#ifndef NIX_MX_DATAARRAY
#define NIX_MX_DATAARRAY

#include "arguments.h"

namespace nixdataarray {

    mxArray *describe(const nix::DataArray &da);

    void add_source(const extractor &input, infusor &output);

    void remove_source(const extractor &input, infusor &output);

    void read_all(const extractor &input, infusor &output);

    void write_all(const extractor &input, infusor &output);

    void delete_dimension(const extractor &input, infusor &output);

} // namespace nixdataarray

#endif