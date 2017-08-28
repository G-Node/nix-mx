% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SourcesMixIn < handle
    % SourcesMixIn
    % mixin class for nix entities that can be related with sources

    properties (Abstract, Hidden)
        alias
    end

    methods
        function obj = SourcesMixIn()
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
        end

        function r = sourceCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        % hasSource supports only check by id, not by name
        function r = hasSource(obj, idEntity)
            has = nix.Utils.parseEntityId(idEntity, 'nix.Source');
            r = nix.Utils.fetchHasEntity(obj, 'hasSource', has);
        end

        function [] = addSource(obj, entity)
            nix.Utils.addEntity(obj, 'addSource', entity, 'nix.Source');
        end

        function [] = addSources(obj, entityArray)
            nix.Utils.addEntityArray(obj, 'addSources', entityArray, 'nix.Source');
        end

        function r = removeSource(obj, del)
            r = nix.Utils.deleteEntity(obj, 'removeSource', del, 'nix.Source');
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
    end

end
