// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#include <iostream>
#include <math.h>
#include <string.h>
#include <vector>
#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"
#include "mknix.h"

#include "nixfile.h"
#include "nixsection.h"
#include "nixproperty.h"
#include "nixblock.h"
#include "nixgroup.h"
#include "nixdataarray.h"
#include "nixsource.h"
#include "nixfeature.h"
#include "nixtag.h"
#include "nixmultitag.h"
#include "nixdimensions.h"

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
#define FILTER(type, class, filt, name) static_cast<type(class::*)(filt)const>(&class::name)
#define SETTER(type, class, name) static_cast<void(class::*)(type)>(&class::name)
#define REMOVER(type, class, name) static_cast<bool(class::*)(const std::string&)>(&class::name)
#define GETBYSTR(type, class, name) static_cast<type(class::*)(const std::string &)const>(&class::name)
#define GETCONTENT(type, class, name) static_cast<type(class::*)()const>(&class::name)

//required to operate on DataArray, Visual Studio 12 compiler does not resolve multiple inheritance properly
#define IDATAARRAY(type, iface, attr, name, isconst) static_cast<type(nix::base::iface<nix::base::IDataArray>::*)(attr)isconst>(&nix::base::iface<nix::base::IDataArray>::name)


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
            .reg("hasBlock", GETBYSTR(bool, nix::File, hasBlock))
            .reg("hasSection", GETBYSTR(bool, nix::File, hasSection))
            .reg("deleteBlock", REMOVER(nix::Block, nix::File, deleteBlock))
            .reg("deleteSection", REMOVER(nix::Section, nix::File, deleteSection))
            .reg("openBlock", GETBYSTR(nix::Block, nix::File, getBlock))
            .reg("openSection", GETBYSTR(nix::Section, nix::File, getSection))
            .reg("createBlock", &nix::File::createBlock)
            .reg("createSection", &nix::File::createSection)
            .reg("blockCount", GETTER(nix::ndsize_t, nix::File, blockCount))
            .reg("sectionCount", GETTER(nix::ndsize_t, nix::File, sectionCount))
            .reg("isOpen", GETTER(bool, nix::File, isOpen));
        methods->add("File::fileMode", nixfile::fileMode);
        methods->add("File::validate", nixfile::validate);
        methods->add("File::openBlockIdx", nixfile::openBlockIdx);
        methods->add("File::openSectionIdx", nixfile::openSectionIdx);
        methods->add("File::sectionsFiltered", nixfile::sectionsFiltered);
        methods->add("File::blocksFiltered", nixfile::blocksFiltered);

        classdef<nix::Block>("Block", methods)
            .desc(&nixblock::describe)
            .reg("createSource", &nix::Block::createSource)
            .reg("createTag", &nix::Block::createTag)
            .reg("dataArrays", &nix::Block::dataArrays)
            .reg("sources", &nix::Block::sources)
            .reg("tags", &nix::Block::tags)
            .reg("multiTags", &nix::Block::multiTags)
            .reg("hasDataArray", GETBYSTR(bool, nix::Block, hasDataArray))
            .reg("hasSource", GETBYSTR(bool, nix::Block, hasSource))
            .reg("groups", &nix::Block::groups)
            .reg("hasTag", GETBYSTR(bool, nix::Block, hasTag))
            .reg("hasMultiTag", GETBYSTR(bool, nix::Block, hasMultiTag))
            .reg("hasGroup", GETBYSTR(bool, nix::Block, hasGroup))
            .reg("getGroup", GETBYSTR(nix::Group, nix::Block, getGroup))
            .reg("openDataArray", GETBYSTR(nix::DataArray, nix::Block, getDataArray))
            .reg("openSource", GETBYSTR(nix::Source, nix::Block, getSource))
            .reg("openTag", GETBYSTR(nix::Tag, nix::Block, getTag))
            .reg("openMultiTag", GETBYSTR(nix::MultiTag, nix::Block, getMultiTag))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Block, metadata))
            .reg("setMetadata", SETTER(const std::string&, nix::Block, metadata))
            .reg("setNoneMetadata", SETTER(const boost::none_t, nix::Block, metadata))
            .reg("deleteDataArray", REMOVER(nix::DataArray, nix::Block, deleteDataArray))
            .reg("deleteSource", REMOVER(nix::Source, nix::Block, deleteSource))
            .reg("deleteTag", REMOVER(nix::Tag, nix::Block, deleteTag))
            .reg("deleteMultiTag", REMOVER(nix::MultiTag, nix::Block, deleteMultiTag))
            .reg("deleteGroup", REMOVER(nix::Group, nix::Block, deleteGroup))
            .reg("setType", SETTER(const std::string&, nix::Block, type))
            .reg("setDefinition", SETTER(const std::string&, nix::Block, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Block, definition))
            .reg("sourceCount", GETTER(nix::ndsize_t, nix::Block, sourceCount))
            .reg("dataArrayCount", GETTER(nix::ndsize_t, nix::Block, dataArrayCount))
            .reg("tagCount", GETTER(nix::ndsize_t, nix::Block, tagCount))
            .reg("multiTagCount", GETTER(nix::ndsize_t, nix::Block, multiTagCount))
            .reg("groupCount", GETTER(nix::ndsize_t, nix::Block, groupCount));
        methods->add("Block::createDataArray", nixblock::createDataArray);
        methods->add("Block::createMultiTag", nixblock::createMultiTag);
        methods->add("Block::createGroup", nixblock::createGroup);
        methods->add("Block::openGroupIdx", nixblock::openGroupIdx);
        methods->add("Block::openDataArrayIdx", nixblock::openDataArrayIdx);
        methods->add("Block::openTagIdx", nixblock::openTagIdx);
        methods->add("Block::openMultiTagIdx", nixblock::openMultiTagIdx);
        methods->add("Block::openSourceIdx", nixblock::openSourceIdx);
        methods->add("Block::compare", nixblock::compare);
        methods->add("Block::sourcesFiltered", nixblock::sourcesFiltered);
        methods->add("Block::groupsFiltered", nixblock::groupsFiltered);
        methods->add("Block::tagsFiltered", nixblock::tagsFiltered);
        methods->add("Block::multiTagsFiltered", nixblock::multiTagsFiltered);
        methods->add("Block::dataArraysFiltered", nixblock::dataArraysFiltered);

        classdef<nix::Group>("Group", methods)
            .desc(&nixgroup::describe)
            .reg("dataArrays", FILTER(std::vector<nix::DataArray>, nix::Group, , dataArrays))
            .reg("sources", FILTER(std::vector<nix::Source>, nix::Group, std::function<bool(const nix::Source &)>, sources))
            .reg("tags", FILTER(std::vector<nix::Tag>, nix::Group, , tags))
            .reg("multiTags", FILTER(std::vector<nix::MultiTag>, nix::Group, , multiTags))
            .reg("hasDataArray", GETBYSTR(bool, nix::Group, hasDataArray))
            .reg("hasSource", GETBYSTR(bool, nix::Group, hasSource))
            .reg("hasTag", GETBYSTR(bool, nix::Group, hasTag))
            .reg("hasMultiTag", GETBYSTR(bool, nix::Group, hasMultiTag))
            .reg("getDataArray", GETBYSTR(nix::DataArray, nix::Group, getDataArray))
            .reg("openSource", GETBYSTR(nix::Source, nix::Group, getSource))
            .reg("getTag", GETBYSTR(nix::Tag, nix::Group, getTag))
            .reg("getMultiTag", GETBYSTR(nix::MultiTag, nix::Group, getMultiTag))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Group, metadata))
            .reg("setMetadata", SETTER(const std::string&, nix::Group, metadata))
            .reg("setNoneMetadata", SETTER(const boost::none_t, nix::Group, metadata))
            .reg("removeDataArray", REMOVER(nix::DataArray, nix::Group, removeDataArray))
            .reg("removeSource", REMOVER(nix::Source, nix::Group, removeSource))
            .reg("removeTag", REMOVER(nix::Tag, nix::Group, removeTag))
            .reg("removeMultiTag", REMOVER(nix::MultiTag, nix::Group, removeMultiTag))
            .reg("setType", SETTER(const std::string&, nix::Group, type))
            .reg("setDefinition", SETTER(const std::string&, nix::Group, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Group, definition))
            .reg("sourceCount", GETTER(nix::ndsize_t, nix::Group, sourceCount))
            .reg("dataArrayCount", GETTER(nix::ndsize_t, nix::Group, dataArrayCount))
            .reg("tagCount", GETTER(nix::ndsize_t, nix::Group, tagCount))
            .reg("multiTagCount", GETTER(nix::ndsize_t, nix::Group, multiTagCount));
        methods->add("Group::addDataArray", nixgroup::addDataArray);
        methods->add("Group::addDataArrays", nixgroup::addDataArrays);
        methods->add("Group::addSource", nixgroup::addSource);
        methods->add("Group::addSources", nixgroup::addSources);
        methods->add("Group::addTag", nixgroup::addTag);
        methods->add("Group::addTags", nixgroup::addTags);
        methods->add("Group::addMultiTag", nixgroup::addMultiTag);
        methods->add("Group::addMultiTags", nixgroup::addMultiTags);
        methods->add("Group::openDataArrayIdx", nixgroup::openDataArrayIdx);
        methods->add("Group::openTagIdx", nixgroup::openTagIdx);
        methods->add("Group::openMultiTagIdx", nixgroup::openMultiTagIdx);
        methods->add("Group::openSourceIdx", nixgroup::openSourceIdx);
        methods->add("Group::compare", nixgroup::compare);
        methods->add("Group::sourcesFiltered", nixgroup::sourcesFiltered);
        methods->add("Group::tagsFiltered", nixgroup::tagsFiltered);
        methods->add("Group::multiTagsFiltered", nixgroup::multiTagsFiltered);
        methods->add("Group::dataArraysFiltered", nixgroup::dataArraysFiltered);

        classdef<nix::DataArray>("DataArray", methods)
            .desc(&nixdataarray::describe)
            .reg("sources", IDATAARRAY(std::vector<nix::Source>, EntityWithSources, std::function<bool(const nix::Source &)>, sources, const))
            .reg("openMetadataSection", IDATAARRAY(nix::Section, EntityWithMetadata, , metadata, const))
            .reg("setMetadata", IDATAARRAY(void, EntityWithMetadata, const std::string&, metadata, ))
            .reg("setNoneMetadata", IDATAARRAY(void, EntityWithMetadata, const boost::none_t, metadata, ))
            .reg("setType", IDATAARRAY(void, NamedEntity, const std::string&, type, ))
            .reg("setDefinition", IDATAARRAY(void, NamedEntity, const std::string&, definition, ))
            .reg("setNoneDefinition", IDATAARRAY(void, NamedEntity, const boost::none_t, definition, ))
            .reg("setLabel", SETTER(const std::string&, nix::DataArray, label))
            .reg("setNoneLabel", SETTER(const boost::none_t, nix::DataArray, label))
            .reg("setUnit", SETTER(const std::string&, nix::DataArray, unit))
            .reg("setNoneUnit", SETTER(const boost::none_t, nix::DataArray, unit))
            .reg("setExpansionOrigin", SETTER(double, nix::DataArray, expansionOrigin))
            .reg("setNoneExpansionOrigin", SETTER(boost::none_t, nix::DataArray, expansionOrigin))
            .reg("setNonePolynomCoefficients", SETTER(boost::none_t, nix::DataArray, polynomCoefficients))
            .reg("dimensions", FILTER(std::vector<nix::Dimension>, nix::DataArray, , dimensions))
            .reg("appendSetDimension", &nix::DataArray::appendSetDimension)
            .reg("appendRangeDimension", &nix::DataArray::appendRangeDimension)
            .reg("appendAliasRangeDimension", &nix::DataArray::appendAliasRangeDimension)
            .reg("appendSampledDimension", &nix::DataArray::appendSampledDimension)
            .reg("createSetDimension", &nix::DataArray::createSetDimension)
            .reg("createRangeDimension", &nix::DataArray::createRangeDimension)
            .reg("createAliasRangeDimension", &nix::DataArray::createAliasRangeDimension)
            .reg("createSampledDimension", &nix::DataArray::createSampledDimension);
        methods->add("DataArray::deleteDimensions", nixdataarray::deleteDimensions);
        methods->add("DataArray::readAll", nixdataarray::readAll);
        methods->add("DataArray::writeAll", nixdataarray::writeAll);
        methods->add("DataArray::addSource", nixdataarray::addSource);
        methods->add("DataArray::addSources", nixdataarray::addSources);
        // REMOVER for DataArray.removeSource leads to an error, therefore use method->add for now
        methods->add("DataArray::removeSource", nixdataarray::removeSource);
        methods->add("DataArray::openSource", nixdataarray::getSource);
        methods->add("DataArray::hasSource", nixdataarray::hasSource);
        methods->add("DataArray::sourceCount", nixdataarray::sourceCount);
        methods->add("DataArray::dimensionCount", nixdataarray::dimensionCount);
        methods->add("DataArray::setPolynomCoefficients", nixdataarray::polynomCoefficients);
        methods->add("DataArray::dataType", nixdataarray::dataType);
        methods->add("DataArray::setDataExtent", nixdataarray::setDataExtent);
        methods->add("DataArray::openSourceIdx", nixdataarray::openSourceIdx);
        methods->add("DataArray::openDimensionIdx", nixdataarray::openDimensionIdx);
        methods->add("DataArray::compare", nixdataarray::compare);

        classdef<nix::Source>("Source", methods)
            .desc(&nixsource::describe)
            .reg("createSource", &nix::Source::createSource)
            .reg("deleteSource", REMOVER(nix::Source, nix::Source, deleteSource))
            .reg("sources", &nix::Source::sources)
            .reg("hasSource", GETBYSTR(bool, nix::Source, hasSource))
            .reg("openSource", GETBYSTR(nix::Source, nix::Source, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Source, metadata))
            .reg("setMetadata", SETTER(const std::string&, nix::Source, metadata))
            .reg("setNoneMetadata", SETTER(const boost::none_t, nix::Source, metadata))
            .reg("setType", SETTER(const std::string&, nix::Source, type))
            .reg("setDefinition", SETTER(const std::string&, nix::Source, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Source, definition))
            .reg("parentSource", GETTER(nix::Source, nix::Source, parentSource))
            .reg("sourceCount", GETTER(nix::ndsize_t, nix::Source, sourceCount))
            .reg("referringDataArrays", GETTER(std::vector<nix::DataArray>, nix::Source, referringDataArrays))
            .reg("referringTags", GETTER(std::vector<nix::Tag>, nix::Source, referringTags))
            .reg("referringMultiTags", GETTER(std::vector<nix::MultiTag>, nix::Source, referringMultiTags));
        methods->add("Source::openSourceIdx", nixsource::openSourceIdx);
        methods->add("Source::compare", nixsource::compare);

        classdef<nix::Tag>("Tag", methods)
            .desc(&nixtag::describe)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::Tag, references))
            .reg("features", &nix::Tag::features)
            .reg("sources", FILTER(std::vector<nix::Source>, nix::Tag, std::function<bool(const nix::Source &)>, sources))
            .reg("hasReference", GETBYSTR(bool, nix::Tag, hasReference))
            .reg("hasFeature", GETBYSTR(bool, nix::Tag, hasFeature))
            .reg("hasSource", GETBYSTR(bool, nix::Tag, hasSource))
            .reg("openReferenceDataArray", GETBYSTR(nix::DataArray, nix::Tag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::Tag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::Tag, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::Tag, metadata))
            .reg("setUnits", SETTER(const std::vector<std::string>&, nix::Tag, units))
            .reg("setNoneUnits", SETTER(const boost::none_t, nix::Tag, units))
            .reg("setMetadata", SETTER(const std::string&, nix::Tag, metadata))
            .reg("setNoneMetadata", SETTER(const boost::none_t, nix::Tag, metadata))
            .reg("setType", SETTER(const std::string&, nix::Tag, type))
            .reg("setDefinition", SETTER(const std::string&, nix::Tag, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Tag, definition))
            .reg("setPosition", SETTER(const std::vector<double>&, nix::Tag, position))
            .reg("setExtent", SETTER(const std::vector<double>&, nix::Tag, extent))
            .reg("setNoneExtent", SETTER(const boost::none_t, nix::Tag, extent))
            .reg("removeReference", REMOVER(nix::DataArray, nix::Tag, removeReference))
            .reg("removeSource", REMOVER(nix::Source, nix::Tag, removeSource))
            .reg("deleteFeature", REMOVER(nix::Feature, nix::Tag, deleteFeature))
            .reg("sourceCount", GETTER(nix::ndsize_t, nix::Tag, sourceCount))
            .reg("referenceCount", GETTER(nix::ndsize_t, nix::Tag, referenceCount))
            .reg("featureCount", GETTER(nix::ndsize_t, nix::Tag, featureCount));
        methods->add("Tag::retrieveData", nixtag::retrieveData);
        methods->add("Tag::featureRetrieveData", nixtag::retrieveFeatureData);
        methods->add("Tag::addReference", nixtag::addReference);
        methods->add("Tag::addReferences", nixtag::addReferences);
        methods->add("Tag::addSource", nixtag::addSource);
        methods->add("Tag::addSources", nixtag::addSources);
        methods->add("Tag::createFeature", nixtag::createFeature);
        methods->add("Tag::openReferenceIdx", nixtag::openReferenceIdx);
        methods->add("Tag::openFeatureIdx", nixtag::openFeatureIdx);
        methods->add("Tag::openSourceIdx", nixtag::openSourceIdx);
        methods->add("Tag::compare", nixtag::compare);
        methods->add("Tag::sourcesFiltered", nixtag::sourcesFiltered);
        methods->add("Tag::referencesFiltered", nixtag::referencesFiltered);
        methods->add("Tag::featuresFiltered", nixtag::featuresFiltered);

        classdef<nix::MultiTag>("MultiTag", methods)
            .desc(&nixmultitag::describe)
            .reg("references", GETTER(std::vector<nix::DataArray>, nix::MultiTag, references))
            .reg("features", &nix::MultiTag::features)
            .reg("sources", FILTER(std::vector<nix::Source>, nix::MultiTag, std::function<bool(const nix::Source &)>, sources))
            .reg("hasPositions", GETCONTENT(bool, nix::MultiTag, hasPositions))
            .reg("hasReference", GETBYSTR(bool, nix::MultiTag, hasReference))
            .reg("hasFeature", GETBYSTR(bool, nix::MultiTag, hasFeature))
            .reg("hasSource", GETBYSTR(bool, nix::MultiTag, hasSource))
            .reg("openPositions", GETCONTENT(nix::DataArray, nix::MultiTag, positions))
            .reg("openExtents", GETCONTENT(nix::DataArray, nix::MultiTag, extents))
            .reg("openReferences", GETBYSTR(nix::DataArray, nix::MultiTag, getReference))
            .reg("openFeature", GETBYSTR(nix::Feature, nix::MultiTag, getFeature))
            .reg("openSource", GETBYSTR(nix::Source, nix::MultiTag, getSource))
            .reg("openMetadataSection", GETCONTENT(nix::Section, nix::MultiTag, metadata))
            .reg("setUnits", SETTER(const std::vector<std::string>&, nix::MultiTag, units))
            .reg("setNoneUnits", SETTER(const boost::none_t, nix::MultiTag, units))
            .reg("setExtents", SETTER(const std::string&, nix::MultiTag, extents))
            .reg("setNoneExtents", SETTER(const boost::none_t, nix::MultiTag, extents))
            .reg("setType", SETTER(const std::string&, nix::MultiTag, type))
            .reg("setDefinition", SETTER(const std::string&, nix::MultiTag, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::MultiTag, definition))
            .reg("setMetadata", SETTER(const std::string&, nix::MultiTag, metadata))
            .reg("setNoneMetadata", SETTER(const boost::none_t, nix::MultiTag, metadata))
            .reg("removeReference", REMOVER(nix::DataArray, nix::MultiTag, removeReference))
            .reg("removeSource", REMOVER(nix::Source, nix::MultiTag, removeSource))
            .reg("deleteFeature", REMOVER(nix::Feature, nix::MultiTag, deleteFeature))
            .reg("sourceCount", GETTER(nix::ndsize_t, nix::MultiTag, sourceCount))
            .reg("referenceCount", GETTER(nix::ndsize_t, nix::MultiTag, referenceCount))
            .reg("featureCount", GETTER(nix::ndsize_t, nix::MultiTag, featureCount));
        methods->add("MultiTag::retrieveData", nixmultitag::retrieveData);
        methods->add("MultiTag::featureRetrieveData", nixmultitag::retrieveFeatureData);
        methods->add("MultiTag::addReference", nixmultitag::addReference);
        methods->add("MultiTag::addReferences", nixmultitag::addReferences);
        methods->add("MultiTag::addSource", nixmultitag::addSource);
        methods->add("MultiTag::addSources", nixmultitag::addSources);
        methods->add("MultiTag::createFeature", nixmultitag::createFeature);
        methods->add("MultiTag::addPositions", nixmultitag::addPositions);
        methods->add("MultiTag::openReferenceIdx", nixmultitag::openReferenceIdx);
        methods->add("MultiTag::openFeatureIdx", nixmultitag::openFeatureIdx);
        methods->add("MultiTag::openSourceIdx", nixmultitag::openSourceIdx);
        methods->add("MultiTag::compare", nixmultitag::compare);

        classdef<nix::Section>("Section", methods)
            .desc(&nixsection::describe)
            .reg("sections", &nix::Section::sections)
            .reg("openSection", GETBYSTR(nix::Section, nix::Section, getSection))
            .reg("hasProperty", GETBYSTR(bool, nix::Section, hasProperty))
            .reg("hasSection", GETBYSTR(bool, nix::Section, hasSection))
            .reg("openLink", GETCONTENT(nix::Section, nix::Section, link))
            .reg("setLink", SETTER(const std::string&, nix::Section, link))
            .reg("setNoneLink", SETTER(const boost::none_t, nix::Section, link))
            .reg("parent", GETCONTENT(nix::Section, nix::Section, parent))
            .reg("setType", SETTER(const std::string&, nix::Section, type))
            .reg("setDefinition", SETTER(const std::string&, nix::Section, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Section, definition))
            .reg("setRepository", SETTER(const std::string&, nix::Section, repository))
            .reg("setNoneRepository", SETTER(const boost::none_t, nix::Section, repository))
            .reg("setMapping", SETTER(const std::string&, nix::Section, mapping))
            .reg("setNoneMapping", SETTER(const boost::none_t, nix::Section, mapping))
            .reg("createSection", &nix::Section::createSection)
            .reg("deleteSection", REMOVER(nix::Section, nix::Section, deleteSection))
            .reg("openProperty", GETBYSTR(nix::Property, nix::Section, getProperty))
            .reg("deleteProperty", REMOVER(nix::Property, nix::Section, deleteProperty))
            .reg("sectionCount", GETTER(nix::ndsize_t, nix::Section, sectionCount))
            .reg("propertyCount", GETTER(nix::ndsize_t, nix::Section, propertyCount))
            .reg("inheritedProperties", GETTER(std::vector<nix::Property>, nix::Section, inheritedProperties))
            .reg("referringDataArrays", GETTER(std::vector<nix::DataArray>, nix::Section, referringDataArrays))
            .reg("referringTags", GETTER(std::vector<nix::Tag>, nix::Section, referringTags))
            .reg("referringMultiTags", GETTER(std::vector<nix::MultiTag>, nix::Section, referringMultiTags))
            .reg("referringSources", GETTER(std::vector<nix::Source>, nix::Section, referringSources))
            .reg("referringBlocks", GETTER(std::vector<nix::Block>, nix::Section, referringBlocks));
        methods->add("Section::properties", nixsection::properties);
        methods->add("Section::createProperty", nixsection::createProperty);
        methods->add("Section::createPropertyWithValue", nixsection::createPropertyWithValue);
        methods->add("Section::referringBlockSources", nixsection::referringBlockSources);
        methods->add("Section::referringBlockTags", nixsection::referringBlockTags);
        methods->add("Section::referringBlockMultiTags", nixsection::referringBlockMultiTags);
        methods->add("Section::referringBlockDataArrays", nixsection::referringBlockDataArrays);
        methods->add("Section::openSectionIdx", nixsection::openSectionIdx);
        methods->add("Section::openPropertyIdx", nixsection::openPropertyIdx);
        methods->add("Section::compare", nixsection::compare);

        classdef<nix::Feature>("Feature", methods)
            .desc(&nixfeature::describe)
            .reg("openData", GETCONTENT(nix::DataArray, nix::Feature, data))
            .reg("setData", SETTER(const std::string&, nix::Feature, data))
            .reg("getLinkType", GETCONTENT(nix::LinkType, nix::Feature, linkType));
        methods->add("Feature::setLinkType", nixfeature::setLinkType);

        classdef<nix::Property>("Property", methods)
            .desc(&nixproperty::describe)
            .reg("setDefinition", SETTER(const std::string&, nix::Property, definition))
            .reg("setNoneDefinition", SETTER(const boost::none_t, nix::Property, definition))
            .reg("setUnit", SETTER(const std::string&, nix::Property, unit))
            .reg("setNoneUnit", SETTER(const boost::none_t, nix::Property, unit))
            .reg("setMapping", SETTER(const std::string&, nix::Property, mapping))
            .reg("setNoneMapping", SETTER(const boost::none_t, nix::Property, mapping))
            .reg("valueCount", GETTER(nix::ndsize_t, nix::Property, valueCount))
            .reg("setNoneValue", SETTER(const boost::none_t, nix::Property, values));
        methods->add("Property::values", nixproperty::values);
        methods->add("Property::updateValues", nixproperty::updateValues);
        methods->add("Property::deleteValues", nixproperty::deleteValues);
        methods->add("Property::compare", nixproperty::compare);

        classdef<nix::SetDimension>("SetDimension", methods)
            .desc(&nixdimensions::describe)
            .reg("setLabels", SETTER(const std::vector<std::string>&, nix::SetDimension, labels))
            .reg("setNoneLabels", SETTER(const boost::none_t, nix::SetDimension, labels));

        classdef<nix::SampledDimension>("SampledDimension", methods)
            .desc(&nixdimensions::describe)
            .reg("setLabel", SETTER(const std::string&, nix::SampledDimension, label))
            .reg("setNoneLabel", SETTER(const boost::none_t, nix::SampledDimension, label))
            .reg("setUnit", SETTER(const std::string&, nix::SampledDimension, unit))
            .reg("setNoneUnit", SETTER(const boost::none_t, nix::SampledDimension, unit))
            .reg("setSamplingInterval", SETTER(double, nix::SampledDimension, samplingInterval))
            .reg("setOffset", SETTER(double, nix::SampledDimension, offset))
            .reg("setNoneOffset", SETTER(const boost::none_t, nix::SampledDimension, offset))
            .reg("indexOf", &nix::SampledDimension::indexOf);
        methods->add("SampledDimension::positionAt", nixdimensions::sampledPositionAt);
        methods->add("SampledDimension::axis", nixdimensions::sampledAxis);

        classdef<nix::RangeDimension>("RangeDimension", methods)
            .desc(&nixdimensions::describe)
            .reg("setLabel", SETTER(const std::string&, nix::RangeDimension, label))
            .reg("setNoneLabel", SETTER(const boost::none_t, nix::RangeDimension, label))
            .reg("setUnit", SETTER(const std::string&, nix::RangeDimension, unit))
            .reg("setNoneUnit", SETTER(const boost::none_t, nix::RangeDimension, unit))
            .reg("setTicks", SETTER(const std::vector<double>&, nix::RangeDimension, ticks))
            .reg("indexOf", &nix::RangeDimension::indexOf);
        methods->add("RangeDimension::tickAt", nixdimensions::rangeTickAt);
        methods->add("RangeDimension::axis", nixdimensions::rangeAxis);

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
