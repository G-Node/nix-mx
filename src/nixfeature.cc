#include "nixfeature.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfeature {

    mxArray *describe(const nix::Feature &feat)
    {
        nix::LinkType link_type = feat.linkType();
        uint8_t ltype;

        switch (link_type) {
        case nix::LinkType::Tagged: ltype = 0; break;
        case nix::LinkType::Untagged: ltype = 1; break;
        case nix::LinkType::Indexed: ltype = 2; break;
        default: throw std::invalid_argument("unkown link type");
        }

        struct_builder sb({ 1 }, { "id", "linkType" });
        sb.set(feat.id());
        sb.set(ltype);
        return sb.array();
    }

} // namespace nixfeature