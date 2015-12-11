#include "nixmultitag.h"
#include "mkarray.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixmultitag {

    mxArray *describe(const nix::MultiTag &multitag)
    {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units" });

        sb.set(multitag.id());
        sb.set(multitag.type());
        sb.set(multitag.name());
        sb.set(multitag.definition());
        sb.set(multitag.units());

        return sb.array();
    }

    void add_reference(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.addReference(input.str(2));
    }

    void add_source(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.addSource(input.str(2));
    }

    void create_feature(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);

        nix::Feature newFeat = currObj.createFeature(input.str(2), input.ltype(3));
        output.set(0, handle(newFeat));
    }

    void retrieve_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveData(p_index, f_index));
        output.set(0, data);
    }

    void retrieve_feature_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array_from_ds(currObj.retrieveFeatureData(p_index, f_index));
        output.set(0, data);
    }

    void add_positions(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        currObj.positions(input.str(2));
    }

} // namespace nixmultitag
