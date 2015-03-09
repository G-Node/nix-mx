#include "nixmultitag.h"
#include "nixgen.h"

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

    void retrieve_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = nixgen::dataset_read_all(currObj.retrieveData(p_index, f_index));
        output.set(0, data);
    }

    void retrieve_feature_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = nixgen::dataset_read_all(currObj.retrieveFeatureData(p_index, f_index));
        output.set(0, data);
    }

} // namespace nixmultitag
