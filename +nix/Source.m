% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Source < nix.NamedEntity & nix.MetadataMixIn
    % Source nix Source object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Source'
    end

    methods
        function obj = Source(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();

            % assign relations
            nix.Dynamic.addGetChildEntities(obj, 'sources', @nix.Source);
        end

        % ------------------
        % Sources methods
        % ------------------

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

        function r = parentSource(obj)
            r = nix.Utils.fetchObj(obj, 'parentSource', @nix.Source);
        end

        function r = referringDataArrays(obj)
            r = nix.Utils.fetchObjList(obj, 'referringDataArrays', @nix.DataArray);
        end

        function r = referringTags(obj)
            r = nix.Utils.fetchObjList(obj, 'referringTags', @nix.Tag);
        end

        function r = referringMultiTags(obj)
            r = nix.Utils.fetchObjList(obj, 'referringMultiTags', @nix.MultiTag);
        end

        function r = filterSources(obj, filter, val)
            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end

        % maxdepth is an index where idx = 0 corresponds to the calling source
        function r = findSources(obj, maxDepth)
            r = obj.filterFindSources(maxDepth, nix.Filter.acceptall, '');
        end

        % maxdepth is an index where idx = 0 corresponds to the calling source
        function r = filterFindSources(obj, maxDepth, filter, val)
            r = nix.Utils.find(obj, 'findSources', maxDepth, filter, val, @nix.Source);
        end
    end

end
