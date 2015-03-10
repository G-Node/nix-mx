classdef Block < nix.NamedEntity
    %Block nix Block object
    
    properties (Access = protected)
        % namespace reference for nix-mx functions
        alias = 'Block'
    end
    
    properties(Hidden)
        metadataCache
    end
    
    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
            
            % assign relations
            obj.add_dyn_relation('dataArrays', @nix.DataArray);
            obj.add_dyn_relation('sources', @nix.Source);
            obj.add_dyn_relation('tags', @nix.Tag);
            obj.add_dyn_relation('multiTags', @nix.MultiTag);
            
            obj.metadataCache = nix.CacheStruct();
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function retObj = data_array(obj, id_or_name)
            handle = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
            retObj = {};
            if handle ~= 0
                retObj = nix.DataArray(handle);
            end;
        end;
        
        function da = create_data_array(obj, name, nixtype, dtype, shape)
            handle = nix_mx('Block::createDataArray', obj.nix_handle, ...
                name, nixtype, dtype, shape);
            da = nix.DataArray(handle);
            obj.dataArraysCache.lastUpdate = 0;
        end
        
        function da = create_data_array_from_data(obj, name, nixtype, data)
            shape = size(data);
            dtype = class(data);
            
            da = obj.create_data_array(name, nixtype, dtype, shape);
            da.write_all(data);
        end
        
        % -----------------
        % Sources methods
        % -----------------
        
        function s = create_source(obj, name, type)
            s = nix.Source(nix_mx('Block::createSource', obj.nix_handle, name, type));
            obj.sourcesCache.lastUpdate = 0;
        end;
        
        function delCheck = delete_source(obj, del)
            [delCheck, obj.sourcesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Source', 'Block::deleteSource', obj.sourcesCache);
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
            hasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
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
            hasMTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
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
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'Block::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

    end;
end