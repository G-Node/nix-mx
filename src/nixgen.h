#ifndef NIX_MX_GENERICS
#define NIX_MX_GENERICS

#include "arguments.h"
#include "handle.h"

namespace nixgen {

    mxArray *dataset_read_all(const nix::DataSet &da);

    std::vector<nix::Value> extract_property_values(const extractor &input, int idx);

} // namespace nixgen

#endif