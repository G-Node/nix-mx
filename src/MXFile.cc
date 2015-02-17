#include "MXFile.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixfile {

void open(const extractor &input, infusor &output)
{
	mexPrintf("[+] open_file\n");

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

void describe(const extractor &input, infusor &output)
{
	mexPrintf("[+] file_describe\n");
	nix::File fd = input.entity<nix::File>(1);

	struct_builder sb({ 1 }, { "blockCount", "sectionCount" });

	sb.set(fd.blockCount());
	sb.set(fd.sectionCount());

	output.set(0, sb.array());
}

void list_blocks(const extractor &input, infusor &output)
{
	mexPrintf("[+] list_blocks\n");
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

void open_block(const extractor &input, infusor &output)
{
	mexPrintf("[+] open_block\n");
	nix::File nf = input.entity<nix::File>(1);
	nix::Block block = nf.getBlock(input.str(2));
	handle bb = handle(block);
	output.set(0, bb);
}

void list_sections(const extractor &input, infusor &output)
{
	mexPrintf("[+] list_sections\n");
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

void open_section(const extractor &input, infusor &output)
{
	mexPrintf("[+] open_section\n");
	nix::File nf = input.entity<nix::File>(1);
	nix::Section sec = nf.getSection(input.str(2));
	handle bb = handle(sec);
	output.set(0, bb);
}

} // namespace nixfile