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
            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = has_data_array(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', id_or_name);
        end

        function r = get_data_array(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'getDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, index)
            idx = nix.Utils.handle_index(index);
            r = nix.Utils.open_entity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function [] = add_data_array(obj, add_this)
            nix.Utils.add_entity(obj, 'addDataArray', add_this, 'nix.DataArray');
        end

        function [] = add_data_arrays(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, 'addDataArrays', add_cell_array, 'nix.DataArray');
        end

        function r = remove_data_array(obj, del)
            r = nix.Utils.delete_entity(obj, 'removeDataArray', del, 'nix.DataArray');
        end

        function r = filter_data_arrays(obj, filter, val)
            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Tags methods
        % -----------------

        function [] = add_tag(obj, add_this)
            nix.Utils.add_entity(obj, 'addTag', add_this, 'nix.Tag');
        end

        function [] = add_tags(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, 'addTags', add_cell_array, 'nix.Tag');
        end

        function r = has_tag(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasTag', id_or_name);
        end

        function r = get_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'getTag', id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, index)
            idx = nix.Utils.handle_index(index);
            r = nix.Utils.open_entity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = remove_tag(obj, del)
            r = nix.Utils.delete_entity(obj, 'removeTag', del, 'nix.Tag');
        end

        function r = tag_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = filter_tags(obj, filter, val)
            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function [] = add_multi_tag(obj, add_this)
            nix.Utils.add_entity(obj, 'addMultiTag', add_this, 'nix.MultiTag');
        end

        function [] = add_multi_tags(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, 'addMultiTags', add_cell_array, 'nix.MultiTag');
        end

        function r = has_multi_tag(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', id_or_name);
        end

        function r = get_multi_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'getMultiTag', id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, index)
            idx = nix.Utils.handle_index(index);
            r = nix.Utils.open_entity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        function r = remove_multi_tag(obj, del)
            r = nix.Utils.delete_entity(obj, 'removeMultiTag', del, 'nix.MultiTag');
        end

        function r = multi_tag_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = filter_multi_tags(obj, filter, val)
            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
