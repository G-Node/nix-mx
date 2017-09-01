% nix.Source class is used to describe the provenance of other entities 
% of the NIX data model.
%
% The Source entity is used to note the provenance of the data and offers the 
% option to bind simple, low level additional metadata.
% One special feature of the Source is the possibility to reference other Sources as 
% children thus building up a tree of Sources.
% This can, for example, be used to specify that a Source 'electrode array' contains
% multiple electrodes as its child Sources.
%
% nix.Source dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, additional description of the entity.
%
% nix.Source dynamic child entity properties:
%   sources      access to all nix.Source child entities.
%
% See also nix.Block, nix.DataArray, nix.Tag, nix.MultiTag, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Source < nix.NamedEntity & nix.MetadataMixIn

    properties (Hidden)
        alias = 'Source'  % nix-mx namespace to access Source specific nix backend functions.
    end

    methods
        function obj = Source(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();

            % assign child entities
            nix.Dynamic.addGetChildEntities(obj, 'sources', @nix.Source);
        end

        % ------------------
        % Sources methods
        % ------------------

        function r = sourceCount(obj)
            % Get the number of direct child nix.Sources.
            %
            % Returns:  (uint) The number of child Sources.
            %
            % Example:  sc = currSource.sourceCount();

            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        function r = createSource(obj, name, type)
            % Create a new nix.Source entity associated with the invoking Source.
            %
            % name (char):  The name of the Source, has to be unique within the file.
            % type (char):  The type of the Source.
            %
            % Returns:  (nix.Source) The newly created Source.
            %
            % Example:  newSource = currSource.createSource('cell5', 'pyramidal');

            fname = strcat(obj.alias, '::createSource');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Source);
        end

        function r = hasSource(obj, idName)
            % Check if a nix.Source exists as a direct child of the invoking Source.
            %
            % idName (char):  Name or ID of the Source.
            %
            % Returns:  (logical) True if the Source exists, false otherwise.
            %
            % Example:  check = currSource.hasSource('some-source-id');
            %           check = currFile.blocks{1}.sources{1}.hasSource('cell5');

            r = nix.Utils.fetchHasEntity(obj, 'hasSource', idName);
        end

        function r = deleteSource(obj, idNameEntity)
            % Deletes a nix.Source and its children from the invoking Source.
            %
            % When a Source is deleted, all its sub-Sources
            % will be deleted recursively from the Source as well.
            %
            % idNameEntity (char/nix.Source):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Source has been removed, false otherwise.
            %
            % Example:  check = currSource.deleteSource('23bb8a99-1812-4bc6-a52c');
            %           check = currSource.deleteSource('cell5');
            %           check = currFile.blocks{1}.sources{1}.deleteSource(newSource);

            r = nix.Utils.deleteEntity(obj, 'deleteSource', idNameEntity, 'nix.Source');
        end

        function r = openSource(obj, idName)
            % Retrieves an existing direct Source from the invoking Source.
            %
            % idName (char):  Name or ID of the Source.
            %
            % Returns:  (nix.Source) The nix.Source or an empty cell, 
            %                       if the Source was not found.
            %
            % Example:  getSource = currSource.openSource('23bb8a99-1812-4bc6-a52c');
            %           getSource = currFile.blocks{1}.sources{1}.openSource('cell5');

            r = nix.Utils.openEntity(obj, 'openSource', idName, @nix.Source);
        end

        function r = openSourceIdx(obj, index)
            % Retrieves an existing nix.Source from the invoking Source, 
            % accessed by index.
            %
            % index (double):  The index of the Source to read.
            %
            % Returns:  (nix.Source) The Source at the given index.
            %
            % Example:  getSource = currSource.openSourceIdx(1);

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = parentSource(obj)
            % Returns the parent Source of the invoking Source. Method performs a search,
            % may thus not be the most efficient way.
            %
            % Returns:  (nix.Source) The parent Source if there is any, 
            %                        an empty cell array otherwise.
            %
            % Example:  getSource = currSource.parentSource();

            r = nix.Utils.fetchObj(obj, 'parentSource', @nix.Source);
        end

        function r = referringDataArrays(obj)
            % Returns all nix.DataArrays which referrence the invoking Source.
            %
            % Returns:  ([nix.DataArray]) A cell array of all DataArray entities
            %                             referring to the invoking Source.
            %
            % Example:  getSource = currSource.referringDataArrays();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchObjList(obj, 'referringDataArrays', @nix.DataArray);
        end

        function r = referringTags(obj)
            % Returns all nix.Tags which referrence the invoking Source.
            %
            % Returns:  ([nix.Tag]) A cell array of all Tag entities
            %                       referring to the invoking Source.
            %
            % Example:  getSource = currSource.referringTags();
            %
            % See also nix.Tag.

            r = nix.Utils.fetchObjList(obj, 'referringTags', @nix.Tag);
        end

        function r = referringMultiTags(obj)
            % Returns all nix.MultiTags which referrence the invoking Source.
            %
            % Returns:  ([nix.MultiTag]) A cell array of all MultiTag entities
            %                            referring to the invoking Source.
            %
            % Example:  getSource = currSource.referringMultiTags();
            %
            % See also nix.MultiTag.

            r = nix.Utils.fetchObjList(obj, 'referringMultiTags', @nix.MultiTag);
        end

        function r = filterSources(obj, filter, val)
            % Get a filtered cell array of all direct child Sources 
            % of the invoking Source.
            %
            % filter (nix.Filter):  the nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Source]) A cell array of Sources filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getSources = currSource.filterSources(nix.Filter.type, 'pyramidal');
            %
            % See also nix.Filter.

            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end

        function r = findSources(obj, maxDepth)
            % Get all Sources and their child Sources in the invoking Source recursively.
            %
            % This method traverses the trees of all Sources in the Source and adds all
            % Sources to the resulting cell array, until the maximum depth of the nested
            % Sources has been reached. The traversal is accomplished via breadth first 
            % and adds the Sources accordingly.
            %
            % maxDepth (double):  The maximum depth of traversal to retrieve nested 
            %                     Sources. Should be handled like an index,
            %                     where idx = 0 corresponds to the calling source.
            %
            % Example:  allSources = currSource.findSources(2);
            %           % will add all Sources until including the 2nd layer of Sources.

            r = obj.filterFindSources(maxDepth, nix.Filter.acceptall, '');
        end

        function r = filterFindSources(obj, maxDepth, filter, val)
            % Get all Sources and their child Sources in the invoking Source recursively.
            %
            % This method traverses the trees of all Sources of the invoking Source.
            % The traversal is accomplished via breadth first and can be limited in depth.
            % On each node or Source a nix.Filter is applied. If the filter returns true,
            % the respective Source will be added to the result list.
            %
            % maxDepth (double):    The maximum depth of traversal to retrieve nested 
            %                       Sources. Should be handled like an index,
            %                       where idx = 0 corresponds to the calling source.
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       the filters 'acceptall', 'id', 'ids',
            %                       'name' and 'type'.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Example:  allSources = currSource.filterFindSources(...
            %                               2, nix.Filter.type, 'ephys');
            %
            % See also nix.Filter.

            r = nix.Utils.find(obj, 'findSources', maxDepth, filter, val, @nix.Source);
        end
    end

end
