classdef MultiTag < nix.Entity
    %MultiTag nix MultiTag object

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
        units
        featureCount
        sourceCount
        referenceCount
        
        references
        features
        sources
    end;

    methods
        function obj = MultiTag(h)
            obj@nix.Entity(h);
            obj.info = nix_mx('MultiTag::describe', obj.nix_handle);

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
            refList = nix_mx('MultiTag::listReferences', obj.nix_handle);
        end;

        function dataArray = open_reference(obj, id_or_name)
            daHandle = nix_mx('MultiTag::openReferences', obj.nix_handle, id_or_name);
            dataArray = nix.DataArray(daHandle);
        end;

        function da = get.references(obj)
            [obj.referencesCache, da] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'MultiTag::references', obj.nix_handle, obj.referencesCache, @nix.DataArray);
        end;
        
        function data = retrieve_data(obj, pos_index, ref_index)
            % convert Matlab-like to C-like index
            assert(pos_index > 0, 'Position index must be positive');
            assert(ref_index > 0, 'Reference index must be positive');
            tmp = nix_mx('MultiTag::retrieveData', obj.nix_handle, ...
                pos_index - 1, ref_index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        % ------------------
        % Features methods
        % ------------------
        
        function featureList = list_features(obj)
            featureList = nix_mx('MultiTag::listFeatures', obj.nix_handle);
        end;

        function feature = open_feature(obj, id_or_name)
            featureHandle = nix_mx('MultiTag::openFeatures', obj.nix_handle, id_or_name);
            feature = nix.Feature(featureHandle);
        end;

        function feat = get.features(obj)
            [obj.featuresCache, feat] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'MultiTag::features', obj.nix_handle, obj.featuresCache, @nix.Feature);
        end;

        function data = retrieve_feature_data(obj, pos_index, fea_index)
            % convert Matlab-like to C-like index
            assert(pos_index > 0, 'Position index must be positive');
            assert(fea_index > 0, 'Feature index must be positive');
            tmp = nix_mx('MultiTag::featureRetrieveData', obj.nix_handle, ...
                pos_index - 1, fea_index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        % ------------------
        % Sources methods
        % ------------------

        function sourceList = list_sources(obj)
            sourceList = nix_mx('MultiTag::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
            sourceHandle = nix_mx('MultiTag::openSource', obj.nix_handle, id_or_name);
            source = nix.Source(sourceHandle);
        end;

        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'MultiTag::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;

        % ------------------
        % Positions methods
        % ------------------

        function hasPositions = has_positions(obj)
            getHasPositions = nix_mx('MultiTag::hasPositions', obj.nix_handle);
            hasPositions = getHasPositions.hasPositions;
        end;
        
        function positions = open_positions(obj)
            if obj.has_positions
                positionsHandle = nix_mx('MultiTag::openPositions', obj.nix_handle);
                positions = nix.DataArray(positionsHandle);
            else
                positions = 'No positions available';
            end;
        end;
        
        % ------------------
        % Extents methods
        % ------------------

        function extents = open_extent(obj)
            extentsHandle = nix_mx('MultiTag::openExtents', obj.nix_handle);
            extents = nix.DataArray(extentsHandle);
        end;
        
        % ------------------
        % Metadata methods
        % ------------------
        
        function hasMetadata = has_metadata(obj)
            getHasMetadata = nix_mx('MultiTag::hasMetadataSection', obj.nix_handle);
            hasMetadata = logical(getHasMetadata.hasMetadataSection);
        end;
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'MultiTag::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

    end;
end