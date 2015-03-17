#ifndef NIX_MX_SECTION
#define NIX_MX_SECTION

#include "arguments.h"

namespace nixsection {

    mxArray *describe(const nix::Section &section);

    void properties(const extractor &input, infusor &output);

    void create_property(const extractor &input, infusor &output);

} // namespace nixfile

#endif