% nix.Block class for basic grouping of further data entities.
%
% The Block entity is a top-level, summarizing element that allows to group the other 
% data entities belonging for example to the same recording session. It is
% the main entity to create nix.DataArrays, nix.Tags and nix.MultiTags.
%
% Please note that when a Block is deleted, all child entities will be 
% permanently deleted from the file as well.
%
% nix.Block dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, optional description of the entity.
%
% nix.Block dynamic child entity properties:
%   groups       access to all nix.Group child entities.
%   dataArrays   access to all nix.DataArray child entities.
%   sources      access to all first level nix.Source child entities.
%   tags         access to all nix.Tag child entities.
%   multiTags    access to all nix.MultiTag child entities.
%
% See also nix.DataArray, nix.Source, nix.Group, nix.Tag, nix.MultiTag, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Block < nix.NamedEntity & nix.MetadataMixIn

    properties (Hidden)
        alias = 'Block'  % nix-mx namespace to access Block specific nix backend functions.
    end

    methods
        function obj = Block(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();

            % assign child entities
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
            % Get the number of direct child nix.Groups.
            %
            % Returns:  (uint) The number of child (non nested) Groups.
            %
            % Example:  gc = currBlock.groupCount();
            %
            % See also nix.Group.

            r = nix.Utils.fetchEntityCount(obj, 'groupCount');
        end

        function r = createGroup(obj, name, type)
            % Create a new nix.Group entity associated with the invoking Block.
            %
            % name (char):  The name of the Group, has to be unique within the file.
            % type (char):  The type of the Group.
            %
            % Returns:  (nix.Group) The newly created Group.
            %
            % Example:  newGroup = currBlock.createGroup('subTrial2', 'ephys');
            %
            % See also nix.Group.

            fname = strcat(obj.alias, '::createGroup');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Group);
        end

        function r = hasGroup(obj, idName)
            % Check if a nix.Group exists as a direct child of the Block.
            %
            % idName (char):  Name or ID of the Group.
            %
            % Returns:  (logical) True if the Group exists, false otherwise.
            %
            % Example:  check = currBlock.hasGroup('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.hasGroup('subTrial2');
            %
            % See also nix.Group.

            r = nix.Utils.fetchHasEntity(obj, 'hasGroup', idName);
        end

        function r = openGroup(obj, idName)
            % Retrieves an existing Group from the invoking Block.
            %
            % idName (char):  Name or ID of the Group.
            %
            % Returns:  (nix.Group) The nix.Group or an empty cell, 
            %                       if the Group was not found.
            %
            % Example:  getGroup = currBlock.openGroup('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getGroup = currFile.blocks{1}.openGroup('subTrial2');
            %
            % See also nix.Group.

            r = nix.Utils.openEntity(obj, 'getGroup', idName, @nix.Group);
        end

        function r = openGroupIdx(obj, index)
            % Retrieves an existing nix.Group from the invoking Block, accessed by index.
            %
            % index (double):  The index of the Group to read.
            %
            % Returns:  (nix.Group) The Group at the given index.
            %
            % Example:  getGroup = currBlock.openGroupIdx(1);
            %
            % See also nix.Group.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openGroupIdx', idx, @nix.Group);
        end

        function r = deleteGroup(obj, idNameEntity)
            % Deletes a nix.Group from the invoking Block.
            %
            % When a Group is deleted, all its content (DataArray, Tags, Sources, etc)
            % will be deleted from the Block as well.
            %
            % idNameEntity (char/nix.Group):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Group has been removed, false otherwise.
            %
            % Example:  check = currBlock.deleteGroup('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currBlock.deleteGroup('trial1');
            %           check = currFile.blocks{1}.deleteGroup(newGroup);
            %
            % See also nix.Group.

            r = nix.Utils.deleteEntity(obj, 'deleteGroup', idNameEntity, 'nix.Group');
        end

        function r = filterGroups(obj, filter, val)
            % Get a filtered cell array of all child Groups of the invoking Block.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Group]) A cell array of Groups filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getGroups = currBlock.filterGroups(nix.Filter.type, 'ephys');
            %
            % See also nix.Group, nix.Filter.

            r = nix.Utils.filter(obj, 'groupsFiltered', filter, val, @nix.Group);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = dataArrayCount(obj)
            % Get the number of child nix.DataArrays.
            %
            % Returns:  (uint) The number of child DataArrays.
            %
            % Example:  dc = currBlock.dataArrayCount();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = openDataArray(obj, idName)
            % Retrieves an existing DataArray from the invoking Block.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (nix.DataArray) The nix.DataArray or an empty cell, 
            %                       if the DataArray was not found.
            %
            % Example:  getDA = currBlock.openDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getDA = currFile.blocks{1}.openDataArray('subTrial2');
            %
            % See also nix.DataArray.

            r = nix.Utils.openEntity(obj, 'openDataArray', idName, @nix.DataArray);
        end

        function r = openDataArrayIdx(obj, index)
            % Retrieves an existing nix.DataArray from the invoking Block, accessed by index.
            %
            % index (double):  The index of the DataArray to read.
            %
            % Returns:  (nix.DataArray) The DataArray at the given index.
            %
            % Example:  getDA = currBlock.openDataArrayIdx(1);
            %
            % See also nix.DataArray.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function r = createDataArray(obj, name, type, datatype, shape)
            % Create a new nix.DataArray entity associated with the invoking Block.
            %
            % name (char):  The name of the DataArray, has to be unique within the file.
            % type (char):  The type of the DataArray.
            % datatype (nix.DataType):  Provides the datatype of the data that the 
            %                           DataArray will contain. It has to be a valid
            %                           nix.DataType.
            % shape (double):  The dimensionality of the data that the DataArray will 
            %                    contain.
            %
            % Returns:  (nix.DataArray) The newly created DataArray.
            %
            % Example:  newDataArray = currBlock.createDataArray('sessionData1', ...
            %                             'epyhs_data', nix.DataType.Double, [12 15]);
            %             % allocates space for a 12x15 array of datatype double.
            %
            % See also nix.DataArray, nix.DataType.

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
                h = nix_mx(fname, obj.nixhandle, name, type, lower(datatype.char), shape);
                r = nix.Utils.createEntity(h, @nix.DataArray);
            end
        end

        function r = createDataArrayFromData(obj, name, type, data)
            % Create a new nix.DataArray entity associated with the invoking Block 
            % from existing data.
            %
            % Create a DataArray with shape and type inferred from data. After
            % successful creation, the contents of data will be written to the
            % DataArray.
            %
            % name (char):  The name of the DataArray, has to be unique within the file.
            % type (char):  The type of the DataArray, required.
            % data (var):   Raw data the DataArray is supposed to contain.
            %
            % Returns:  (nix.DataArray) The newly created DataArray.
            %
            % Example:  newDataArray = currBlock.createDataArray('sessionData2', ...
            %                               'epyhs_data', rawDataVariable);
            %
            % See also nix.DataArray, nix.DataType.

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

            r = obj.createDataArray(name, type, dtype, shape);
            r.writeAllData(data);
        end

        function r = hasDataArray(obj, idName)
            % Check if a nix.DataArray exists as a child of the Block.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (logical) True if the DataArray exists, false otherwise.
            %
            % Example:  check = currBlock.hasDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.hasDataArray('sessionData2');
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', idName);
        end

        function r = deleteDataArray(obj, idNameEntity)
            % Deletes a nix.DataArray from the invoking Block.
            %
            % When a DataArray is deleted, all its data content and
            % referenced Dimensions will be deleted from the Block as well.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the DataArray has been removed, false otherwise.
            %
            % Example:  check = currBlock.deleteDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currBlock.deleteDataArray('sessionData2');
            %           check = currFile.blocks{1}.deleteDataArray(newDataArray);
            %
            % See also nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'deleteDataArray', idNameEntity, 'nix.DataArray');
        end

        function r = filterDataArrays(obj, filter, val)
            % Get a filtered cell array of all DataArrays of the invoking Block.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.DataArray]) A cell array of DataArrays filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getDAs = currBlock.filterDataArrays(nix.Filter.type, 'ephys_data');
            %
            % See also nix.DataArray, nix.Filter.

            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Sources methods
        % -----------------

        function r = sourceCount(obj)
            % Get the number of direct child Sources.
            %
            % Returns:  (uint) The number of child (non nested) Sources.
            %
            % Example:  sc = currBlock.sourceCount();
            %
            % See also nix.Source.

            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        function r = createSource(obj, name, type)
            % Create a new nix.Source entity associated with the invoking Block.
            %
            % name (char):  The name of the Source, has to be unique within the file.
            % type (char):  The type of the Source.
            %
            % Returns:  (nix.Source) The newly created Source.
            %
            % Example:  newSource = currBlock.createSource('cell5', 'pyramidal');
            %
            % See also nix.Source.

            fname = strcat(obj.alias, '::createSource');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Source);
        end

        function r = hasSource(obj, idName)
            % Check if a nix.Source exists as a direct child of the Block.
            %
            % idName (char):  Name or ID of the Source.
            %
            % Returns:  (logical) True if the Source exists, false otherwise.
            %
            % Example:  check = currBlock.hasSource('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.hasSource('cell5');
            %
            % See also nix.Source.

            r = nix.Utils.fetchHasEntity(obj, 'hasSource', idName);
        end

        function r = deleteSource(obj, idNameEntity)
            % Deletes a nix.Source from the invoking Block.
            %
            % When a Source is deleted, all its child Sources will be deleted as well.
            %
            % idNameEntity (char/nix.Source):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Source has been removed, false otherwise.
            %
            % Example:  check = currBlock.deleteSource('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currBlock.deleteSource('cell5');
            %           check = currFile.blocks{1}.deleteSource(newSource);
            %
            % See also nix.Group.

            r = nix.Utils.deleteEntity(obj, 'deleteSource', idNameEntity, 'nix.Source');
        end

        function r = openSource(obj, idName)
            % Retrieves an existing direct Source from the invoking Block.
            %
            % idName (char):  Name or ID of the Source.
            %
            % Returns:  (nix.Source) The nix.Source or an empty cell, 
            %                       if the Source was not found.
            %
            % Example:  getSource = currBlock.openSource('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getSource = currFile.blocks{1}.openSource('cell5');
            %
            % See also nix.Source.

            r = nix.Utils.openEntity(obj, 'openSource', idName, @nix.Source);
        end

        function r = openSourceIdx(obj, index)
            % Retrieves an existing nix.Source from the invoking Block, accessed by index.
            %
            % index (double):  The index of the Source to read.
            %
            % Returns:  (nix.Source) The Source at the given index.
            %
            % Example:  getSource = currBlock.openSourceIdx(1);
            %
            % See also nix.Source.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = filterSources(obj, filter, val)
            % Get a filtered cell array of all child Sources of the invoking Block.
            %
            % filter (nix.Filter):  the nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Source]) A cell array of Sources filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getSources = currBlock.filterSources(nix.Filter.type, 'pyramidal');
            %
            % See also nix.Source, nix.Filter.

            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end

        function r = findSources(obj, maxDepth)
            % Get all Sources and their child Sources in the invoking Block recursively.
            %
            % This method traverses the trees of all Sources in the Block and adds all
            % Sources to the resulting cell array, until the maximum depth of the nested
            % Sources has been reached. The traversal is accomplished via breadth first 
            % and adds the Sources accordingly.
            %
            % maxDepth (double):  The maximum depth of traversal to retrieve nested 
            %                     Sources. Should be handled like an index.
            %
            % Example:  allSources = currBlock.findSources(2);
            %           % will add all Sources until including the 2nd layer of Sources.
            %
            % See also nix.Source.

            r = obj.filterFindSources(maxDepth, nix.Filter.acceptall, '');
        end

        function r = filterFindSources(obj, maxDepth, filter, val)
            % Get all Sources and their child Sources in the invoking Block recursively.
            %
            % This method traverses the trees of all Sources in the Block. The traversal
            % is accomplished via breadth first and can be limited in depth. On each 
            % node or Source a nix.Filter is applied. If the filter returns true, the 
            % respective Source will be added to the result list.
            %
            % maxDepth (double):    The maximum depth of traversal to retrieve nested 
            %                       Sources. Should be handled like an index.
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       the filters 'acceptall', 'id', 'ids',
            %                       'name' and 'type'.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Example:  allSources = currBlock.filterFindSources(...
            %                               2, nix.Filter.type, 'ephys');
            %
            % See also nix.Source, nix.Filter.

            r = nix.Utils.find(obj, 'findSources', maxDepth, filter, val, @nix.Source);
        end

        % -----------------
        % Tags methods
        % -----------------

        function r = tagCount(obj)
            % Get the number of child nix.Tags.
            %
            % Returns:  (uint) The number of child Tags.
            %
            % Example:  tc = currBlock.tagCount();
            %
            % See also nix.Tag.

            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = hasTag(obj, idName)
            % Check if a nix.Tag exists as a child of the Block.
            %
            % idName (char):  Name or ID of the Tag.
            %
            % Returns:  (logical) True if the Tag exists, false otherwise.
            %
            % Example:  check = currBlock.hasTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.hasTag('roi_1');
            %
            % See also nix.Tag.

            r = nix.Utils.fetchHasEntity(obj, 'hasTag', idName);
        end

        function r = openTag(obj, idName)
            % Retrieves an existing Tag from the invoking Block.
            %
            % idName (char):  Name or ID of the Tag.
            %
            % Returns:  (nix.Tag) The nix.Tag or an empty cell, 
            %                       if the Tag was not found.
            %
            % Example:  getTag = currBlock.openTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getTag = currFile.blocks{1}.openTag('roi_1');
            %
            % See also nix.Tag.

            r = nix.Utils.openEntity(obj, 'openTag', idName, @nix.Tag);
        end

        function r = openTagIdx(obj, index)
            % Retrieves an existing nix.Tag from the invoking Block, accessed by index.
            %
            % index (double):  The index of the Tag to read.
            %
            % Returns:  (nix.Tag) The Tag at the given index.
            %
            % Example:  getTag = currBlock.openTagIdx(1);
            %
            % See also nix.Tag.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = createTag(obj, name, type, position)
            % Create a new nix.Tag entity associated with the invoking Block.
            %
            %   name (char):        The name of the Tag, has to be unique within the file.
            %   type (char):        The type of the Tag.
            %   position (double):  Start position of the Tag. Position has to match 
            %                       the referenced data. If e.g. the referenced data is 
            %                       2D, the start position has to provide two coordinates
            %                       as well.
            %
            %   Returns:  (nix.Tag) The newly created Tag.
            %
            %   Example:  newTag = currBlock.createTag('roi_1', 'ephys', [12, 15]);
            %
            % See also nix.Tag.

            fname = strcat(obj.alias, '::createTag');
            h = nix_mx(fname, obj.nixhandle, name, type, position);
            r = nix.Utils.createEntity(h, @nix.Tag);
        end

        function r = deleteTag(obj, idNameEntity)
            % Deletes a nix.Tag from the invoking Block.
            %
            % When a Tag is deleted, all its Features will be deleted 
            % from the Block as well.
            %
            % idNameEntity (char/nix.Tag):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Tag has been removed, false otherwise.
            %
            % Example:  check = currBlock.deleteTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currBlock.deleteTag('roi_1');
            %           check = currFile.blocks{1}.deleteTag(newTag);
            %
            % See also nix.Tag.

            r = nix.Utils.deleteEntity(obj, 'deleteTag', idNameEntity, 'nix.Tag');
        end

        function r = filterTags(obj, filter, val)
            % Get a filtered cell array of all Tags of the invoking Block.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Tag]) A cell array of Tags filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getTags = currBlock.filterTags(nix.Filter.type, 'ephys');
            %
            % See also nix.Tag, nix.Filter.

            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function r = multiTagCount(obj)
            % Get the number of child nix.MultiTags.
            %
            % Returns:  (uint) The number of child MultiTags.
            %
            % Example:  mtc = currBlock.multiTagCount();
            %
            % See also nix.MultiTag.

            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = hasMultiTag(obj, idName)
            % Check if a nix.MultiTag exists as a child of the Block.
            %
            % idName (char):  Name or ID of the MultiTag.
            %
            % Returns:  (logical) True if the MultiTag exists, false otherwise.
            %
            % Example:  check = currBlock.hasMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.hasMultiTag('roi_2');
            %
            % See also nix.MultiTag.

            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', idName);
        end

        function r = openMultiTag(obj, idName)
            % Retrieves an existing MultiTag from the invoking Block.
            %
            % idName (char):  Name or ID of the MultiTag.
            %
            % Returns:  (nix.MultiTag) The nix.MultiTag or an empty cell, 
            %                       if the MultiTag was not found.
            %
            % Example:  getMT = currBlock.openMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getMT = currFile.blocks{1}.openMultiTag('roi_2');
            %
            % See also nix.MultiTag.

            r = nix.Utils.openEntity(obj, 'openMultiTag', idName, @nix.MultiTag);
        end

        function r = openMultiTagIdx(obj, index)
            % Retrieves an existing nix.MultiTag from the invoking Block, accessed by index.
            %
            % index (double):  The index of the MultiTag to read.
            %
            % Returns:  (nix.MultiTag) The MultiTag at the given index.
            %
            % Example:  getMT = currBlock.openMultiTagIdx(1);
            %
            % See also nix.MultiTag.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        function r = createMultiTag(obj, name, type, refDataArray)
            % Create a new nix.MultiTag entity associated with the invoking Block.
            %
            %   name (char):  The name of the MultiTag, has to be unique within the file.
            %   type (char):  The type of the MultiTag.
            %   refDataArray (nix.DataArray):  An existing DataArray, that will be 
            %                                  referenced by the created MultiTag.
            %
            %   Returns:  (nix.MultiTag) The newly created MultiTag.
            %
            %   Example:  newMultiTag = currBlock.createMultiTag('roi_2', 'ephys', refDA);
            %
            % See also nix.MultiTag.

            fname = strcat(obj.alias, '::createMultiTag');
            id = nix.Utils.parseEntityId(refDataArray, 'nix.DataArray');
            h = nix_mx(fname, obj.nixhandle, name, type, id);
            r = nix.Utils.createEntity(h, @nix.MultiTag);
        end

        function r = deleteMultiTag(obj, idNameEntity)
            % Deletes a nix.MultiTag from the invoking Block.
            %
            % When a MultiTag is deleted, all its Features will be deleted 
            % from the Block as well.
            %
            % idNameEntity (char/nix.MultiTag):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the MultiTag has been removed, false otherwise.
            %
            % Example:  check = currBlock.deleteMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currBlock.deleteMultiTag('roi_2');
            %           check = currFile.blocks{1}.deleteMultiTag(newMultiTag);
            %
            % See also nix.MultiTag.

            r = nix.Utils.deleteEntity(obj, 'deleteMultiTag', idNameEntity, 'nix.MultiTag');
        end

        function r = filterMultiTags(obj, filter, val)
            % Get a filtered cell array of all MultiTags of the invoking Block.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.MultiTag]) A cell array of MultiTags filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getMultiTags = currBlock.filterMultiTags(nix.Filter.type, 'ephys');
            %
            % See also nix.MultiTag, nix.Filter.

            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
