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
        nix::Tag currTag = input.entity<nix::Tag>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "position", "extent",
            "units", "featureCount", "sourceCount", "referenceCount" });

        sb.set(currTag.id());
        sb.set(currTag.type());
        sb.set(currTag.name());
        sb.set(currTag.definition());
        sb.set(currTag.position());
        sb.set(currTag.extent());
        sb.set(currTag.units());
        sb.set(currTag.featureCount());
        sb.set(currTag.sourceCount());
        sb.set(currTag.referenceCount());

        output.set(0, sb.array());
    }

    void open_data_array(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::open_data_array(currTag.getReference(input.str(2))));
    }

    void list_references_array(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_data_arrays(currTag.references()));
    }

    void list_features(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_features(currTag.features()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::list_sources(currTag.sources()));
    }

    void open_feature(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::open_feature(currTag.getFeature(input.str(2))));
    }

    void open_source(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::open_source(currTag.getSource(input.str(2))));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Tag currTag = input.entity<nix::Tag>(1);
        output.set(0, nixgen::open_metadata_section(currTag.metadata()));
    }

} // namespace nixtag