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

        struct_builder sb({ 1 }, { "id", "type", "name" });

        sb.set(block.id());
        sb.set(block.type());
        sb.set(block.name());

        output.set(0, sb.array());
    }

    void open_data_array(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::open_data_array(block.getDataArray(input.str(2))));
    }

    void data_arrays(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::DataArray> dataArrays = block.dataArrays();

        const mwSize size = static_cast<mwSize>(dataArrays.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < dataArrays.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(dataArrays[i])));
        }

        output.set(0, lst);
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

    void open_source(const extractor &input, infusor &output)
    {
        nix::Block currSource = input.entity<nix::Block>(1);
        output.set(0, nixgen::open_source(currSource.getSource(input.str(2))));
    }

    void sources(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::Source> sources = block.sources();

        const mwSize size = static_cast<mwSize>(sources.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < sources.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(sources[i])));
        }

        output.set(0, lst);
    }

    void has_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_entity(block.hasTag(input.str(2)), { "hasTag" }));
    }

    void open_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        nix::Tag currTag = block.getTag(input.str(2));
        handle currBlockTagHandle = handle(currTag);
        output.set(0, currBlockTagHandle);
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

    void tags(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::Tag> tags = block.tags();

        const mwSize size = static_cast<mwSize>(tags.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < tags.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(tags[i])));
        }

        output.set(0, lst);
    }

    void has_multi_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_entity(block.hasMultiTag(input.str(2)), { "hasMultiTag" }));
    }

    void open_multi_tag(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        nix::MultiTag currMultiTag = block.getMultiTag(input.str(2));
        handle currBlockMultiTagHandle = handle(currMultiTag);
        output.set(0, currBlockMultiTagHandle);
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

    void multitags(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);
        std::vector<nix::MultiTag> arr = block.multiTags();

        const mwSize size = static_cast<mwSize>(arr.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (size_t i = 0; i < arr.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(arr[i])));
        }

        output.set(0, lst);
    }

    void has_metadata_section(const extractor &input, infusor &output)
    {
        nix::Block currObj = input.entity<nix::Block>(1);
        output.set(0, nixgen::has_metadata_section(currObj.metadata()));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Block currObj = input.entity<nix::Block>(1);
        output.set(0, nixgen::open_metadata_section(currObj.metadata()));
    }

} // namespace nixblock
