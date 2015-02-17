#include "MXBlock.h"
#include "MXGenerics.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixblock {

    void describe(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_describe\n");
        nix::Block block = input.entity<nix::Block>(1);

        struct_builder sb({ 1 }, { "id", "type", "name", "sourceCount", "dataArrayCount", "tagCount", "multiTagCount" });

        sb.set(block.id());
        sb.set(block.type());
        sb.set(block.name());
        sb.set(block.sourceCount());
        sb.set(block.dataArrayCount());
        sb.set(block.tagCount());
        sb.set(block.multiTagCount());

        output.set(0, sb.array());
    }

    void open_data_array(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_open_data_array\n");
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, gen::open_data_array(block.getDataArray(input.str(2))));
    }

    void list_data_arrays(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_list_data_arrays\n");
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, gen::list_data_arrays(block.dataArrays()));
    }

    void list_sources(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_list_sources\n");
        nix::Block currSource = input.entity<nix::Block>(1);
        output.set(0, gen::list_sources(currSource.sources()));
    }

    void open_source(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_open_source\n");
        nix::Block currSource = input.entity<nix::Block>(1);
        output.set(0, gen::open_source(currSource.getSource(input.str(2))));
    }

    void has_tag(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_has_tag\n");
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, gen::has_entity(block.hasTag(input.str(2)), { "hasTag" }));
    }

    void open_tag(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_open_tag\n");
        nix::Block block = input.entity<nix::Block>(1);
        nix::Tag currTag = block.getTag(input.str(2));
        handle currBlockTagHandle = handle(currTag);
        output.set(0, currBlockTagHandle);
    }

    void list_tags(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_list_tags\n");

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
        mexPrintf("[+] block_has_multi_tag\n");
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, gen::has_entity(block.hasMultiTag(input.str(2)), { "hasMultiTag" }));
    }

    void open_multi_tag(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_open_multi_tag\n");
        nix::Block block = input.entity<nix::Block>(1);
        nix::MultiTag currMultiTag = block.getMultiTag(input.str(2));
        handle currBlockMultiTagHandle = handle(currMultiTag);
        output.set(0, currBlockMultiTagHandle);
    }

    void list_multi_tags(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_list_multi_tags\n");

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

    void open_metadata_section(const extractor &input, infusor &output)
    {
        mexPrintf("[+] block_open_metadata_section\n");
        nix::Block currTag = input.entity<nix::Block>(1);
        output.set(0, gen::open_metadata_section(currTag.metadata()));
    }



} // namespace nixblock