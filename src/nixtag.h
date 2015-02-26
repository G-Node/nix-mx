#ifndef NIX_MX_TAG
#define NIX_MX_TAG

#include "arguments.h"

namespace nixtag {

    void describe(const extractor &input, infusor &output);

    void list_references_array(const extractor &input, infusor &output);

    void list_features(const extractor &input, infusor &output);

    void list_sources(const extractor &input, infusor &output);

    void open_metadata_section(const extractor &input, infusor &output);

    void retrieve_data(const extractor &input, infusor &output);

    void retrieve_feature_data(const extractor &input, infusor &output);

} // namespace nixtag

#endif