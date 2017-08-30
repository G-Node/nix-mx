% nix.Group class for basic grouping of further data entities.
%
% nix.Groups establish a simple way of grouping entities that in some way belong 
% together. The Group exists inside a Block and can contain (link) DataArrays, Tags, 
% and MultiTags. As any other nix-entity, the Group is named, has a type, and a 
% definition property. Additionally, it contains DataArray, Tag, and MultiTag 
% lists. As indicated before, a Group does only link the entities. Thus, deleting 
% elements from a Group element does not remove them from file, it merely removes the link 
% from the Group.
%
% nix.Group dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, additional description of the entity.
%
% nix.Group dynamic child entity properties:
%   dataArrays   access to all nix.DataArray child entities.
%   tags         access to all nix.Tag child entities.
%   multiTags    access to all nix.MultiTag child entities.
%   sources      access to all first level nix.Source child entities.
%   sections     access to all first level nix.Section child entities.
%
% See also nix.DataArray, nix.Tag, nix.MultiTag, nix.Source, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Group < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn

    properties (Hidden)
        alias = 'Group'  % nix-mx namespace to access Group specific nix backend functions.
    end

    methods
        function obj = Group(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign child entities
            nix.Dynamic.addGetChildEntities(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.addGetChildEntities(obj, 'tags', @nix.Tag);
            nix.Dynamic.addGetChildEntities(obj, 'multiTags', @nix.MultiTag);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = dataArrayCount(obj)
            % Get the number of child nix.DataArrays.
            %
            % Returns:  (uint) The number of child DataArrays.
            %
            % Example:  dc = currGroup.dataArrayCount();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = hasDataArray(obj, idName)
            % Check if a nix.DataArray exists as a child of the Group.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (logical) True if the DataArray exists, false otherwise.
            %
            % Example:  check = currGroup.hasDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.groups{1}.hasDataArray('sessionData2');
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', idName);
        end

        function r = openDataArray(obj, idName)
            % Retrieves an existing DataArray from the invoking Group.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (nix.DataArray) The nix.DataArray or an empty cell, 
            %                       if the DataArray was not found.
            %
            % Example:  getDA = currGroup.openDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getDA = currFile.blocks{1}.groups{1}.openDataArray('subTrial2');
            %
            % See also nix.DataArray.

            r = nix.Utils.openEntity(obj, 'getDataArray', idName, @nix.DataArray);
        end

        function r = openDataArrayIdx(obj, index)
            % Retrieves an existing nix.DataArray from the invoking Group, 
            % accessed by index.
            %
            % index (double):  The index of the DataArray to read.
            %
            % Returns:  (nix.DataArray) The DataArray at the given index.
            %
            % Example:  getDA = currGroup.openDataArrayIdx(1);
            %
            % See also nix.DataArray.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function [] = addDataArray(obj, idNameEntity)
            % Add a nix.DataArray to the referenced list of the invoking Group.
            %
            % idNameEntity (char/nix.DataArray):  The id or name of an existing DataArray,
            %                                     or a valid nix.DataArray entity.
            %
            % Example:  currGroup.addDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currGroup.addDataArray('subTrial2');
            %           currFile.blocks{1}.groups{1}.addDataArray(currDataArrayEntity);
            %
            % See also nix.DataArray.

            nix.Utils.addEntity(obj, 'addDataArray', idNameEntity, 'nix.DataArray');
        end

        function [] = addDataArrays(obj, entityArray)
            % Set the list of referenced DataArrays for the invoking Group.
            %
            % Previously referenced DataArrays that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.DataArray]):  A cell array of nix.DataArrays.
            %
            % Example:  currGroup.addDataArrays({dataArray1, dataArray2});
            %
            % See also nix.DataArray.

            nix.Utils.addEntityArray(obj, 'addDataArrays', entityArray, 'nix.DataArray');
        end

        function r = removeDataArray(obj, idNameEntity)
            % Removes the reference to a nix.DataArray from the invoking Group.
            %
            % This method removes the association between the DataArray and the
            % Group, the DataArray itself will not be removed from the file.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the reference to the DataArray 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currGroup.removeDataArray('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currGroup.removeDataArray('sessionData2');
            %           check = currFile.blocks{1}.groups{1}.removeDataArray(newDataArray);
            %
            % See also nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'removeDataArray', idNameEntity, 'nix.DataArray');
        end

        function r = filterDataArrays(obj, filter, val)
            % Get a filtered cell array of all DataArrays referenced by the invoking Group.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.DataArray]) A cell array of DataArrays filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getDAs = currGroup.filterDataArrays(nix.Filter.type, 'ephys_data');
            %
            % See also nix.DataArray, nix.Filter.

            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Tags methods
        % -----------------

        function [] = addTag(obj, idNameEntity)
            % Add a nix.Tag to the referenced list of the invoking Group.
            %
            % idNameEntity (char/nix.Tag):  The id or name of an existing Tag,
            %                                     or a valid nix.Tag entity.
            %
            % Example:  currGroup.addTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currGroup.addTag('roi_1');
            %           currFile.blocks{1}.groups{1}.addTag(currTagEntity);
            %
            % See also nix.Tag.

            nix.Utils.addEntity(obj, 'addTag', idNameEntity, 'nix.Tag');
        end

        function [] = addTags(obj, entityArray)
            % Set the list of referenced Tags for the invoking Group.
            %
            % Previously referenced Tags that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.Tag]):  A cell array of nix.Tags.
            %
            % Example:  currGroup.addTags({tag1, tag2});
            %
            % See also nix.Tag.

            nix.Utils.addEntityArray(obj, 'addTags', entityArray, 'nix.Tag');
        end

        function r = hasTag(obj, idName)
            % Check if a nix.Tag exists as a child of the Group.
            %
            % idName (char):  Name or ID of the Tag.
            %
            % Returns:  (logical) True if the Tag exists, false otherwise.
            %
            % Example:  check = currGroup.hasTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.groups{1}.hasTag('roi_1');
            %
            % See also nix.Tag.

            r = nix.Utils.fetchHasEntity(obj, 'hasTag', idName);
        end

        function r = openTag(obj, idName)
            % Retrieves an existing Tag from the invoking Group.
            %
            % idName (char):  Name or ID of the Tag.
            %
            % Returns:  (nix.Tag) The nix.Tag or an empty cell, 
            %                       if the Tag was not found.
            %
            % Example:  getTag = currGroup.openTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getTag = currFile.blocks{1}.groups{1}.openTag('roi_1');
            %
            % See also nix.Tag.

            r = nix.Utils.openEntity(obj, 'getTag', idName, @nix.Tag);
        end

        function r = openTagIdx(obj, index)
            % Retrieves an existing nix.Tag from the invoking Group, 
            % accessed by index.
            %
            % index (double):  The index of the Tag to read.
            %
            % Returns:  (nix.Tag) The Tag at the given index.
            %
            % Example:  getTag = currGroup.openTagIdx(1);
            %
            % See also nix.Tag.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = removeTag(obj, idNameEntity)
            % Removes the reference to a nix.Tag from the invoking Group.
            %
            % This method removes the association between the Tag and the
            % Group, the Tag itself will not be removed from the file.
            %
            % idNameEntity (char/nix.Tag):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the reference to the Tag 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currGroup.removeTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currGroup.removeTag('roi_1');
            %           check = currFile.blocks{1}.groups{1}.removeTag(newTag);
            %
            % See also nix.Tag.

            r = nix.Utils.deleteEntity(obj, 'removeTag', idNameEntity, 'nix.Tag');
        end

        function r = tagCount(obj)
            % Get the number of child nix.Tags.
            %
            % Returns:  (uint) The number of child Tags.
            %
            % Example:  tc = currGroup.tagCount();
            %
            % See also nix.Tag.

            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = filterTags(obj, filter, val)
            % Get a filtered cell array of all Tags referenced by the invoking Group.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Tag]) A cell array of Tags filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getTags = currGroup.filterTags(nix.Filter.type, 'ephys');
            %
            % See also nix.Tag, nix.Filter.

            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function [] = addMultiTag(obj, idNameEntity)
            % Add a nix.MultiTag to the referenced list of the invoking Group.
            %
            % idNameEntity (char/nix.MultiTag):  The id or name of an existing MultiTag,
            %                                     or a valid nix.MultiTag entity.
            %
            % Example:  currGroup.addMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currGroup.addMultiTag('roi_2');
            %           currFile.blocks{1}.groups{1}.addMultiTag(currMultiTagEntity);
            %
            % See also nix.MultiTag.

            nix.Utils.addEntity(obj, 'addMultiTag', idNameEntity, 'nix.MultiTag');
        end

        function [] = addMultiTags(obj, entityArray)
            % Set the list of referenced MultiTags for the invoking Group.
            %
            % Previously referenced MultiTags that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.MultiTag]):  A cell array of nix.MultiTags.
            %
            % Example:  currGroup.addMultiTags({multiTag1, multiTag2});
            %
            % See also nix.MultiTag.

            nix.Utils.addEntityArray(obj, 'addMultiTags', entityArray, 'nix.MultiTag');
        end

        function r = hasMultiTag(obj, idName)
            % Check if a nix.MultiTag is referenced by the Group.
            %
            % idName (char):  Name or ID of the MultiTag.
            %
            % Returns:  (logical) True if the MultiTag exists, false otherwise.
            %
            % Example:  check = currGroup.hasMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.groups{1}.hasMultiTag('roi_2');
            %
            % See also nix.MultiTag.

            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', idName);
        end

        function r = openMultiTag(obj, idName)
            % Retrieves an existing MultiTag from the invoking Group.
            %
            % idName (char):  Name or ID of the MultiTag.
            %
            % Returns:  (nix.MultiTag) The nix.MultiTag or an empty cell, 
            %                       if the MultiTag was not found.
            %
            % Example:  getMT = currGroup.openMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getMT = currFile.blocks{1}.groups{1}.openMultiTag('roi_2');
            %
            % See also nix.MultiTag.

            r = nix.Utils.openEntity(obj, 'getMultiTag', idName, @nix.MultiTag);
        end

        function r = openMultiTagIdx(obj, index)
            % Retrieves an existing nix.MultiTag from the invoking Group, 
            % accessed by index.
            %
            % index (double):  The index of the MultiTag to read.
            %
            % Returns:  (nix.MultiTag) The MultiTag at the given index.
            %
            % Example:  getMultiTag = currGroup.openMultiTagIdx(1);
            %
            % See also nix.MultiTag.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        function r = removeMultiTag(obj, idNameEntity)
            % Removes the reference to a nix.MultiTag from the invoking Group.
            %
            % This method removes the association between the MultiTag and the
            % Group, the MultiTag itself will not be removed from the file.
            %
            % idNameEntity (char/nix.MultiTag):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the reference to the MultiTag 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currGroup.removeMultiTag('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currGroup.removeMultiTag('roi_2');
            %           check = currFile.blocks{1}.groups{1}.removeMultiTag(newMultiTag);
            %
            % See also nix.MultiTag.

            r = nix.Utils.deleteEntity(obj, 'removeMultiTag', idNameEntity, 'nix.MultiTag');
        end

        function r = multiTagCount(obj)
            % Get the number of child nix.MultiTags.
            %
            % Returns:  (uint) The number of child MultiTags.
            %
            % Example:  mtc = currGroup.multiTagCount();
            %
            % See also nix.MultiTag.

            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = filterMultiTags(obj, filter, val)
            % Get a filtered cell array of all MultiTags referenced by the invoking Group.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.MultiTag]) A cell array of MultiTags filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getMultiTags = currGroup.filterMultiTags(nix.Filter.type, 'ephys');
            %
            % See also nix.MultiTag, nix.Filter.

            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
