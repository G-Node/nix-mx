classdef Block < nix.NamedEntity
    %Block nix Block object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Block'
        metadataCache
    end
    
    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
            
            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
            
            obj.metadataCache = nix.CacheStruct();
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function retObj = data_array(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openDataArray', id_or_name, @nix.DataArray);
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

        function delCheck = delete_data_array(obj, del)
            [delCheck, obj.dataArraysCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Block::deleteDataArray', obj.dataArraysCache);
        end;

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
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openSource', id_or_name, @nix.Source);
        end;

        % -----------------
        % Tags methods
        % -----------------
        
        function hasTag = has_tag(obj, id_or_name)
            hasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
        end;
        
        function retObj = open_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openTag', id_or_name, @nix.Tag);
        end;
        
        function tag = create_tag(obj, name, type, position)
           th = nix_mx('Block::createTag', obj.nix_handle, ...
               name, type, position);
           tag = nix.Tag(th);
           obj.tagsCache.lastUpdate = 0;
        end;

        function delCheck = delete_tag(obj, del)
            [delCheck, obj.tagsCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Tag', 'Block::deleteTag', obj.tagsCache);
        end;

        % -----------------
        % MultiTag methods
        % -----------------
        
        function hasMTag = has_multi_tag(obj, id_or_name)
            hasMTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
        end;

        function retObj = open_multi_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openMultiTag', id_or_name, @nix.MultiTag);
        end;

        %-- creating a multitag requires an already existing data array
        function multitag = create_multi_tag(obj, name, type, add_data_array)
            if(strcmp(class(add_data_array), 'nix.DataArray'))
                addID = add_data_array.id;
            else
                addID = add_data_array;
            end;

            multitag = nix.MultiTag(nix_mx('Block::createMultiTag', ...
                obj.nix_handle, name, type, addID));
            obj.multiTagsCache.lastUpdate = 0;
        end;
        
        function delCheck = delete_multi_tag(obj, del)
            [delCheck, obj.multiTagsCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.MultiTag', 'Block::deleteMultiTag', obj.multiTagsCache);
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