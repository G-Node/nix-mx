#ifndef NIX_MX_TAG
#define NIX_MX_TAG

#include "arguments.h"

namespace nixtag {

    void describe(const extractor &input, infusor &output);

    void retrieve_data(const extractor &input, infusor &output);

    void retrieve_feature_data(const extractor &input, infusor &output);

} // namespace nixtag

#endif