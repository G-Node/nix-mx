#include "nixfeature.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat)
    {
        struct_builder sb({ 1 }, { "id" });
        sb.set(feat.id());
        return sb.array();
    }

    void link_type(const extractor &input, infusor &output)
    {
        nix::Feature currFeat = input.entity<nix::Feature>(1);
        //TODO properly implement link type
        struct_builder sb({ 1 }, { "linkType" });
        sb.set("linkType");
        output.set(0, sb.array());
    }

} // namespace nixfeature