#include "nixsection.h"

#include "mex.h"
#include <nix.hpp>

#include "nixgen.h"
#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"


namespace nixsection {

void describe(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);

    struct_builder sb({ 1 }, { 
        "name", "id", "type", "repository", "mapping"
    });

    sb.set(section.name());
    sb.set(section.id());
    sb.set(section.type());
    sb.set(section.repository());
    sb.set(section.mapping());

    output.set(0, sb.array());
}

void link(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);

    nix::Section linked = section.link();
    handle lh = handle(linked);
    output.set(0, lh);
}

void parent(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);

    nix::Section parent = section.parent();
    handle lh = handle(parent);
    output.set(0, lh);
}

void has_section(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    output.set(0, nixgen::has_entity(section.hasSection(input.str(2)), { "hasSection" }));
}

void open_section(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    nix::Section sec = section.getSection(input.str(2));
    handle h = handle(sec);
    output.set(0, h);
}

void list_sections(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    std::vector<nix::Section> sections = section.sections();

    struct_builder sb({ sections.size() }, { "name", "id", "type" });

    for (const auto &b : sections) {
        sb.set(b.name());
        sb.set(b.id());
        sb.set(b.type());

        sb.next();
    }

    output.set(0, sb.array());
}

void sections(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    std::vector<nix::Section> sections = section.sections();

    const mwSize size = static_cast<mwSize>(sections.size());
    mxArray *lst = mxCreateCellArray(1, &size);

    for (int i = 0; i < sections.size(); i++) {
        mxSetCell(lst, i, make_mx_array(handle(sections[i])));
    }

    output.set(0, lst);
}

void has_property(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    output.set(0, nixgen::has_entity(section.hasProperty(input.str(2)), { "hasProperty" }));
}

void list_properties(const extractor &input, infusor &output)
{

}

} // namespace nixfile