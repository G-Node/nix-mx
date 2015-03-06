#ifndef NIX_MX_DATAARRAY
#define NIX_MX_DATAARRAY

#include "arguments.h"

namespace nixdataarray {

    void describe(const extractor &input, infusor &output);
    
    void read_all(const extractor &input, infusor &output);

} // namespace nixdataarray

#endif