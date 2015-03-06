#ifndef NIX_MX_FEATURE
#define NIX_MX_FEATURE

#include "arguments.h"

namespace nixfeature {

    void describe(const extractor &input, infusor &output);

    void link_type(const extractor &input, infusor &output);

} // namespace nixfeature

#endif