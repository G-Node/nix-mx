#ifndef NIX_MX_PROPERTY
#define NIX_MX_PROPERTY

#include "arguments.h"

namespace nixproperty {

    mxArray *describe(const nix::Property &prop);

    void values(const extractor &input, infusor &output);

} // namespace nixproperty

#endif
