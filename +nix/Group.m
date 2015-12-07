classdef Group < nix.NamedEntity
    %Group nix Group object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Group'
    end
    
    methods
        function obj = Group(h)
            obj@nix.NamedEntity(h);
            
            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        %-- TODO seems to work -- remove me later
        function hasDataArray = has_data_array(obj, id_or_name)
            hasDataArray = nix_mx('Group::hasDataArray', ...
                obj.nix_handle, id_or_name);
        end;

        %-- TODO seems to work -- remove me later
        function retObj = get_data_array(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getDataArray', id_or_name, @nix.DataArray);
        end;

        %-- TODO seems to work -- remove me later
        function [] = add_data_array(obj, add_this)
            obj.dataArraysCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.DataArray', 'Group::addDataArray', ...
                obj.dataArraysCache);
        end;

        %-- TODO seems to work -- remove me later
        function delCheck = remove_data_array(obj, del)
            [delCheck, obj.dataArraysCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Group::removeDataArray', ...
                obj.dataArraysCache);
        end;

        % -----------------
        % Tags methods
        % -----------------
        
        %-- TODO seems to work -- remove me later
        function hasTag = has_tag(obj, id_or_name)
            hasTag = nix_mx('Group::hasTag', obj.nix_handle, id_or_name);
        end;

        %-- TODO seems to work -- remove me later
        function retObj = get_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getTag', id_or_name, @nix.Tag);
        end;

        %-- TODO seems to work -- remove me later
        function [] = add_tag(obj, add_this)
            obj.tagsCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.Tag', 'Group::addTag', ...
                obj.tagsCache);
        end;

        %-- TODO seems to work -- remove me later
        function delCheck = remove_tag(obj, del)
            [delCheck, obj.tagsCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Tag', 'Group::removeTag', ...
                obj.tagsCache);
        end;

        % -----------------
        % MultiTag methods
        % -----------------
        
        %-- TODO seems to work -- remove me later
        function hasMTag = has_multi_tag(obj, id_or_name)
            hasMTag = nix_mx('Group::hasMultiTag', ...
                obj.nix_handle, id_or_name);
        end;

        %-- TODO seems to work -- remove me later
        function retObj = get_multi_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getMultiTag', id_or_name, @nix.MultiTag);
        end;

        %-- TODO seems to work -- remove me later
        function [] = add_multi_tag(obj, add_this)
            obj.multiTagsCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.MultiTag', 'Group::addMultiTag', ...
                obj.multiTagsCache);
        end;

        %-- TODO seems to work -- remove me later
        function delCheck = remove_multi_tag(obj, del)
            [delCheck, obj.multiTagsCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.MultiTag', 'Group::removeMultiTag', ...
                obj.multiTagsCache);
        end;

    end;
end
