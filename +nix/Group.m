% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Group < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % Group nix Group object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Group'
    end

    methods
        function obj = Group(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = data_array_count(obj)
            r = nix_mx('Group::dataArrayCount', obj.nix_handle);
        end

        function r = has_data_array(obj, id_or_name)
            r = nix_mx('Group::hasDataArray', obj.nix_handle, id_or_name);
        end

        function r = get_data_array(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'Group::getDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'Group::openDataArrayIdx', idx, @nix.DataArray);
        end

        function [] = add_data_array(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.DataArray', 'Group::addDataArray');
        end

        function [] = add_data_arrays(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.DataArray', strcat(obj.alias, '::addDataArrays'));
        end

        function r = remove_data_array(obj, del)
            r = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'Group::removeDataArray');
        end

        function r = filter_data_arrays(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Group::dataArraysFiltered', @nix.DataArray);
        end

        % -----------------
        % Tags methods
        % -----------------

        function [] = add_tag(obj, add_this)
            nix.Utils.add_entity(obj, add_this, 'nix.Tag', 'Group::addTag');
        end

        function [] = add_tags(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.Tag', strcat(obj.alias, '::addTags'));
        end

        function r = has_tag(obj, id_or_name)
            r = nix_mx('Group::hasTag', obj.nix_handle, id_or_name);
        end

        function r = get_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Group::getTag', id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Group::openTagIdx', idx, @nix.Tag);
        end

        function r = remove_tag(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Tag', 'Group::removeTag');
        end

        function r = tag_count(obj)
            r = nix_mx('Group::tagCount', obj.nix_handle);
        end

        function r = filter_tags(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'Group::tagsFiltered', @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function [] = add_multi_tag(obj, add_this)
            nix.Utils.add_entity(obj, add_this, 'nix.MultiTag', 'Group::addMultiTag');
        end

        function [] = add_multi_tags(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.MultiTag', strcat(obj.alias, '::addMultiTags'));
        end

        function r = has_multi_tag(obj, id_or_name)
            r = nix_mx('Group::hasMultiTag', obj.nix_handle, id_or_name);
        end

        function r = get_multi_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'Group::getMultiTag', id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'Group::openMultiTagIdx', idx, @nix.MultiTag);
        end

        function r = remove_multi_tag(obj, del)
            r = nix.Utils.delete_entity(obj, del, ...
                'nix.MultiTag', 'Group::removeMultiTag');
        end

        function r = multi_tag_count(obj)
            r = nix_mx('Group::multiTagCount', obj.nix_handle);
        end

        function r = filter_multi_tags(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Group::multiTagsFiltered', @nix.MultiTag);
        end
    end

end
