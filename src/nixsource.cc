#include "nixsource.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixsource {

    void describe(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });
        sb.set(currObj.id());
        sb.set(currObj.type());
        sb.set(currObj.name());
        sb.set(currObj.definition());
        output.set(0, sb.array());
    }

} // namespace nixsource
