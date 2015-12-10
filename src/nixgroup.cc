#include "nixgroup.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixgroup {

    mxArray *describe(const nix::Group &group)
    {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });

        sb.set(group.id());
        sb.set(group.type());
        sb.set(group.name());
        sb.set(group.definition());

        return sb.array();
    }
    
    void add_data_array(const extractor &input, infusor &output)
    {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addDataArray(input.str(2));
    }

    void add_tag(const extractor &input, infusor &output)
    {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addTag(input.str(2));
    }

    void add_multi_tag(const extractor &input, infusor &output)
    {
        nix::Group currObj = input.entity<nix::Group>(1);
        currObj.addMultiTag(input.str(2));
    }

} // namespace nixgroup
