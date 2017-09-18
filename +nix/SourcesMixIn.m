% Mixin Class for entities that can be associated with a nix.Source entity.
%
% In order to describe the provenance of data some entities of the NIX data model
% can be associated with nix.Source entities. This class serves as a base class
% for those.
%
% See also nix.Source, nix.Group, nix.DataArray, nix.Tag, nix.MultiTag.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SourcesMixIn < handle

    properties (Abstract, Hidden)
        alias
    end

    methods
        function obj = SourcesMixIn()
            nix.Dynamic.addGetChildEntities(obj, 'sources', @nix.Source);
        end

        function r = sourceCount(obj)
            % Get the number of direct child nix.Sources.
            %
            % Returns:  (uint) The number of child Sources.
            %
            % Example:  sc = currEntity.sourceCount();
            %
            % See also nix.Source.

            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        function r = hasSource(obj, idEntity)
            % Check if a nix.Source exists as a direct child of the invoking Entity.
            %
            % idEntity (char/nix.Source):  ID of the Source or the Source itself.
            %
            % Returns:  (logical) True if the Source exists, false otherwise.
            %
            % Example:  check = currEntity.hasSource('some-source-id');
            %           check = currFile.blocks{1}.tags{1}.hasSource(newSourceEntity);
            %
            % See also nix.Source.

            has = nix.Utils.parseEntityId(idEntity, 'nix.Source');
            r = nix.Utils.fetchHasEntity(obj, 'hasSource', has);
        end

        function [] = addSource(obj, idEntity)
            % Add an existing nix.Source to the referenced list of the invoking Entity.
            %
            % idEntity (char/nix.Source):  The ID of an existing Source, 
            %                              or a nix.Source entity.
            %
            % Example:  currEntity.addSource('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currFile.blocks{1}.groups{1}.addSource(newSourceEntity);
            %
            % See also nix.Source.

            nix.Utils.addEntity(obj, 'addSource', idEntity, 'nix.Source');
        end

        function [] = addSources(obj, entityArray)
            % Set the list of referenced Sources for the invoking Entity.
            %
            % Previously referenced Sources that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.Source]):  A cell array of nix.Sources.
            %
            % Example:  currEntity.addSources({source1, source2});
            %
            % See also nix.Source.

            nix.Utils.addEntityArray(obj, 'addSources', entityArray, 'nix.Source');
        end

        function r = removeSource(obj, idEntity)
            % Removes the reference to a nix.Source from the invoking Entity.
            %
            % This method removes the association between the Source and the
            % Entity, the Source itself will not be removed from the file.
            %
            % idEntity (char/nix.Source):  id of the Source to be removed
            %                              or the Source itself.
            %
            % Returns:  (logical) True if the reference to the Source 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currEntity.removeSource('23bb8a99-1812-4bc6-a52c');
            %           check = currFile.blocks{1}.groups{1}.removeSource(newSourceEntity);
            %
            % See also nix.Source.

            r = nix.Utils.deleteEntity(obj, 'removeSource', idEntity, 'nix.Source');
        end

        function r = openSource(obj, idName)
            % Retrieves an existing Source from the invoking Entity.
            %
            % idName (char):  Name or ID of the Source.
            %
            % Returns:  (nix.Source) The nix.Source or an empty cell, 
            %                        if the Source was not found.
            %
            % Example:  getSource = currEntity.openSource('23bb8a99-1812-4bc6-a52c');
            %           getSource = currFile.blocks{1}.tags{1}.openSource('subTrial2');
            %
            % See also nix.Source.

            r = nix.Utils.openEntity(obj, 'openSource', idName, @nix.Source);
        end

        function r = openSourceIdx(obj, index)
            % Retrieves an existing nix.Source from the invoking Entity, 
            % accessed by index.
            %
            % index (double):  The index of the Source to read.
            %
            % Returns:  (nix.Source) The Source at the given index.
            %
            % Example:  getSource = currEntity.openSourceIdx(1);
            %
            % See also nix.Source.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = filterSources(obj, filter, val)
            % Get a filtered cell array of all Source entities 
            % referenced by the invoking Entity.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Source]) A cell array of Sources filtered according
            %                          to the applied nix.Filter.
            %
            % Example:  getSources = currEntity.filterSources(...
            %                                       nix.Filter.type, 'ephys_data');
            %
            % See also nix.Source, nix.Filter.

            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end
    end

end
