classdef Tag < nix.Entity
    %Tag nix Tag object

    properties(Hidden)
        info
        referencesCache
        featuresCache
        sourcesCache
        metadataCache
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

            obj.referencesCache.lastUpdate = 0;
            obj.referencesCache.data = {};
            obj.featuresCache.lastUpdate = 0;
            obj.featuresCache.data = {};
            obj.sourcesCache.lastUpdate = 0;
            obj.sourcesCache.data = {};
            obj.metadataCache.lastUpdate = 0;
            obj.metadataCache.data = {};
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

        function retObj = open_reference(obj, id_or_name)
            handle = nix_mx('Tag::openReferenceDataArray', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.DataArray(handle);
            end;
        end;

        function da = get.references(obj)
            [obj.referencesCache, da] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Tag::references', obj.nix_handle, obj.referencesCache, @nix.DataArray);
        end;
        
        function data = retrieve_data(obj, index)
            % convert Matlab-like to C-like index
            assert(index > 0, 'Subscript indices must be positive');
            tmp = nix_mx('Tag::retrieveData', obj.nix_handle, index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;

        % ------------------
        % Features methods
        % ------------------
        
        function featureList = list_features(obj)
            featureList = nix_mx('Tag::listFeatures', obj.nix_handle);
        end;

        function retObj = open_feature(obj, id_or_name)
            handle = nix_mx('Tag::openFeature', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Feature(handle);
            end;
        end;

        function feat = get.features(obj)
            [obj.featuresCache, feat] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Tag::features', obj.nix_handle, obj.featuresCache, @nix.Feature);
        end;
        
        function data = retrieve_feature_data(obj, index)
            % convert Matlab-like to C-like index
            assert(index > 0, 'Subscript indices must be positive');
            tmp = nix_mx('Tag::featureRetrieveData', obj.nix_handle, index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        % ------------------
        % Sources methods
        % ------------------
        
        function sourceList = list_sources(obj)
            sourceList = nix_mx('Tag::listSources', obj.nix_handle);
        end;

        function retObj = open_source(obj, id_or_name)
            handle = nix_mx('Tag::openSource', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Source(handle);
            end;
        end;

        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Tag::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;

        % ------------------
        % Metadata methods
        % ------------------

        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'Tag::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

    end;
end