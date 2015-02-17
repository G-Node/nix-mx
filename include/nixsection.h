#ifndef NIX_MX_SECTION
#define NIX_MX_SECTION

#include "arguments.h"

namespace nixsection {

void describe(const extractor &input, infusor &output);

void link(const extractor &input, infusor &output);

void parent(const extractor &input, infusor &output);

void has_section(const extractor &input, infusor &output);

void open_section(const extractor &input, infusor &output);

void list_sections(const extractor &input, infusor &output);

void sections(const extractor &input, infusor &output);

void has_property(const extractor &input, infusor &output);

void list_properties(const extractor &input, infusor &output);

} // namespace nixfile

#endif