classdef Block < nix.NamedEntity & nix.MetadataMixIn
    %Block nix Block object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Block'
    end
    
    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            
            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'groups', @nix.Group);
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
        end;
        
        % -----------------
        % Group methods
        % -----------------
        
        function g = create_group(obj, name, nixtype)
            handle = nix_mx('Block::createGroup', obj.nix_handle, ...
                name, nixtype);
            g = nix.Group(handle);
        end;
        
        function hasGroup = has_group(obj, id_or_name)
            hasGroup = nix_mx('Block::hasGroup', obj.nix_handle, id_or_name);
        end;

        function retObj = get_group(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::getGroup', id_or_name, @nix.Group);
        end;

        function delCheck = delete_group(obj, del)
            delCheck = nix.Utils.delete_entity_(obj, ...
                del, 'nix.Group', 'Block::deleteGroup');
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function retObj = data_array(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openDataArray', id_or_name, @nix.DataArray);
        end;
        
        %-- As "datatype" provide one of the nix.DataTypes. Alternatively
        %-- a string stating one of the datatypes supported by nix can be provided.
        function da = create_data_array(obj, name, nixtype, datatype, shape)
            handle = nix_mx('Block::createDataArray', obj.nix_handle, ...
                name, nixtype, datatype, shape);
            da = nix.DataArray(handle);
        end
        
        function da = create_data_array_from_data(obj, name, nixtype, data)
            shape = size(data);
            dtype = class(data);
            
            da = obj.create_data_array(name, nixtype, dtype, shape);
            da.write_all(data);
        end

        function hasDA = has_data_array(obj, id_or_name)
            hasDA = nix_mx('Block::hasDataArray', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = delete_data_array(obj, del)
            delCheck = nix.Utils.delete_entity_(obj, ...
                del, 'nix.DataArray', 'Block::deleteDataArray');
        end;

        % -----------------
        % Sources methods
        % -----------------
        
        function s = create_source(obj, name, type)
            s = nix.Source(nix_mx('Block::createSource', ...
                obj.nix_handle, name, type));
        end;
        
        function hasSource = has_source(obj, id_or_name)
            hasSource = nix_mx('Block::hasSource', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = delete_source(obj, del)
            delCheck = nix.Utils.delete_entity_(obj, ...
                del, 'nix.Source', 'Block::deleteSource');
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
        end;

        function delCheck = delete_tag(obj, del)
            delCheck = nix.Utils.delete_entity_(obj, ...
                del, 'nix.Tag', 'Block::deleteTag');
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
        end;
        
        function delCheck = delete_multi_tag(obj, del)
            delCheck = nix.Utils.delete_entity_(obj, ...
                del, 'nix.MultiTag', 'Block::deleteMultiTag');
        end;

    end;
end
