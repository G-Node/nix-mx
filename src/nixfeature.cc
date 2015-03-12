#include "nixfeature.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat)
    {
        struct_builder sb({ 1 }, { "id", "linkType" });
        sb.set(feat.id());
        sb.set(feat.linkType());
        return sb.array();
    }

} // namespace nixfeature