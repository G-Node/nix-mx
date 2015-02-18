classdef Tag < nix.Entity
    %Tag nix Tag object

    properties(Hidden)
        info
        referencesCache
        featuresCache
        sourcesCache
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        position
        extent
        units
        featureCount
        sourceCount
        referenceCount
        
        references
        features
        sources
    end;

    methods
        function obj = Tag(h)
            obj@nix.Entity(h);
            obj.info = nix_mx('Tag::describe', obj.nix_handle);

            obj.referencesCache = {};
            obj.featuresCache = {};
            obj.sourcesCache = {};
        end;
        
        function id = get.id(tag)
           id = tag.info.id; 
        end;
        
        function name = get.name(tag)
           name = tag.info.name;
        end;
        
        function type = get.type(tag)
            type = tag.info.type;
        end;

        function definition = get.definition(tag)
            definition = tag.info.definition;
        end;

        function position = get.position(tag)
            position = tag.info.position;
        end;

        function extent = get.extent(tag)
            extent = tag.info.extent;
        end;

        function units = get.units(tag)
            units = tag.info.units;
        end;

        function featureCount = get.featureCount(tag)
            featureCount = tag.info.featureCount;
        end;

        function sourceCount = get.sourceCount(tag)
             sourceCount = tag.info.sourceCount;
        end;

        function referenceCount = get.referenceCount(tag)
            referenceCount = tag.info.referenceCount;
        end;

        % ------------------
        % References methods
        % ------------------
        
        function refList = list_references(obj)
            refList = nix_mx('Tag::listReferences', obj.nix_handle);
        end;

        function dataArray = open_reference(obj, id_or_name)
            daHandle = nix_mx('Tag::openReferenceDataArray', obj.nix_handle, id_or_name);
            dataArray = nix.DataArray(daHandle);
        end;

        function da = get.references(obj)
            da_list = nix_mx('Tag::references', obj.nix_handle);
            
            if length(obj.referencesCache) ~= length(da_list)
                obj.referencesCache = cell(length(da_list), 1);

                for i = 1:length(da_list)
                    obj.referencesCache{i} = nix.DataArray(da_list{i});
                end;
            end;

            da = obj.referencesCache;
        end;

        % ------------------
        % Features methods
        % ------------------
        
        function featureList = list_features(obj)
            featureList = nix_mx('Tag::listFeatures', obj.nix_handle);
        end;

        function feature = open_feature(obj, id_or_name)
            featureHandle = nix_mx('Tag::openFeature', obj.nix_handle, id_or_name);
            feature = nix.Feature(featureHandle);
        end;

        function feat = get.features(obj)
            featList = nix_mx('Tag::features', obj.nix_handle);
            
            if length(obj.featuresCache) ~= length(featList)
                obj.featuresCache = cell(length(featList), 1);

                for i = 1:length(featList)
                    obj.featuresCache{i} = nix.Feature(featList{i});
                end;
            end;

            feat = obj.featuresCache;
        end;
        
        % ------------------
        % Sources methods
        % ------------------
        
        function sourceList = list_sources(obj)
            sourceList = nix_mx('Tag::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
            sourceHandle = nix_mx('Tag::openSource', obj.nix_handle, id_or_name);
            source = nix.Source(sourceHandle);
        end;

        function sources = get.sources(obj)
            sList = nix_mx('Tag::sources', obj.nix_handle);
            
            if length(obj.sourcesCache) ~= length(sList)
                obj.sourcesCache = cell(length(sList), 1);

                for i = 1:length(sList)
                    obj.sourcesCache{i} = nix.Source(sList{i});
                end;
            end;

            sources = obj.sourcesCache;
        end;

        % ------------------
        % Metadata methods
        % ------------------

        function hasMetadata = has_metadata(obj)
            getHasMetadata = nix_mx('Tag::hasMetadataSection', obj.nix_handle);
            hasMetadata = logical(getHasMetadata.hasMetadataSection);
        end;
        
        function metadata = open_metadata(obj)
            metadata = {};
            metadataHandle = nix_mx('Tag::openMetadataSection', obj.nix_handle);
            if obj.has_metadata()
                metadata = nix.Section(metadataHandle);
            end;
        end;

    end;
end