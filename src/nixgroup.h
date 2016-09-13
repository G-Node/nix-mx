#ifndef NIX_MX_GROUP
#define NIX_MX_GROUP

#include "arguments.h"

namespace nixgroup {

    mxArray *describe(const nix::Group &group);

    void add_data_array(const extractor &input, infusor &output);

    void add_tag(const extractor &input, infusor &output);

    void add_multi_tag(const extractor &input, infusor &output);

} // namespace nixgroup

#endif
