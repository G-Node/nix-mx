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
            fname = strcat(obj.alias, '::sourceCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        % has_source supports only check by id, not by name
        function r = has_source(obj, id_or_entity)
            has = id_or_entity;
            if (strcmp(class(has), 'nix.Source'))
            	has = id_or_entity.id;
            end

            fname = strcat(obj.alias, '::hasSource');
            r = nix_mx(fname, obj.nix_handle, has);
        end

        function [] = add_source(obj, add_this)
            fname = strcat(obj.alias, '::addSource');
            nix.Utils.add_entity(obj, add_this, 'nix.Source', fname);
        end

        function [] = add_sources(obj, add_cell_array)
            fname = strcat(obj.alias, '::addSources');
            nix.Utils.add_entity_array(obj, add_cell_array, 'nix.Source', fname);
        end

        function r = remove_source(obj, del)
            fname = strcat(obj.alias, '::removeSource');
            r = nix.Utils.delete_entity(obj, del, 'nix.Source', fname);
        end

        function r = open_source(obj, id_or_name)
            fname = strcat(obj.alias, '::openSource');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            fname = strcat(obj.alias, '::openSourceIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Source);
        end

        function r = filter_sources(obj, filter, val)
            fname = strcat(obj.alias, '::sourcesFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Source);
        end
    end

end
