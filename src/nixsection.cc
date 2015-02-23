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
    output.set(0, nixgen::get_handle_or_none(section.link()));
}

void parent(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    output.set(0, nixgen::get_handle_or_none(section.parent()));
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
    output.set(0, sections);
}

void has_property(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    output.set(0, nixgen::has_entity(section.hasProperty(input.str(2)), { "hasProperty" }));
}

void list_properties(const extractor &input, infusor &output)
{
    nix::Section section = input.entity<nix::Section>(1);
    std::vector<nix::Property> properties = section.properties();

    const mwSize size = static_cast<mwSize>(properties.size());
    mxArray *lst = mxCreateCellArray(1, &size);

    for (size_t i = 0; i < properties.size(); i++) {

        nix::Property pr = properties[i];
        std::vector<nix::Value> values = pr.values();

        mxArray *mx_values = make_mx_array(values);

        struct_builder sb({ 1 }, {
            "name", "id", "definition", "mapping", "unit", "values"
        });

        sb.set(pr.name());
        sb.set(pr.id());
        sb.set(pr.definition());
        sb.set(pr.mapping());
        sb.set(pr.unit());
        sb.set(mx_values);

        mxSetCell(lst, i, sb.array());
    }

    output.set(0, lst);
}

} // namespace nixsection
