#ifndef NIX_MX_MULTITAG
#define NIX_MX_MULTITAG

#include "arguments.h"

namespace nixmultitag {

    void describe(const extractor &input, infusor &output);

    void open_references(const extractor &input, infusor &output);

    void open_positions(const extractor &input, infusor &output);

    void open_extents(const extractor &input, infusor &output);

    void list_references_array(const extractor &input, infusor &output);

    void has_positions(const extractor &input, infusor &output);

    void list_features(const extractor &input, infusor &output);

    void list_sources(const extractor &input, infusor &output);

    void open_source(const extractor &input, infusor &output);

    void open_features(const extractor &input, infusor &output);

    void open_metadata_section(const extractor &input, infusor &output);

} // namespace nixmultitag

#endif