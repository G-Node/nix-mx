#ifndef NIX_MX_GENERICS
#define NIX_MX_GENERICS

#include "arguments.h"
#include "handle.h"

namespace nixgen {

    mxArray* list_data_arrays(std::vector<nix::DataArray> daIn);

    mxArray* list_features(std::vector<nix::Feature> featIn);

    mxArray* list_sources(std::vector<nix::Source> sourceIn);

    mxArray *dataset_read_all(const nix::DataSet &da);

} // namespace nixgen

#endif