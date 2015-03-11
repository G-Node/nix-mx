#ifndef NIX_MX_MULTITAG
#define NIX_MX_MULTITAG

#include "arguments.h"

namespace nixmultitag {

    mxArray *describe(const nix::MultiTag &multitag);

    void add_reference(const extractor &input, infusor &output);

    void add_source(const extractor &input, infusor &output);

    void retrieve_data(const extractor &input, infusor &output);

    void retrieve_feature_data(const extractor &input, infusor &output);

} // namespace nixmultitag

#endif