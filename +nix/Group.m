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
            fname = strcat(obj.alias, '::dataArrayCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = has_data_array(obj, id_or_name)
            fname = strcat(obj.alias, '::hasDataArray');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = get_data_array(obj, id_or_name)
            fname = strcat(obj.alias, '::getDataArray');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, idx)
            fname = strcat(obj.alias, '::openDataArrayIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.DataArray);
        end

        function [] = add_data_array(obj, add_this)
            fname = strcat(obj.alias, '::addDataArray');
            nix.Utils.add_entity(obj, add_this, 'nix.DataArray', fname);
        end

        function [] = add_data_arrays(obj, add_cell_array)
            fname = strcat(obj.alias, '::addDataArrays');
            nix.Utils.add_entity_array(obj, add_cell_array, 'nix.DataArray', fname);
        end

        function r = remove_data_array(obj, del)
            fname = strcat(obj.alias, '::removeDataArray');
            r = nix.Utils.delete_entity(obj, del, 'nix.DataArray', fname);
        end

        function r = filter_data_arrays(obj, filter, val)
            fname = strcat(obj.alias, '::dataArraysFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.DataArray);
        end

        % -----------------
        % Tags methods
        % -----------------

        function [] = add_tag(obj, add_this)
            fname = strcat(obj.alias, '::addTag');
            nix.Utils.add_entity(obj, add_this, 'nix.Tag', fname);
        end

        function [] = add_tags(obj, add_cell_array)
            fname = strcat(obj.alias, '::addTags');
            nix.Utils.add_entity_array(obj, add_cell_array, 'nix.Tag', fname);
        end

        function r = has_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::hasTag');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = get_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::getTag');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, idx)
            fname = strcat(obj.alias, '::openTagIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Tag);
        end

        function r = remove_tag(obj, del)
            fname = strcat(obj.alias, '::removeTag');
            r = nix.Utils.delete_entity(obj, del, 'nix.Tag', fname);
        end

        function r = tag_count(obj)
            fname = strcat(obj.alias, '::tagCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_tags(obj, filter, val)
            fname = strcat(obj.alias, '::tagsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function [] = add_multi_tag(obj, add_this)
            fname = strcat(obj.alias, '::addMultiTag');
            nix.Utils.add_entity(obj, add_this, 'nix.MultiTag', fname);
        end

        function [] = add_multi_tags(obj, add_cell_array)
            fname = strcat(obj.alias, '::addMultiTags');
            nix.Utils.add_entity_array(obj, add_cell_array, 'nix.MultiTag', fname);
        end

        function r = has_multi_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::hasMultiTag');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = get_multi_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::getMultiTag');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, idx)
            fname = strcat(obj.alias, '::openMultiTagIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.MultiTag);
        end

        function r = remove_multi_tag(obj, del)
            fname = strcat(obj.alias, '::removeMultiTag');
            r = nix.Utils.delete_entity(obj, del, 'nix.MultiTag', fname);
        end

        function r = multi_tag_count(obj)
            fname = strcat(obj.alias, '::multiTagCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_multi_tags(obj, filter, val)
            fname = strcat(obj.alias, '::multiTagsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.MultiTag);
        end
    end

end
