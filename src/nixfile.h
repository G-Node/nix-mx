#ifndef NIX_MX_FILE
#define NIX_MX_FILE

#include "arguments.h"

namespace nixfile {

void open(const extractor &input, infusor &output);

mxArray *describe(const nix::File &f);

void list_blocks(const extractor &input, infusor &output);

void list_sections(const extractor &input, infusor &output);

void create_block(const extractor &input, infusor &output);

void create_section(const extractor &input, infusor &output);

} // namespace nixfile

#endif