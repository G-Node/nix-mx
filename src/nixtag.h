#ifndef NIX_MX_TAG
#define NIX_MX_TAG

#include "arguments.h"

namespace nixtag {

    mxArray *describe(const nix::Tag &tag);

    void add_reference(const extractor &input, infusor &output);

    void add_source(const extractor &input, infusor &output);

    void retrieve_data(const extractor &input, infusor &output);

    void retrieve_feature_data(const extractor &input, infusor &output);

} // namespace nixtag

#endif