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

        function r = source_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sourceCount');
        end

        % has_source supports only check by id, not by name
        function r = has_source(obj, id_or_entity)
            has = nix.Utils.parseEntityId(id_or_entity, 'nix.Source');
            fname = strcat(obj.alias, '::hasSource');
            r = nix_mx(fname, obj.nix_handle, has);
        end

        function [] = add_source(obj, add_this)
            nix.Utils.add_entity(obj, 'addSource', add_this, 'nix.Source');
        end

        function [] = add_sources(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, 'addSources', add_cell_array, 'nix.Source');
        end

        function r = remove_source(obj, del)
            r = nix.Utils.delete_entity(obj, 'removeSource', del, 'nix.Source');
        end

        function r = open_source(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openSource', id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openSourceIdx', idx, @nix.Source);
        end

        function r = filter_sources(obj, filter, val)
            r = nix.Utils.filter(obj, 'sourcesFiltered', filter, val, @nix.Source);
        end
    end

end
