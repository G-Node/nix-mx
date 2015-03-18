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

    void values(const extractor &input, infusor &output)
    {
        nix::Property prop = input.entity<nix::Property>(1);
        std::vector<nix::Value> vals = prop.values();

        const mwSize size = static_cast<mwSize>(vals.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < vals.size(); i++) {

            nix::Value pr = vals[i];

            struct_builder sb({ 1 }, { "value", "uncertainty", "checksum", "encoder", "filename", "reference" });

            sb.set(make_mx_array(pr));
            sb.set(pr.uncertainty);
            sb.set(pr.checksum);
            sb.set(pr.checksum);
            sb.set(pr.filename);
            sb.set(pr.reference);

            mxSetCell(lst, i, sb.array());
        }

        output.set(0, lst);
    }

    void update_values(const extractor &input, infusor &output)
    {
        nix::Property prop = input.entity<nix::Property>(1);
        std::vector<nix::Value> getVals = input.extractFromStruct(2);
        prop.values(getVals);
    }

} // namespace nixproperty
