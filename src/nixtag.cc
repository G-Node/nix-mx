#include "nixtag.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixtag {

    void describe(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "extent", "units" });

        sb.set(currObj.id());
        sb.set(currObj.type());
        sb.set(currObj.name());
        sb.set(currObj.definition());
        sb.set(currObj.position());
        sb.set(currObj.extent());
        sb.set(currObj.units());

        output.set(0, sb.array());
    }

    void list_references_array(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_data_arrays(currObj.references()));
    }

    void list_features(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_features(currObj.features()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_sources(currObj.sources()));
    }

    void has_metadata_section(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        output.set(0, nixgen::has_metadata_section(currObj.metadata()));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Tag currObj = input.entity<nix::Tag>(1);
        output.set(0, nixgen::get_handle_or_none(currObj.metadata()));
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
