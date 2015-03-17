#include "nixproperty.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixproperty {

    mxArray *describe(const nix::Property &prop)
    {
        struct_builder sb({ 1 }, { "id", "name", "definition", "unit", "mapping", "datatype" });

        sb.set(prop.id());
        sb.set(prop.name());
        sb.set(prop.definition());
        sb.set(prop.unit());
        sb.set(prop.mapping());
        sb.set(nix::data_type_to_string(prop.dataType()));

        return sb.array();
    }

} // namespace nixproperty
