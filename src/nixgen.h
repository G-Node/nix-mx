#ifndef NIX_MX_GENERICS
#define NIX_MX_GENERICS

#include "arguments.h"
#include "handle.h"

namespace nixgen {

    mxArray *dataset_read_all(const nix::DataSet &da);

    nix::LinkType get_link_type(uint8_t ltype);

} // namespace nixgen

#endif