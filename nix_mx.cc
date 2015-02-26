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

#include <utils/glue.h>

#include <mutex>

// *** functions ***

static void entity_destroy(const extractor &input, infusor &output)
{
    handle h = input.hdl(1);
    h.destroy();
}

static void entity_updated_at(const extractor &input, infusor &output)
{
    const handle::entity *curr = input.hdl(1).the_entity();
    time_t uat = curr->updated_at();
    uint64_t the_time = static_cast<uint64_t>(uat);
    output.set(0, the_time);
}

// *** ***

typedef void (*fn_t)(const extractor &input, infusor &output);

struct fendpoint {

fendpoint(std::string name, fn_t fn) : name(name), fn(fn) {}

    std::string name;
    fn_t fn;
};

const std::vector<fendpoint> funcs = {
        { "Entity::destroy", entity_destroy },
        { "Entity::updatedAt", entity_updated_at },

        // File
        { "File::open", nixfile::open },
        { "File::describe", nixfile::describe },
        { "File::listBlocks", nixfile::list_blocks },
        { "File::listSections", nixfile::list_sections },
        { "File::createBlock", nixfile::create_block },
        { "File::createSection", nixfile::create_section },

        // Block
        { "Block::describe", nixblock::describe },
        { "Block::listDataArrays", nixblock::list_data_arrays },
        { "Block::openDataArray", nixblock::open_data_array },
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
        { "Block::hasMetadataSection", nixblock::has_metadata_section },
        { "Block::openMetadataSection", nixblock::open_metadata_section },

        // Data Array
        { "DataArray::describe", nixdataarray::describe },
        { "DataArray::readAll", nixdataarray::read_all },
        { "DataArray::hasMetadataSection", nixdataarray::has_metadata_section },
        { "DataArray::openMetadataSection", nixdataarray::open_metadata_section },
        { "DataArray::sources", nixdataarray::sources },

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
        { "Tag::hasMetadataSection", nixtag::has_metadata_section },
        { "Tag::openMetadataSection", nixtag::open_metadata_section },
        { "Tag::retrieveData", nixtag::retrieve_data },
        { "Tag::featureRetrieveData", nixtag::retrieve_feature_data },

        // Multi Tag
        { "MultiTag::describe", nixmultitag::describe },
        { "MultiTag::listReferences", nixmultitag::list_references_array },
        { "MultiTag::listFeatures", nixmultitag::list_features },
        { "MultiTag::listSources", nixmultitag::list_sources },
        { "MultiTag::references", nixmultitag::references },
        { "MultiTag::features", nixmultitag::features },
        { "MultiTag::sources", nixmultitag::sources },
        { "MultiTag::hasPositions", nixmultitag::has_positions },
        { "MultiTag::openPositions", nixmultitag::open_positions },
        { "MultiTag::openExtents", nixmultitag::open_extents },
        { "MultiTag::openReferences", nixmultitag::open_references },
        { "MultiTag::openFeature", nixmultitag::open_features },
        { "MultiTag::openSource", nixmultitag::open_source },
        { "MultiTag::hasMetadataSection", nixmultitag::has_metadata_section },
        { "MultiTag::openMetadataSection", nixmultitag::open_metadata_section },
        { "MultiTag::retrieveData", nixmultitag::retrieve_data },
        { "MultiTag::featureRetrieveData", nixmultitag::retrieve_feature_data },

        // Source
        { "Source::describe", nixsource::describe },
        { "Source::listSources", nixsource::list_sources },
        { "Source::openSource", nixsource::open_source },
        { "Source::sources", nixsource::sources },
        { "Source::hasMetadataSection", nixsource::has_metadata_section },
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

//glue "globals"
std::once_flag init_flag;
static glue::registry *methods = nullptr;

static void on_exit() {
#ifdef DEBUG_GLUE
    mexPrintf("[GLUE] deleting hanlders!\n");
#endif

    delete methods;
}

#define GETTER(type, class, name) static_cast<type(class::*)()const>(&class::name)
#define GETBYSTR(type, class, name) static_cast<type(class::*)(const std::string &)const>(&class::name)
#define REMOVER(type, class, name) static_cast<bool(class::*)(const std::string&)>(&class::name)

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

    std::call_once(init_flag, []() {
        using namespace glue;

        #ifdef DEBUG_GLUE
        mexPrintf("[GLUE] Registering classdefs...\n");
        #endif

        methods = new registry{};

        classdef<nix::File>("File", methods)
            .reg("blocks", GETTER(std::vector<nix::Block>, nix::File, blocks))
            .reg("sections", GETTER(std::vector<nix::Section>, nix::File, sections))
            .reg("deleteBlock", REMOVER(nix::Block, nix::File, deleteBlock))
            .reg("deleteSection", REMOVER(nix::Section, nix::File, deleteSection))
            .reg("openBlock", GETBYSTR(nix::Block, nix::File, getBlock))
            .reg("openSection", GETBYSTR(nix::Section, nix::File, getSection));

        classdef<nix::Block>("Block", methods)
            .reg("dataArrays", &nix::Block::dataArrays)
            .reg("createTag", &nix::Block::createTag);

        mexAtExit(on_exit);
    });

    bool processed = false;

    try {
        processed = methods->dispatch(cmd, input, output);

        #ifdef DEBUG_GLUE
        if (processed) {
            mexPrintf("[GLUE] %s: processed by glue.\n", cmd.c_str());
        }
        #endif

        for (const auto &fn : funcs) {

            if (processed) {
                break;
            }

            if (fn.name == cmd) {
                fn.fn(input, output);
                processed = true;
            }
        }

    } catch (const std::invalid_argument &e) {
        mexErrMsgIdAndTxt("nix:arg:inval", e.what());
    } catch (const std::exception &e) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", e.what());
    } catch (...) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "unkown exception");
    }

    if (!processed) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "Unkown command");
    }
}

