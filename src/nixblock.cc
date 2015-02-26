#include "nixblock.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixblock {

    void describe(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "definition" });

        sb.set(block.id());
        sb.set(block.type());
        sb.set(block.name());
        sb.set(block.definition());

        output.set(0, sb.array());
    }

    void list_data_arrays(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::list_data_arrays(block.dataArrays()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::Block currSource = input.entity<nix::Block>(1);
        output.set(0, nixgen::list_sources(currSource.sources()));
    }

    void has_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_entity(block.hasTag(input.str(2)), { "hasTag" }));
    }

    void list_tags(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::Tag> arr = block.tags();

        struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "position", "extent", "units" });

        for (const auto &da : arr) {
            sb.set(da.id());
            sb.set(da.type());
            sb.set(da.name());
            sb.set(da.definition());
            sb.set(da.position());
            sb.set(da.extent());
            sb.set(da.units());

            sb.next();
        }
        output.set(0, sb.array());
    }

    void has_multi_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_entity(block.hasMultiTag(input.str(2)), { "hasMultiTag" }));
    }

    void list_multi_tags(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::MultiTag> arr = block.multiTags();

        struct_builder sb({ arr.size() }, { "id", "type", "name", "definition", "units" });

        for (const auto &da : arr) {
            sb.set(da.id());
            sb.set(da.type());
            sb.set(da.name());
            sb.set(da.definition());
            sb.set(da.units());

            sb.next();
        }
        output.set(0, sb.array());
    }

    void has_metadata_section(const extractor &input, infusor &output)
    {
        nix::Block currObj = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_metadata_section(currObj.metadata()));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Block currObj = input.entity<nix::Block>(1);
        output.set(0, nixgen::get_handle_or_none(currObj.metadata()));
    }

} // namespace nixblock
