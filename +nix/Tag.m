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
        
        function [] = add_reference(obj, add_this)
            obj.referencesCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.DataArray', 'Tag::addReference', obj.referencesCache);
        end;

        function delCheck = remove_reference(obj, del)
            [delCheck, obj.referencesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Tag::removeReference', obj.referencesCache);
        end;

        function retObj = open_reference(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Tag::openReferenceDataArray', id_or_name, @nix.DataArray);
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
        
        function retObj = open_feature(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Tag::openFeature', id_or_name, @nix.Feature);
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

        function [] = add_source(obj, add_this)
            obj.sourcesCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.Source', 'Tag::addSource', obj.sourcesCache);
        end;

        function delCheck = remove_source(obj, del)
            [delCheck, obj.sourcesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Source', 'Tag::removeSource', obj.sourcesCache);
        end;

        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Tag::openSource', id_or_name, @nix.Source);
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