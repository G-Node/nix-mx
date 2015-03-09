#ifndef NIX_MX_FEATURE
#define NIX_MX_FEATURE

#include "arguments.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat);

    void link_type(const extractor &input, infusor &output);

} // namespace nixfeature

#endif