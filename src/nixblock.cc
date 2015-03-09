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

    void create_data_array(const extractor &input, infusor &output)
    {
        nix::Block block = input.entity<nix::Block>(1);

        std::string name = input.str(2);
        std::string type = input.str(3);
        nix::DataType dtype = nix::DataType::Double; // FIXME nix::string_to_data_type(input.str(3));
        nix::NDSize size = input.ndsize(5);

        nix::DataArray dt = block.createDataArray(name, type, dtype, size);
        output.set(0, dt);
    }

} // namespace nixblock
