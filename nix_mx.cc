#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "nix2mx.h"

#include "nixfile.h"
#include "nixsection.h"
#include "nixblock.h"
#include "nixdataarray.h"
#include "nixsource.h"
#include "nixfeature.h"
#include "nixtag.h"
#include "nixmultitag.h"

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    handle h = input.hdl(1);
    h.destroy();
}

// *** ***

typedef void (*fn_t)(const extractor &input, infusor &output);

struct fendpoint {

fendpoint(std::string name, fn_t fn) : name(name), fn(fn) {}

    std::string name;
    fn_t fn;
};

const std::vector<fendpoint> funcs = {
        {"Entity::destroy", entity_destroy},

        // File
        { "File::open", nixfile::open },
        { "File::describe", nixfile::describe },
        { "File::listBlocks", nixfile::list_blocks },
        { "File::openBlock", nixfile::open_block },
        { "File::blocks", nixfile::blocks },
        { "File::listSections", nixfile::list_sections },
        { "File::openSection", nixfile::open_section },
        { "File::sections", nixfile::sections },

        // Block
        { "Block::describe", nixblock::describe },
        { "Block::listDataArrays", nixblock::list_data_arrays },
        { "Block::openDataArray", nixblock::open_data_array },
        { "Block::dataArrays", nixblock::data_arrays },
        { "Block::listSources", nixblock::list_sources },
        { "Block::openSource", nixblock::open_source },
        { "Block::sources", nixblock::sources },
        { "Block::hasTag", nixblock::has_tag },
        { "Block::listTags", nixblock::list_tags },
        { "Block::openTag", nixblock::open_tag },
        { "Block::tags", nixblock::tags },
        { "Block::hasMultiTag", nixblock::has_multi_tag },
        { "Block::listMultiTags", nixblock::list_multi_tags },
        { "Block::openMultiTag", nixblock::open_multi_tag },
        { "Block::multiTags", nixblock::multitags },
        { "Block::openMetadataSection", nixblock::open_metadata_section },

        // Data Array
        { "DataArray::describe", nixdataarray::describe },
        { "DataArray::readAll", nixdataarray::read_all },
        { "DataArray::openMetadataSection", nixdataarray::open_metadata_section },

        // Tag
        { "Tag::describe", nixtag::describe },
        { "Tag::listReferences", nixtag::list_references_array },
        { "Tag::listFeatures", nixtag::list_features },
        { "Tag::listSources", nixtag::list_sources },
        { "Tag::references", nixtag::references },
        { "Tag::features", nixtag::features },
        { "Tag::sources", nixtag::sources },
        { "Tag::openReferenceDataArray", nixtag::open_data_array },
        { "Tag::openFeature", nixtag::open_feature },
        { "Tag::openSource", nixtag::open_source },
        { "Tag::openMetadataSection", nixtag::open_metadata_section },

        // Multi Tag
        { "MultiTag::describe", nixmultitag::describe },
        { "MultiTag::listReferences", nixmultitag::list_references_array },
        { "MultiTag::listFeatures", nixmultitag::list_features },
        { "MultiTag::listSources", nixmultitag::list_sources },
        { "MultiTag::hasPositions", nixmultitag::has_positions },
        { "MultiTag::openPositions", nixmultitag::open_positions },
        { "MultiTag::openExtents", nixmultitag::open_extents },
        { "MultiTag::openReferences", nixmultitag::open_references },
        { "MultiTag::openFeature", nixmultitag::open_features },
        { "MultiTag::openSource", nixmultitag::open_source },
        { "MultiTag::openMetadataSection", nixmultitag::open_metadata_section },

        // Source
        { "Source::describe", nixsource::describe },
        { "Source::listSources", nixsource::list_sources },
        { "Source::openSource", nixsource::open_source },
        { "Source::openMetadataSection", nixsource::open_metadata_section },

        // Feature
        { "Feature::describe", nixfeature::describe },
        { "Feature::linkType", nixfeature::link_type },
        { "Feature::openData", nixfeature::open_data },

        // Section
        { "Section::describe", nixsection::describe },
        { "Section::link", nixsection::link },
        { "Section::parent", nixsection::parent },
        { "Section::hasSection", nixsection::has_section },
        { "Section::openSection", nixsection::open_section },
        { "Section::listSections", nixsection::list_sections },
        { "Section::sections", nixsection::sections },
        { "Section::hasProperty", nixsection::has_property },
        { "Section::listProperties", nixsection::list_properties }
};

// main entry point
void mexFunction(int            nlhs,
                 mxArray       *lhs[],
                 int            nrhs,
                 const mxArray *rhs[])
{
    extractor input(rhs, nrhs);
    infusor   output(lhs, nlhs);

    std::string cmd = input.str(0);

    //mexPrintf("[F] %s\n", cmd.c_str());

    bool processed = false;
    for (const auto &fn : funcs) {
        if (fn.name == cmd) {
            try {
                fn.fn(input, output);
            } catch (const std::invalid_argument &e) {
                mexErrMsgIdAndTxt("nix:arg:inval", e.what());
            } catch (const std::exception &e) {
                mexErrMsgIdAndTxt("nix:arg:dispatch", e.what());
            } catch (...) {
                mexErrMsgIdAndTxt("nix:arg:dispatch", "unkown exception");
            }
            processed = true;
            break;
        }
    }

    if (!processed) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "Unkown command");
    }
}

