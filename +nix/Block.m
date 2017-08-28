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
            nix.Dynamic.addGetChildEntities(obj, 'groups', @nix.Group);
            nix.Dynamic.addGetChildEntities(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.addGetChildEntities(obj, 'sources', @nix.Source);
            nix.Dynamic.addGetChildEntities(obj, 'tags', @nix.Tag);
            nix.Dynamic.addGetChildEntities(obj, 'multiTags', @nix.MultiTag);
        end

        % -----------------
        % Group methods
        % -----------------

        function r = groupCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'groupCount');
        end

        function r = createGroup(obj, name, nixtype)
            fname = strcat(obj.alias, '::createGroup');
            h = nix_mx(fname, obj.nixhandle, name, nixtype);
            r = nix.Utils.createEntity(h, @nix.Group);
        end

        function r = hasGroup(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasGroup', idName);
        end

        function r = openGroup(obj, idName)
            r = nix.Utils.openEntity(obj, 'getGroup', idName, @nix.Group);
        end

        function r = openGroupIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openGroupIdx', idx, @nix.Group);
        end

        function r = deleteGroup(obj, idNameEntity)
            r = nix.Utils.deleteEntity(obj, 'deleteGroup', idNameEntity, 'nix.Group');
        end

        function r = filterGroups(obj, filter, val)
            r = nix.Utils.filter(obj, 'groupsFiltered', filter, val, @nix.Group);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = dataArrayCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = openDataArray(obj, idName)
            r = nix.Utils.openEntity(obj, 'openDataArray', idName, @nix.DataArray);
        end

        function r = openDataArrayIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function r = createDataArray(obj, name, nixtype, datatype, shape)
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if (shape(1) == 1)
                shape(2:size(shape, 2));
            end

            err.identifier = 'NIXMX:UnsupportedDataType';
            if (~isa(datatype, 'nix.DataType'))
                err.message = 'Please provide a valid nix.DataType';
                error(err);
            elseif (isequal(datatype, nix.DataType.String))
                err.message = 'Writing char/string DataArrays is currently not supported.';
                error(err);
            else
                fname = strcat(obj.alias, '::createDataArray');
                h = nix_mx(fname, obj.nixhandle, name, nixtype, lower(datatype.char), shape);
                r = nix.Utils.createEntity(h, @nix.DataArray);
            end
        end

        function r = createDataArrayFromData(obj, name, nixtype, data)
            shape = size(data);
            %-- Quick fix to enable alias range dimension with
            %-- 1D data arrays created with this function.
            %-- e.g. size([1 2 3]) returns shape [1 3], which would not
            %-- be accepted when trying to add an alias range dimension.
            if (shape(1) == 1)
                shape = size(data, 2);
            end

            err.identifier = 'NIXMX:UnsupportedDataType';
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

            r = obj.createDataArray(name, nixtype, dtype, shape);
            r.writeAllData(data);
        end

        function r = hasDataArray(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', idName);
        end

        function r = deleteDataArray(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteDataArray', del, 'nix.DataArray');
        end

        function r = filterDataArrays(obj, filter, val)
            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------

        function r = sourceCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        function r = createSource(obj, name, type)
            fname = strcat(obj.alias, '::createSource');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Source);
        end

        function r = hasSource(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasSource', idName);
        end

        function r = deleteSource(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteSource', del, 'nix.Source');
        end

        function r = openSource(obj, idName)
            r = nix.Utils.openEntity(obj, 'openSource', idName, @nix.Source);
        end

        function r = openSourceIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = filterSources(obj, filter, val)
            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end

        % maxdepth is an index
        function r = findSources(obj, maxDepth)
            r = obj.filterFindSources(maxDepth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = filterFindSources(obj, maxDepth, filter, val)
            r = nix.Utils.find(obj, 'findSources', maxDepth, filter, val, @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------

        function r = tagCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = hasTag(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasTag', idName);
        end

        function r = openTag(obj, idName)
            r = nix.Utils.openEntity(obj, 'openTag', idName, @nix.Tag);
        end

        function r = openTagIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = createTag(obj, name, type, position)
            fname = strcat(obj.alias, '::createTag');
            h = nix_mx(fname, obj.nixhandle, name, type, position);
            r = nix.Utils.createEntity(h, @nix.Tag);
        end

        function r = deleteTag(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteTag', del, 'nix.Tag');
        end

        function r = filterTags(obj, filter, val)
            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function r = multiTagCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = hasMultiTag(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', idName);
        end

        function r = openMultiTag(obj, idName)
            r = nix.Utils.openEntity(obj, 'openMultiTag', idName, @nix.MultiTag);
        end

        function r = openMultiTagIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        %-- Creating a multitag requires an already existing data array
        function r = createMultiTag(obj, name, type, refDataArray)
            fname = strcat(obj.alias, '::createMultiTag');
            id = nix.Utils.parseEntityId(refDataArray, 'nix.DataArray');
            h = nix_mx(fname, obj.nixhandle, name, type, id);
            r = nix.Utils.createEntity(h, @nix.MultiTag);
        end

        function r = deleteMultiTag(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteMultiTag', del, 'nix.MultiTag');
        end

        function r = filterMultiTags(obj, filter, val)
            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
