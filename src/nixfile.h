#ifndef NIX_MX_FILE
#define NIX_MX_FILE

#include "arguments.h"

namespace nixfile {

void open(const extractor &input, infusor &output);

mxArray *describe(const nix::File &f);

} // namespace nixfile

#endif