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

typedef void(*fn_t)(const extractor &input, infusor &output);

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
    { "Block::listSources", nixblock::list_sources },
    { "Block::listTags", nixblock::list_tags },
    { "Block::listMultiTags", nixblock::list_multi_tags },
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
    { "Tag::openMetadataSection", nixtag::open_metadata_section },
    { "Tag::retrieveData", nixtag::retrieve_data },
    { "Tag::featureRetrieveData", nixtag::retrieve_feature_data },

    // Multi Tag
    { "MultiTag::describe", nixmultitag::describe },
    { "MultiTag::listReferences", nixmultitag::list_references_array },
    { "MultiTag::listFeatures", nixmultitag::list_features },
    { "MultiTag::listSources", nixmultitag::list_sources },
    { "MultiTag::openMetadataSection", nixmultitag::open_metadata_section },
    { "MultiTag::retrieveData", nixmultitag::retrieve_data },
    { "MultiTag::featureRetrieveData", nixmultitag::retrieve_feature_data },

    // Source
    { "Source::describe", nixsource::describe },
    { "Source::listSources", nixsource::list_sources },
    { "Source::openMetadataSection", nixsource::open_metadata_section },

    // Feature
    { "Feature::describe", nixfeature::describe },
    { "Feature::linkType", nixfeature::link_type },
    { "Feature::openData", nixfeature::open_data },

    // Section
    { "Section::describe", nixsection::describe },
    { "Section::listSections", nixsection::list_sections },
    { "Section::listProperties", nixsection::list_properties }
};

//glue "globals"
std::once_flag init_flag;
static glue::registry *methods = nullptr;

static void on_exit() {
#ifdef DEBUG_GLUE
    mexPrintf("[GLUE] deleting handlers!\n");
#endif

    delete methods;
}

#define GETTER(type, class, name) static_cast<type(class::*)()const>(&class::name)
#define GETBYSTR(type, class, name) static_cast<type(class::*)(const std::string &)const>(&class::name)
#define GETCONTENT(type, class, name) static_cast<type(class::*)()const>(&class::name)
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
            .reg("createTag", &nix::Block::createTag)
            .reg("sources", &nix::Block::sources)
            .reg("tags", &nix::Block::tags)
            .reg("multiTags", &nix::Block::multiTags)
            .reg("hasTag", GETBYSTR(bool, nix::Block, hasTag))
            .reg("hasMultiTag", GETBYSTR(bool, nix::Block, hasMultiTag))
            .reg("openDataArray", GETBYSTR(nix::DataArray, nix::Block, getDataArray))
            .reg("openSource", GETBYSTR(nix::Source, nix::Block, getSource))
            .reg("openTag", GETBYSTR(nix::Tag, nix::Block, getTag))
            .reg("openMultiTag", GETBYSTR(nix::MultiTag, nix::Block, getMultiTag));

        classdef<nix::DataArray>("DataArray", methods)
            .reg("sources", static_cast<std::vector<nix::Source>(nix::base::EntityWithSources<nix::base::IDataArray>::*)(std::function<bool(const nix::Source &)>)const>(&nix::base::EntityWithSources<nix::base::IDataArray>::sources));

        classdef<nix::Source>("Source", methods)
            .reg("sources", &nix::Source::sources)
            .reg("openSource", GETBYSTR(nix::Source, nix::Source, getSource));

        classdef<nix::Tag>("Tag", methods)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::Tag, references))
            .reg("features", &nix::Tag::features)
            .reg("sources", static_cast<std::vector<nix::Source>(nix::base::EntityWithSources<nix::base::ITag>::*)(std::function<bool(const nix::Source &)>)const>(&nix::base::EntityWithSources<nix::base::ITag>::sources))
            .reg("openReferenceDataArray", GETBYSTR(nix::DataArray, nix::Tag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::Tag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::Tag, getSource));

        classdef<nix::MultiTag>("MultiTag", methods)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::MultiTag, references))
            .reg("features", &nix::MultiTag::features)
            .reg("sources", static_cast<std::vector<nix::Source>(nix::base::EntityWithSources<nix::base::IMultiTag>::*)(std::function<bool(const nix::Source &)>)const>(&nix::base::EntityWithSources<nix::base::IMultiTag>::sources))
            .reg("hasPositions", GETCONTENT(bool, nix::MultiTag, hasPositions))
            .reg("openPositions", GETCONTENT(nix::DataArray, nix::MultiTag, positions))
            .reg("openExtents", GETCONTENT(nix::DataArray, nix::MultiTag, extents))
            .reg("openReferences", GETBYSTR(nix::DataArray, nix::MultiTag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::MultiTag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::MultiTag, getSource));

        classdef<nix::Section>("Section", methods)
            .reg("sections", &nix::Section::sections)
            .reg("openSection", GETBYSTR(nix::Section, nix::Section, getSection))
            .reg("hasProperty", GETBYSTR(bool, nix::Section, hasProperty))
            .reg("hasSection", GETBYSTR(bool, nix::Section, hasSection))
            .reg("link", GETCONTENT(nix::Section, nix::Section, link))
            .reg("parent", GETCONTENT(nix::Section, nix::Section, parent));

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

    }
    catch (const std::invalid_argument &e) {
        mexErrMsgIdAndTxt("nix:arg:inval", e.what());
    }
    catch (const std::exception &e) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", e.what());
    }
    catch (...) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "unkown exception");
    }

    if (!processed) {
        mexErrMsgIdAndTxt("nix:arg:dispatch", "Unkown command");
    }
}

