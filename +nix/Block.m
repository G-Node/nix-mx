% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

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
        end

        % -----------------
        % Group methods
        % -----------------

        function r = group_count(obj)
            r = nix_mx('Block::groupCount', obj.nix_handle);
        end

        function r = create_group(obj, name, nixtype)
            h = nix_mx('Block::createGroup', obj.nix_handle, name, nixtype);
            r = nix.Group(h);
        end

        function r = has_group(obj, id_or_name)
            r = nix_mx('Block::hasGroup', obj.nix_handle, id_or_name);
        end

        function r = get_group(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Block::getGroup', id_or_name, @nix.Group);
        end

        function r = open_group_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Block::openGroupIdx', idx, @nix.Group);
        end

        function r = delete_group(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Group', 'Block::deleteGroup');
        end

        function r = filter_groups(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'Block::groupsFiltered', @nix.Group);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = data_array_count(obj)
            r = nix_mx('Block::dataArrayCount', obj.nix_handle);
        end

        function r = data_array(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'Block::openDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_data_array_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'Block::openDataArrayIdx', idx, @nix.DataArray);
        end

        function r = create_data_array(obj, name, nixtype, datatype, shape)
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if(shape(1) == 1)
                shape(2:size(shape, 2));
            end

            errorStruct.identifier = 'Block:unsupportedDataType';
            if(~isa(datatype, 'nix.DataType'))
                errorStruct.message = 'Please provide a valid nix.DataType';
                error(errorStruct);
            elseif(isequal(datatype, nix.DataType.String))
                errorStruct.message = 'Writing Strings to DataArrays is not supported as of yet.';
                error(errorStruct);
            else
                h = nix_mx('Block::createDataArray', obj.nix_handle, ...
                    name, nixtype, lower(datatype.char), shape);
                r = nix.DataArray(h);
            end
        end

        function r = create_data_array_from_data(obj, name, nixtype, data)
            shape = size(data);
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if(shape(1) == 1)
                shape = size(data, 2);
            end

            errorStruct.identifier = 'Block:unsupportedDataType';
            if(ischar(data))
                errorStruct.message = 'Writing Strings to DataArrays is not supported as of yet.';
                error(errorStruct);
            elseif(islogical(data))
                dtype = nix.DataType.Bool;
            elseif(isnumeric(data))
                dtype = nix.DataType.Double;
            else
                errorStruct.message = 'DataType of provided data is not supported.';
                error(errorStruct);
            end

            r = obj.create_data_array(name, nixtype, dtype, shape);
            r.write_all(data);
        end

        function r = has_data_array(obj, id_or_name)
            r = nix_mx('Block::hasDataArray', obj.nix_handle, id_or_name);
        end

        function r = delete_data_array(obj, del)
            r = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Block::deleteDataArray');
        end

        function r = filter_data_arrays(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Block::dataArraysFiltered', @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------

        function r = source_count(obj)
            r = nix_mx('Block::sourceCount', obj.nix_handle);
        end

        function r = create_source(obj, name, type)
            r = nix.Source(nix_mx('Block::createSource', obj.nix_handle, name, type));
        end

        function r = has_source(obj, id_or_name)
            r = nix_mx('Block::hasSource', obj.nix_handle, id_or_name);
        end

        function r = delete_source(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Source', 'Block::deleteSource');
        end

        function r = open_source(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Block::openSource', id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Block::openSourceIdx', idx, @nix.Source);
        end

        function r = filter_sources(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'Block::sourcesFiltered', @nix.Source);
        end

        % maxdepth is an index
        function r = find_sources(obj, max_depth)
            r = obj.find_filtered_sources(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sources(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, ...
                max_depth, filter, val, 'Block::findSources', @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------

        function r = tag_count(obj)
            r = nix_mx('Block::tagCount', obj.nix_handle);
        end

        function r = has_tag(obj, id_or_name)
            r = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
        end

        function r = open_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Block::openTag', id_or_name, @nix.Tag);
        end

        function r = open_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Block::openTagIdx', idx, @nix.Tag);
        end

        function r = create_tag(obj, name, type, position)
           h = nix_mx('Block::createTag', obj.nix_handle, name, type, position);
           r = nix.Tag(h);
        end

        function r = delete_tag(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Tag', 'Block::deleteTag');
        end

        function r = filter_tags(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'Block::tagsFiltered', @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function r = multi_tag_count(obj)
            r = nix_mx('Block::multiTagCount', obj.nix_handle);
        end

        function r = has_multi_tag(obj, id_or_name)
            r = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
        end

        function r = open_multi_tag(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'Block::openMultiTag', id_or_name, @nix.MultiTag);
        end

        function r = open_multi_tag_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Block::openMultiTagIdx', idx, @nix.MultiTag);
        end

        %-- Creating a multitag requires an already existing data array
        function r = create_multi_tag(obj, name, type, add_data_array)
            if(strcmp(class(add_data_array), 'nix.DataArray'))
                addID = add_data_array.id;
            else
                addID = add_data_array;
            end

            h = nix_mx('Block::createMultiTag', obj.nix_handle, name, type, addID);
            r = nix.MultiTag(h);
        end

        function r = delete_multi_tag(obj, del)
            r = nix.Utils.delete_entity(obj, ...
                del, 'nix.MultiTag', 'Block::deleteMultiTag');
        end

        function r = filter_multi_tags(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Block::multiTagsFiltered', @nix.MultiTag);
        end
    end

end
