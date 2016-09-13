#include "nixsource.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixsource {

    mxArray *describe(const nix::Source &source) {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });
        sb.set(source.id());
        sb.set(source.type());
        sb.set(source.name());
        sb.set(source.definition());
        return sb.array();
    }

} // namespace nixsource
