#include "nixsection.h"

#include "mex.h"
#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"


namespace nixsection {

mxArray *describe(const nix::Section &section)
{
    struct_builder sb({ 1 }, { 
        "name", "id", "type", "definition", "repository", "mapping"
    });

    sb.set(section.name());
    sb.set(section.id());
    sb.set(section.type());
    sb.set(section.definition());
    sb.set(section.repository());
    sb.set(section.mapping());

    return sb.array();
}

void properties(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    std::vector<nix::Property> properties = section.properties();

    const mwSize size = static_cast<mwSize>(properties.size());
    mxArray *lst = mxCreateCellArray(1, &size);

    for (size_t i = 0; i < properties.size(); i++) {

        nix::Property pr = properties[i];

        struct_builder sb({ 1 }, {
            "name", "id", "definition", "mapping", "unit"
        });

        sb.set(pr.name());
        sb.set(pr.id());
        sb.set(pr.definition());
        sb.set(pr.mapping());
        sb.set(pr.unit());

        mxSetCell(lst, i, sb.array());
    }

    output.set(0, lst);
}

void create_property(const extractor &input, infusor &output)
{
    nix::Section currObj = input.entity<nix::Section>(1);

    nix::DataType dtype = nix::string_to_data_type(input.str(3));

    nix::Property p = currObj.createProperty(input.str(2), dtype);
    output.set(0, handle(p));
}

void create_property_with_value(const extractor &input, infusor &output)
{
    nix::Section currObj = input.entity<nix::Section>(1);

    std::vector<nix::Value> currVec;

    mxClassID currID = input.class_id(3);
    if (currID == mxCELL_CLASS){
        mexPrintf("Cell\n");
        const mxArray *cell_element_ptr = input.cellElemPtr(3, 0);

        if (mxGetClassID(cell_element_ptr) == mxSTRUCT_CLASS){
            mexPrintf("Struct\n");
            currVec = input.extractFromStruct(3);
        }
        else
        {
            mexPrintf("Cell with normal values\n");
            currVec = input.vec(3);
        }
    }
    else if (currID == mxCHAR_CLASS){
        mexPrintf("Just char\n");
    }
    else if (currID == mxDOUBLE_CLASS){
        mexPrintf("Just double\n");
    }
    else if (currID == mxLOGICAL_CLASS){
        mexPrintf("Just logical\n");
    }

    nix::Property p = currObj.createProperty(input.str(2), currVec);
    output.set(0, handle(p));
}

} // namespace nixsection
