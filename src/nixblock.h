#ifndef NIX_MX_BLOCK
#define NIX_MX_BLOCK

#include "arguments.h"

namespace nixblock {

    mxArray *describe(const nix::Block &block);

    void create_data_array(const extractor &input, infusor &output);

    void create_multi_tag(const extractor &input, infusor &output);

    void create_group(const extractor &input, infusor &output);

} // namespace nixblock

#endif