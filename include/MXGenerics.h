#ifndef NIX_MX_GENERICS
#define NIX_MX_GENERICS

#include "arguments.h"

namespace gen {

    handle open_data_array(nix::DataArray inDa);

    mxArray* list_data_arrays(std::vector<nix::DataArray> daIn);

    mxArray* has_entity(bool boolIn, std::vector<const char *> currLabel);

    mxArray* list_features(std::vector<nix::Feature> featIn);

    mxArray* list_sources(std::vector<nix::Source> sourceIn);

    handle open_source(nix::Source sourceIn);

    handle open_feature(nix::Feature featIn);

    handle open_metadata_section(nix::Section secIn);

} // namespace gen

#endif