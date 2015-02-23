#include "nixmultitag.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixmultitag {

    void describe(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units" });
        sb.set(currObj.id());
        sb.set(currObj.type());
        sb.set(currObj.name());
        sb.set(currObj.definition());
        sb.set(currObj.units());

        output.set(0, sb.array());
    }

    void open_references(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currObj.getReference(input.str(2))));
    }

    void open_positions(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currObj.positions()));
    }

    void open_extents(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currObj.extents()));
    }

    void list_references_array(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_data_arrays(currObj.references()));
    }

    void has_positions(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::has_entity(currObj.hasPositions(), { "hasPositions" }));
    }

    void list_features(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_features(currObj.features()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_sources(currObj.sources()));
    }

    void open_source(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_source(currObj.getSource(input.str(2))));
    }

    void open_features(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_feature(currObj.getFeature(input.str(2))));
    }

    void has_metadata_section(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::has_metadata_section(currObj.metadata()));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        nix::Section sec = currObj.metadata();

        if (sec) {
            handle lh = handle(sec);
            output.set(0, lh);
        }
        else
        {
            output.set(0, uint64_t(0));
        }
    }

    void references(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::DataArray> arr = currObj.references();
        output.set(0, arr);
    }

    void features(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::Feature> arr = currObj.features();
        output.set(0, arr);
    }

    void sources(const extractor &input, infusor &output)
    {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        std::vector<nix::Source> arr = currObj.sources();

        output.set(0, arr);
    }

    void retrieve_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array(currObj.retrieveData(p_index, f_index));
        output.set(0, data);
    }

    void retrieve_feature_data(const extractor &input, infusor &output) {
        nix::MultiTag currObj = input.entity<nix::MultiTag>(1);
        double p_index = input.num<double>(2);
        double f_index = input.num<double>(3);

        mxArray *data = make_mx_array(currObj.retrieveFeatureData(p_index, f_index));
        output.set(0, data);
    }

} // namespace nixmultitag
