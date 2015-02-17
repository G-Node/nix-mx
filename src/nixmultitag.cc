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
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "units", "featureCount", "sourceCount", "referenceCount" });
        sb.set(currMTag.id());
        sb.set(currMTag.type());
        sb.set(currMTag.name());
        sb.set(currMTag.definition());
        sb.set(currMTag.units());
        sb.set(currMTag.featureCount());
        sb.set(currMTag.sourceCount());
        sb.set(currMTag.referenceCount());

        output.set(0, sb.array());
    }

    void open_references(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currMTag.getReference(input.str(2))));
    }

    void open_positions(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currMTag.positions()));
    }

    void open_extents(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_data_array(currMTag.extents()));
    }

    void list_references_array(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_data_arrays(currMTag.references()));
    }

    void has_positions(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::has_entity(currMTag.hasPositions(), { "hasPositions" }));
    }

    void list_features(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_features(currMTag.features()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::list_sources(currMTag.sources()));
    }

    void open_source(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_source(currMTag.getSource(input.str(2))));
    }

    void open_features(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_feature(currMTag.getFeature(input.str(2))));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::MultiTag currMTag = input.entity<nix::MultiTag>(1);
        output.set(0, nixgen::open_metadata_section(currMTag.metadata()));
    }

} // namespace nixmultitag