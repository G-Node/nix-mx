#include "MXFeature.h"
#include "MXGenerics.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfeature {

    void describe(const extractor &input, infusor &output)
    {
        mexPrintf("[+] feature_describe\n");
        nix::Feature currFeat = input.entity<nix::Feature>(1);
        struct_builder sb({ 1 }, { "id" });
        sb.set(currFeat.id());
        output.set(0, sb.array());
    }

    void open_data(const extractor &input, infusor &output)
    {
        mexPrintf("[+] feature_open_data\n");
        nix::Feature currFeat = input.entity < nix::Feature >(1);
        output.set(0, gen::open_data_array(currFeat.data()));
    }

    void link_type(const extractor &input, infusor &output)
    {
        mexPrintf("[+] feature_link_type\n");
        nix::Feature currFeat = input.entity<nix::Feature>(1);
        //TODO properly implement link type
        struct_builder sb({ 1 }, { "linkType" });
        sb.set("linkType");
        output.set(0, sb.array());
    }

} // namespace nixfeature