#ifndef NIX_MX_DATAARRAY
#define NIX_MX_DATAARRAY

#include "arguments.h"

namespace nixda {

    void describe(const extractor &input, infusor &output);
    
    void read_all(const extractor &input, infusor &output);

    void open_metadata_section(const extractor &input, infusor &output);

} // namespace nixda

#endif