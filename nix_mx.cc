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
#define GETSOURCES(base__) static_cast<std::vector<nix::Source>(nix::base::EntityWithSources<nix::base::base__>::*)(std::function<bool(const nix::Source &)>)const>(&nix::base::EntityWithSources<nix::base::base__>::sources)
//required to open nix::Section from DataArray, normal GETCONTENT leads to a compiler error with Visual Studio 12
#define GETMETADATA(base__) static_cast<nix::Section(nix::base::EntityWithMetadata<nix::base::base__>::*)()const>(&nix::base::EntityWithMetadata<nix::base::base__>::metadata)
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

        methods->add("Entity::destroy", entity_destroy);
        methods->add("Entity::updatedAt", entity_updated_at);

        classdef<nix::File>("File", methods)
            .desc(&nixfile::describe)
            .add("open", nixfile::open)
            .reg("blocks", GETTER(std::vector<nix::Block>, nix::File, blocks))
            .reg("sections", GETTER(std::vector<nix::Section>, nix::File, sections))
            .reg("deleteBlock", REMOVER(nix::Block, nix::File, deleteBlock))
            .reg("deleteSection", REMOVER(nix::Section, nix::File, deleteSection))
            .reg("openBlock", GETBYSTR(nix::Block, nix::File, getBlock))
            .reg("openSection", GETBYSTR(nix::Section, nix::File, getSection))
            .reg("createBlock", &nix::File::createBlock)
            .reg("createSection", &nix::File::createSection);

        classdef<nix::Block>("Block", methods)
            .desc(&nixblock::describe)
            .reg("dataArrays", &nix::Block::dataArrays)
            .reg("createSource", &nix::Block::createSource)
            .reg("deleteSource", REMOVER(nix::Source, nix::Block, deleteSource))
            //.reg("createDataArray", static_cast<nix::DataArray(nix::Block::*)(const std::string &, const std::string &, nix::DataType, const nix::NDSize &)>(&nix::Block::createDataArray))
            .reg("createTag", &nix::Block::createTag)
            .reg("createMultiTag", &nix::Block::createMultiTag)
            .reg("sources", &nix::Block::sources)
            .reg("tags", &nix::Block::tags)
            .reg("multiTags", &nix::Block::multiTags)
            .reg("hasTag", GETBYSTR(bool, nix::Block, hasTag))
            .reg("hasMultiTag", GETBYSTR(bool, nix::Block, hasMultiTag))
            .reg("openDataArray", GETBYSTR(nix::DataArray, nix::Block, getDataArray))
            .reg("openSource", GETBYSTR(nix::Source, nix::Block, getSource))
            .reg("openTag", GETBYSTR(nix::Tag, nix::Block, getTag))
            .reg("openMultiTag", GETBYSTR(nix::MultiTag, nix::Block, getMultiTag))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Block, metadata));
        methods->add("Block::createDataArray", nixblock::create_data_array);

        classdef<nix::DataArray>("DataArray", methods)
            .desc(&nixdataarray::describe)
            .reg("sources", GETSOURCES(IDataArray))
            .reg("openMetadataSection", GETMETADATA(IDataArray));
        methods->add("DataArray::readAll", nixdataarray::read_all);
        methods->add("DataArray::writeAll", nixdataarray::write_all);

        classdef<nix::Source>("Source", methods)
            .desc(&nixsource::describe)
            .reg("createSource", &nix::Source::createSource)
            .reg("deleteSource", REMOVER(nix::Source, nix::Source, deleteSource))
            .reg("sources", &nix::Source::sources)
            .reg("openSource", GETBYSTR(nix::Source, nix::Source, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Source, metadata));

        classdef<nix::Tag>("Tag", methods)
            .desc(&nixtag::describe)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::Tag, references))
            .reg("features", &nix::Tag::features)
            .reg("sources", GETSOURCES(ITag))
            .reg("openReferenceDataArray", GETBYSTR(nix::DataArray, nix::Tag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::Tag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::Tag, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Tag, metadata))
            .reg("removeReference", REMOVER(nix::DataArray, nix::Tag, removeReference))
            .reg("removeSource", REMOVER(nix::Source, nix::Tag, removeSource));
        methods->add("Tag::retrieveData", nixtag::retrieve_data);
        methods->add("Tag::featureRetrieveData", nixtag::retrieve_feature_data);
        methods->add("Tag::addReference", nixtag::add_reference);
        methods->add("Tag::addSource", nixtag::add_source);

        classdef<nix::MultiTag>("MultiTag", methods)
            .desc(&nixmultitag::describe)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::MultiTag, references))
            .reg("features", &nix::MultiTag::features)
            .reg("sources", GETSOURCES(IMultiTag))
            .reg("hasPositions", GETCONTENT(bool, nix::MultiTag, hasPositions))
            .reg("openPositions", GETCONTENT(nix::DataArray, nix::MultiTag, positions))
            .reg("openExtents", GETCONTENT(nix::DataArray, nix::MultiTag, extents))
            .reg("openReferences", GETBYSTR(nix::DataArray, nix::MultiTag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::MultiTag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::MultiTag, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::MultiTag, metadata))
            .reg("removeReference", REMOVER(nix::DataArray, nix::MultiTag, removeReference))
            .reg("removeSource", REMOVER(nix::Source, nix::MultiTag, removeSource));
        methods->add("MultiTag::retrieveData", nixmultitag::retrieve_data);
        methods->add("MultiTag::featureRetrieveData", nixmultitag::retrieve_feature_data);
        methods->add("MultiTag::addReference", nixmultitag::add_reference);
        methods->add("MultiTag::addSource", nixmultitag::add_source);

        classdef<nix::Section>("Section", methods)
            .desc(&nixsection::describe)
            .reg("sections", &nix::Section::sections)
            .reg("openSection", GETBYSTR(nix::Section, nix::Section, getSection))
            .reg("hasProperty", GETBYSTR(bool, nix::Section, hasProperty))
            .reg("hasSection", GETBYSTR(bool, nix::Section, hasSection))
            .reg("link", GETCONTENT(nix::Section, nix::Section, link))
            .reg("parent", GETCONTENT(nix::Section, nix::Section, parent));
        methods->add("Section::properties", nixsection::properties);

        classdef<nix::Feature>("Feature", methods)
            .desc(&nixfeature::describe)
            .reg("openData", GETCONTENT(nix::DataArray, nix::Feature, data));
        methods->add("Feature::linkType", nixfeature::link_type);

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

