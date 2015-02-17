#include "nixsection.h"

#include "mex.h"
#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"


namespace nixsection {

void describe(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);

    struct_builder sb({ 1 }, { 
        "repository", "mapping", "sectionCount", "propertyCount" 
    });

    sb.set(section.repository());
    sb.set(section.mapping());
    sb.set(section.sectionCount());
    sb.set(section.propertyCount());

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
    output.set(0, has_entity(section.hasSection(input.str(2)), { "hasSection" }));
}

void open_section(const extractor &input, infusor &output);

void list_sections(const extractor &input, infusor &output);

void has_property(const extractor &input, infusor &output);

void list_properties(const extractor &input, infusor &output);

} // namespace nixfile