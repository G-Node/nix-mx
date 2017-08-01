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
            fname = strcat(obj.alias, '::groupCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = create_group(obj, name, nixtype)
            fname = strcat(obj.alias, '::createGroup');
            h = nix_mx(fname, obj.nix_handle, name, nixtype);
            r = nix.Group(h);
        end

        function r = has_group(obj, id_or_name)
            fname = strcat(obj.alias, '::hasGroup');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = get_group(obj, id_or_name)
            fname = strcat(obj.alias, '::getGroup');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Group);
        end

        function r = open_group_idx(obj, idx)
            fname = strcat(obj.alias, '::openGroupIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Group);
        end

        function r = delete_group(obj, del)
            fname = strcat(obj.alias, '::deleteGroup');
            r = nix.Utils.delete_entity(obj, del, 'nix.Group', fname);
        end

        function r = filter_groups(obj, filter, val)
            fname = strcat(obj.alias, '::groupsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Group);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = data_array_count(obj)
            fname = strcat(obj.alias, '::dataArrayCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = data_array(obj, id_or_name)
            fname = strcat(obj.alias, '::openDataArray');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, idx)
            fname = strcat(obj.alias, '::openDataArrayIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.DataArray);
        end

        function r = create_data_array(obj, name, nixtype, datatype, shape)
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if (shape(1) == 1)
                shape(2:size(shape, 2));
            end

            errorStruct.identifier = 'Block:unsupportedDataType';
            if (~isa(datatype, 'nix.DataType'))
                errorStruct.message = 'Please provide a valid nix.DataType';
                error(errorStruct);
            elseif (isequal(datatype, nix.DataType.String))
                errorStruct.message = 'Writing Strings to DataArrays is not supported as of yet.';
                error(errorStruct);
            else
                fname = strcat(obj.alias, '::createDataArray');
                h = nix_mx(fname, obj.nix_handle, name, nixtype, lower(datatype.char), shape);
                r = nix.DataArray(h);
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

            errorStruct.identifier = 'Block:unsupportedDataType';
            if (ischar(data))
                errorStruct.message = 'Writing Strings to DataArrays is not supported as of yet.';
                error(errorStruct);
            elseif (islogical(data))
                dtype = nix.DataType.Bool;
            elseif (isnumeric(data))
                dtype = nix.DataType.Double;
            else
                errorStruct.message = 'DataType of provided data is not supported.';
                error(errorStruct);
            end

            r = obj.create_data_array(name, nixtype, dtype, shape);
            r.write_all(data);
        end

        function r = has_data_array(obj, id_or_name)
            fname = strcat(obj.alias, '::hasDataArray');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = delete_data_array(obj, del)
            fname = strcat(obj.alias, '::deleteDataArray');
            r = nix.Utils.delete_entity(obj, del, 'nix.DataArray', fname);
        end

        function r = filter_data_arrays(obj, filter, val)
            fname = strcat(obj.alias, '::dataArraysFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------

        function r = source_count(obj)
            fname = strcat(obj.alias, '::sourceCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = create_source(obj, name, type)
            fname = strcat(obj.alias, '::createSource');
            r = nix.Source(nix_mx(fname, obj.nix_handle, name, type));
        end

        function r = has_source(obj, id_or_name)
            fname = strcat(obj.alias, '::hasSource');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = delete_source(obj, del)
            fname = strcat(obj.alias, '::deleteSource');
            r = nix.Utils.delete_entity(obj, del, 'nix.Source', fname);
        end

        function r = open_source(obj, id_or_name)
            fname = strcat(obj.alias, '::openSource');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            fname = strcat(obj.alias, '::openSourceIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Source);
        end

        function r = filter_sources(obj, filter, val)
            fname = strcat(obj.alias, '::sourcesFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Source);
        end

        % maxdepth is an index
        function r = find_sources(obj, max_depth)
            r = obj.find_filtered_sources(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sources(obj, max_depth, filter, val)
            fname = strcat(obj.alias, '::findSources');
            r = nix.Utils.find(obj, max_depth, filter, val, fname, @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------

        function r = tag_count(obj)
            fname = strcat(obj.alias, '::tagCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = has_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::hasTag');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = open_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::openTag');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, idx)
            fname = strcat(obj.alias, '::openTagIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Tag);
        end

        function r = create_tag(obj, name, type, position)
            fname = strcat(obj.alias, '::createTag');
            h = nix_mx(fname, obj.nix_handle, name, type, position);
            r = nix.Tag(h);
        end

        function r = delete_tag(obj, del)
            fname = strcat(obj.alias, '::deleteTag');
            r = nix.Utils.delete_entity(obj, del, 'nix.Tag', fname);
        end

        function r = filter_tags(obj, filter, val)
            fname = strcat(obj.alias, '::tagsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function r = multi_tag_count(obj)
            fname = strcat(obj.alias, '::multiTagCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = has_multi_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::hasMultiTag');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = open_multi_tag(obj, id_or_name)
            fname = strcat(obj.alias, '::openMultiTag');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, idx)
            fname = strcat(obj.alias, '::openMultiTagIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.MultiTag);
        end

        %-- Creating a multitag requires an already existing data array
        function r = create_multi_tag(obj, name, type, add_data_array)
            if (isa(add_data_array, 'nix.DataArray'))
                addID = add_data_array.id;
            else
                addID = add_data_array;
            end

            fname = strcat(obj.alias, '::createMultiTag');
            h = nix_mx(fname, obj.nix_handle, name, type, addID);
            r = nix.MultiTag(h);
        end

        function r = delete_multi_tag(obj, del)
            fname = strcat(obj.alias, '::deleteMultiTag');
            r = nix.Utils.delete_entity(obj, del, 'nix.MultiTag', fname);
        end

        function r = filter_multi_tags(obj, filter, val)
            fname = strcat(obj.alias, '::multiTagsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.MultiTag);
        end
    end

end
