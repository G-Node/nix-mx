#ifndef NIX_MX_BLOCK
#define NIX_MX_BLOCK

#include "arguments.h"

namespace nixblock {

    void describe(const extractor &input, infusor &output);

    void list_data_arrays(const extractor &input, infusor &output);

    void list_sources(const extractor &input, infusor &output);

    void list_tags(const extractor &input, infusor &output);

    void list_multi_tags(const extractor &input, infusor &output);

    void has_metadata_section(const extractor &input, infusor &output);

    void open_metadata_section(const extractor &input, infusor &output);

} // namespace nixblock

#endif