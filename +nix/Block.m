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
        end;
        
        % -----------------
        % Group methods
        % -----------------
        
        function c = group_count(obj)
            c = nix_mx('Block::groupCount', obj.nix_handle);
        end

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

        function retObj = open_group_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openGroupIdx', idx, @nix.Group);
        end

        function delCheck = delete_group(obj, del)
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.Group', 'Block::deleteGroup');
        end;

        function filtered = filter_groups(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'Block::groupsFiltered', @nix.Group);
        end
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function c = data_array_count(obj)
            c = nix_mx('Block::dataArrayCount', obj.nix_handle);
        end

        function retObj = data_array(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openDataArray', id_or_name, @nix.DataArray);
        end;

        function retObj = open_data_array_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openDataArrayIdx', idx, @nix.DataArray);
        end

        function da = create_data_array(obj, name, nixtype, datatype, shape)
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if(shape(1) == 1)
                shape(2:size(shape,2));
            end;
            
            errorStruct.identifier = 'Block:unsupportedDataType';
            if(~isa(datatype, 'nix.DataType'))
                errorStruct.message = 'Please provide a valid nix.DataType';
                error(errorStruct);
            elseif(isequal(datatype, nix.DataType.String))
                errorStruct.message = 'Writing Strings to DataArrays is not supported as of yet.';
                error(errorStruct);
            else
                handle = nix_mx('Block::createDataArray', obj.nix_handle, ...
                    name, nixtype, lower(datatype.char), shape);
                da = nix.DataArray(handle);
            end;
        end
        
        function da = create_data_array_from_data(obj, name, nixtype, data)
            shape = size(data);
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if(shape(1) == 1)
                shape = size(data, 2);
            end;

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
            end;

            da = obj.create_data_array(name, nixtype, dtype, shape);
            da.write_all(data);
        end

        function hasDA = has_data_array(obj, id_or_name)
            hasDA = nix_mx('Block::hasDataArray', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = delete_data_array(obj, del)
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Block::deleteDataArray');
        end;

        function filtered = filter_data_arrays(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'Block::dataArraysFiltered', @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------
        
        function c = source_count(obj)
            c = nix_mx('Block::sourceCount', obj.nix_handle);
        end

        function s = create_source(obj, name, type)
            s = nix.Source(nix_mx('Block::createSource', ...
                obj.nix_handle, name, type));
        end;
        
        function hasSource = has_source(obj, id_or_name)
            hasSource = nix_mx('Block::hasSource', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = delete_source(obj, del)
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.Source', 'Block::deleteSource');
        end;
        
        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openSource', id_or_name, @nix.Source);
        end;

        function retObj = open_source_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openSourceIdx', idx, @nix.Source);
        end

        function filtered = filter_sources(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'Block::sourcesFiltered', @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------
        
        function c = tag_count(obj)
            c = nix_mx('Block::tagCount', obj.nix_handle);
        end

        function hasTag = has_tag(obj, id_or_name)
            hasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
        end;
        
        function retObj = open_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openTag', id_or_name, @nix.Tag);
        end;

        function retObj = open_tag_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openTagIdx', idx, @nix.Tag);
        end

        function tag = create_tag(obj, name, type, position)
           th = nix_mx('Block::createTag', obj.nix_handle, ...
               name, type, position);
           tag = nix.Tag(th);
        end;

        function delCheck = delete_tag(obj, del)
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.Tag', 'Block::deleteTag');
        end;

        function filtered = filter_tags(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'Block::tagsFiltered', @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------
        
        function c = multi_tag_count(obj)
            c = nix_mx('Block::multiTagCount', obj.nix_handle);
        end

        function hasMTag = has_multi_tag(obj, id_or_name)
            hasMTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
        end;

        function retObj = open_multi_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openMultiTag', id_or_name, @nix.MultiTag);
        end;

        function retObj = open_multi_tag_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'Block::openMultiTagIdx', idx, @nix.MultiTag);
        end

        %-- Creating a multitag requires an already existing data array
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
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.MultiTag', 'Block::deleteMultiTag');
        end;

        function filtered = filter_multi_tags(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'Block::multiTagsFiltered', @nix.MultiTag);
        end

    end;
end
