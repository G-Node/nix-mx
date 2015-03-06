#include "nixfile.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfile {

void open(const extractor &input, infusor &output)
{
    std::string name = input.str(1);
    uint8_t omode = input.num<uint8_t>(2);
    nix::FileMode mode;

    switch (omode) {
    case 0: mode = nix::FileMode::ReadOnly; break;
    case 1: mode = nix::FileMode::ReadWrite; break;
    case 2: mode = nix::FileMode::Overwrite; break;
    default: throw std::invalid_argument("unkown open mode");
    }

    nix::File fn = nix::File::open(name, mode);
    handle h = handle(fn);

    output.set(0, h);
}

mxArray *describe(const nix::File &fd) {
    struct_builder sb({ 1 }, { "format", "version", "location", "createdAt", "updatedAt" });
    sb.set(fd.format());
    sb.set(fd.version());
    sb.set(fd.location());
    sb.set(static_cast<uint64_t>(fd.createdAt()));
    sb.set(static_cast<uint64_t>(fd.updatedAt()));
    return sb.array();
}


void list_blocks(const extractor &input, infusor &output)
{
    nix::File fd = input.entity<nix::File>(1);

    std::vector<nix::Block> blocks = fd.blocks();

    struct_builder sb({ blocks.size() }, { "name", "id", "type" });

    for (const auto &b : blocks) {
        sb.set(b.name());
        sb.set(b.id());
        sb.set(b.type());

        sb.next();
    }

    output.set(0, sb.array());
}

void list_sections(const extractor &input, infusor &output)
{
    nix::File fd = input.entity<nix::File>(1);

    std::vector<nix::Section> secs = fd.sections();

    struct_builder sb({ secs.size() }, { "name", "id", "type" });

    for (const auto &b : secs) {
        sb.set(b.name());
        sb.set(b.id());
        sb.set(b.type());

        sb.next();
    }

    output.set(0, sb.array());
}

void create_block(const extractor &input, infusor &output)
{
    nix::File currObj = input.entity<nix::File>(1);
    nix::Block newBlock = currObj.createBlock(input.str(2), input.str(3));

    handle nbh = handle(newBlock);
    output.set(0, nbh);
}

void create_section(const extractor &input, infusor &output)
{
    nix::File currObj = input.entity<nix::File>(1);
    nix::Section newSection = currObj.createSection(input.str(2), input.str(3));

    handle nsh = handle(newSection);
    output.set(0, nsh);
}

} // namespace nixfile
