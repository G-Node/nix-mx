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
            r = nix_mx('Source::sourceCount', obj.nix_handle);
        end

        function r = create_source(obj, name, type)
            r = nix.Source(nix_mx('Source::createSource', obj.nix_handle, name, type));
        end

        function r = has_source(obj, id_or_name)
            r = nix_mx('Source::hasSource', obj.nix_handle, id_or_name);
        end

        function r = delete_source(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Source', 'Source::deleteSource');
        end

        function r = open_source(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Source::openSource', id_or_name, @nix.Source);
        end

        function r = open_source_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Source::openSourceIdx', idx, @nix.Source);
        end

        function r = parent_source(obj)
            r = nix.Utils.fetchObj('Source::parentSource', obj.nix_handle, @nix.Source);
        end

        function r = referring_data_arrays(obj)
            r = nix.Utils.fetchObjList('Source::referringDataArrays', ...
                obj.nix_handle, @nix.DataArray);
        end

        function r = referring_tags(obj)
            r = nix.Utils.fetchObjList('Source::referringTags', ...
                obj.nix_handle, @nix.Tag);
        end

        function r = referring_multi_tags(obj)
            r = nix.Utils.fetchObjList('Source::referringMultiTags', ...
                obj.nix_handle, @nix.MultiTag);
        end

        function r = filter_sources(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Source::sourcesFiltered', @nix.Source);
        end

        % maxdepth is an index where idx = 0 corresponds to the calling
        % source
        function r = find_sources(obj, max_depth)
            r = obj.find_filtered_sources(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index where idx = 0 corresponds to the calling
        % source
        function r = find_filtered_sources(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, ...
                max_depth, filter, val, 'Source::findSources', @nix.Source);
        end
    end

end
