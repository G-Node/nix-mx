#ifndef NIX_MX_BLOCK
#define NIX_MX_BLOCK

#include "arguments.h"

namespace nixblock {

    void describe(const extractor &input, infusor &output);

    void create_data_array(const extractor &input, infusor &output);

} // namespace nixblock

#endif