#ifndef NIX_MX_SOURCE
#define NIX_MX_SOURCE

#include "arguments.h"

namespace nixsource {

    void describe(const extractor &input, infusor &output);

    void list_sources(const extractor &input, infusor &output);

    void open_source(const extractor &input, infusor &output);

    void open_metadata_section(const extractor &input, infusor &output);

} // namespace nixsource

#endif