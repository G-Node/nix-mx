% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Block < nix.NamedEntity & nix.MetadataMixIn
    % Block nix Block object

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
        end

        % -----------------
        % Group methods
        % -----------------

        function r = group_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'groupCount');
        end

        function r = create_group(obj, name, nixtype)
            fname = strcat(obj.alias, '::createGroup');
            h = nix_mx(fname, obj.nix_handle, name, nixtype);
            r = nix.Utils.createEntity(h, @nix.Group);
        end

        function r = has_group(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasGroup', id_or_name);
        end

        function r = get_group(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'getGroup', id_or_name, @nix.Group);
        end

        function r = open_group_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openGroupIdx', idx, @nix.Group);
        end

        function r = delete_group(obj, idNameEntity)
            r = nix.Utils.delete_entity(obj, 'deleteGroup', idNameEntity, 'nix.Group');
        end

        function r = filter_groups(obj, filter, val)
            r = nix.Utils.filter(obj, 'groupsFiltered', filter, val, @nix.Group);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = data_array_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = data_array(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function r = create_data_array(obj, name, nixtype, datatype, shape)
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if (shape(1) == 1)
                shape(2:size(shape, 2));
            end

            err.identifier = 'Block:unsupportedDataType';
            if (~isa(datatype, 'nix.DataType'))
                err.message = 'Please provide a valid nix.DataType';
                error(err);
            elseif (isequal(datatype, nix.DataType.String))
                err.message = 'Writing char/string DataArrays is currently not supported.';
                error(err);
            else
                fname = strcat(obj.alias, '::createDataArray');
                h = nix_mx(fname, obj.nix_handle, name, nixtype, lower(datatype.char), shape);
                r = nix.Utils.createEntity(h, @nix.DataArray);
            end
        end

        function r = create_data_array_from_data(obj, name, nixtype, data)
            shape = size(data);
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if (shape(1) == 1)
                shape = size(data, 2);
            end

            err.identifier = 'Block:unsupportedDataType';
            if (ischar(data))
                err.message = 'Writing char/string DataArrays is currently not supported.';
                error(err);
            elseif (islogical(data))
                dtype = nix.DataType.Bool;
            elseif (isnumeric(data))
                dtype = nix.DataType.Double;
            else
                err.message = 'DataType of provided data is not supported.';
                error(err);
            end

            r = obj.create_data_array(name, nixtype, dtype, shape);
            r.write_all(data);
        end

        function r = has_data_array(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', id_or_name);
        end

        function r = delete_data_array(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteDataArray', del, 'nix.DataArray');
        end

        function r = filter_data_arrays(obj, filter, val)
            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------

        function r = source_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        function r = create_source(obj, name, type)
            fname = strcat(obj.alias, '::createSource');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Source);
        end

        function r = has_source(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasSource', id_or_name);
        end

        function r = delete_source(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteSource', del, 'nix.Source');
        end

        function r = open_source(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openSource', id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = filter_sources(obj, filter, val)
            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end

        % maxdepth is an index
        function r = find_sources(obj, max_depth)
            r = obj.find_filtered_sources(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sources(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, 'findSources', max_depth, filter, val, @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------

        function r = tag_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = has_tag(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasTag', id_or_name);
        end

        function r = open_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openTag', id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = create_tag(obj, name, type, position)
            fname = strcat(obj.alias, '::createTag');
            h = nix_mx(fname, obj.nix_handle, name, type, position);
            r = nix.Utils.createEntity(h, @nix.Tag);
        end

        function r = delete_tag(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteTag', del, 'nix.Tag');
        end

        function r = filter_tags(obj, filter, val)
            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function r = multi_tag_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = has_multi_tag(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', id_or_name);
        end

        function r = open_multi_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openMultiTag', id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        %-- Creating a multitag requires an already existing data array
        function r = create_multi_tag(obj, name, type, add_data_array)
            fname = strcat(obj.alias, '::createMultiTag');
            id = nix.Utils.parseEntityId(add_data_array, 'nix.DataArray');
            h = nix_mx(fname, obj.nix_handle, name, type, id);
            r = nix.Utils.createEntity(h, @nix.MultiTag);
        end

        function r = delete_multi_tag(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteMultiTag', del, 'nix.MultiTag');
        end

        function r = filter_multi_tags(obj, filter, val)
            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
