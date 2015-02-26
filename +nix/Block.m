classdef Block < nix.NamedEntity
    %Block nix Block object
    
    properties (Access = protected)
        % namespace reference for nix-mx functions
        alias = 'Block'
    end
    
    properties(Hidden)
        metadataCache = nix.CacheStruct()
    end
    
    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
            
            % assign relations
            obj.add_dyn_relation('dataArrays', @nix.DataArray);
            obj.add_dyn_relation('sources', @nix.Source);
            obj.add_dyn_relation('tags', @nix.Tag);
            obj.add_dyn_relation('multiTags', @nix.MultiTag);
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function das = list_data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end;
        
        function retObj = data_array(obj, id_or_name)
            handle = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
            retObj = {};
            if handle ~= 0
                retObj = nix.DataArray(handle);
            end;
        end;
        
        % -----------------
        % Sources methods
        % -----------------
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Block::listSources', obj.nix_handle);
        end;

        function retObj = open_source(obj, id_or_name)
            handle = nix_mx('Block::openSource', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Source(handle);
            end;
        end;

        % -----------------
        % Tags methods
        % -----------------
        
        function hasTag = has_tag(obj, id_or_name)
            getHasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
            hasTag = logical(getHasTag.hasTag);
        end;
        
        function tagList = list_tags(obj)
            tagList = nix_mx('Block::listTags', obj.nix_handle);
        end;
        
        function retObj = open_tag(obj, id_or_name)
            handle = nix_mx('Block::openTag', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Tag(handle);
            end;
        end;
        
        function tag = create_tag(obj, name, type, position)
           th = nix_mx('Block::createTag', obj.nix_handle, ...
               name, type, position);
           tag = nix.Tag(th);
           obj.tagsCache.lastUpdate = 0;
        end;
        
        % -----------------
        % MultiTag methods
        % -----------------
        
        function hasMTag = has_multi_tag(obj, id_or_name)
            getHasMTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
            hasMTag = logical(getHasMTag.hasMultiTag);
        end;

        function tagList = list_multi_tags(obj)
            tagList = nix_mx('Block::listMultiTags', obj.nix_handle);
        end;
        
        function retObj = open_multi_tag(obj, id_or_name)
            handle = nix_mx('Block::openMultiTag', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.MultiTag(handle);
            end;
        end;
        
        % -----------------
        % Metadata methods
        % -----------------
        
        function hasMetadata = has_metadata(obj)
            getHasMetadata = nix_mx('Block::hasMetadataSection', obj.nix_handle);
            hasMetadata = logical(getHasMetadata.hasMetadataSection);
        end;
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'Block::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

    end;
end