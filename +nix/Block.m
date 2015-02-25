classdef Block < nix.NamedEntity
    %Block nix Block object
    
    properties (Access = protected)
        % namespace reference for nix-mx functions
        alias = 'Block'
        
        % dynamically assigned attrs
        dynamic_attrs = {}
    
        % dynamically assigned relations
        dynamic_relations = {
            struct('name', 'dataArrays', 'constructor', @nix.DataArray), ...
            struct('name', 'sources', 'constructor', @nix.Source), ...
            struct('name', 'tags', 'constructor', @nix.Tag), ...
            struct('name', 'multiTags', 'constructor', @nix.MultiTag), ...
        }
    end
    
    properties(Hidden)
        metadataCache = nix.CacheStruct()
    end
    
    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function das = list_data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end;
        
        function da = data_array(obj, id_or_name)
           dh = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
           da = nix.DataArray(dh);
        end;
        
        % -----------------
        % Sources methods
        % -----------------
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Block::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
           sh = nix_mx('Block::openSource', obj.nix_handle, id_or_name); 
           source = nix.Source(sh);
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
        
        function tag = open_tag(obj, id_or_name)
           tagHandle = nix_mx('Block::openTag', obj.nix_handle, id_or_name); 
           tag = nix.Tag(tagHandle);
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
        
        function tag = open_multi_tag(obj, id_or_name)
           tagHandle = nix_mx('Block::openMultiTag', obj.nix_handle, id_or_name); 
           tag = nix.MultiTag(tagHandle);
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