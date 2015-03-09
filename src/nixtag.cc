#include "nixtag.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixtag {

    mxArray *describe(const nix::Tag &tag)
    {
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "extent", "units" });

        sb.set(tag.id());
        sb.set(tag.type());
        sb.set(tag.name());
        sb.set(tag.definition());
        sb.set(tag.position());
        sb.set(tag.extent());
        sb.set(tag.units());

        return sb.array();
    }

    void retrieve_data(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        double index = input.num<double>(2);

        mxArray *data = nixgen::dataset_read_all(currObj.retrieveData(index));
        output.set(0, data);
    }

    void retrieve_feature_data(const extractor &input, infusor &output) {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        double index = input.num<double>(2);

        mxArray *data = nixgen::dataset_read_all(currObj.retrieveFeatureData(index));
        output.set(0, data);
    }

} // namespace nixtag
