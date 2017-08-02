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
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
        end

        % ------------------
        % Sources methods
        % ------------------

        function r = source_count(obj)
            fname = strcat(obj.alias, '::sourceCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = create_source(obj, name, type)
            fname = strcat(obj.alias, '::createSource');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Source);
        end

        function r = has_source(obj, id_or_name)
            fname = strcat(obj.alias, '::hasSource');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = delete_source(obj, del)
            fname = strcat(obj.alias, '::deleteSource');
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

        function r = parent_source(obj)
            fname = strcat(obj.alias, '::parentSource');
            r = nix.Utils.fetchObj(fname, obj.nix_handle, @nix.Source);
        end

        function r = referring_data_arrays(obj)
            fname = strcat(obj.alias, '::referringDataArrays');
            r = nix.Utils.fetchObjList(fname, obj.nix_handle, @nix.DataArray);
        end

        function r = referring_tags(obj)
            fname = strcat(obj.alias, '::referringTags');
            r = nix.Utils.fetchObjList(fname, obj.nix_handle, @nix.Tag);
        end

        function r = referring_multi_tags(obj)
            fname = strcat(obj.alias, '::referringMultiTags');
            r = nix.Utils.fetchObjList(fname, obj.nix_handle, @nix.MultiTag);
        end

        function r = filter_sources(obj, filter, val)
            fname = strcat(obj.alias, '::sourcesFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Source);
        end

        % maxdepth is an index where idx = 0 corresponds to the calling source
        function r = find_sources(obj, max_depth)
            r = obj.find_filtered_sources(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index where idx = 0 corresponds to the calling source
        function r = find_filtered_sources(obj, max_depth, filter, val)
            fname = strcat(obj.alias, '::findSources');
            r = nix.Utils.find(obj, max_depth, filter, val, fname, @nix.Source);
        end
    end

end
