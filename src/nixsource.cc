#include "nixsource.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixsource {

    void describe(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "sourceCount" });
        sb.set(currObj.id());
        sb.set(currObj.type());
        sb.set(currObj.name());
        sb.set(currObj.definition());
        sb.set(currObj.sourceCount());
        output.set(0, sb.array());
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        output.set(0, nixgen::list_sources(currObj.sources()));
    }

    void open_source(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        output.set(0, nixgen::open_source(currObj.getSource(input.str(2))));
    }

    void has_metadata_section(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        output.set(0, nixgen::has_metadata_section(currObj.metadata()));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        output.set(0, nixgen::open_metadata_section(currObj.metadata()));
    }

    void sources(const extractor &input, infusor &output)
    {
        nix::Source currObj = input.entity<nix::Source>(1);
        std::vector<nix::Source> arr = currObj.sources();

        const mwSize size = static_cast<mwSize>(arr.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < arr.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(arr[i])));
        }

        output.set(0, lst);
    }

} // namespace nixsource