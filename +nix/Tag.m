% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Tag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % Tag nix Tag object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Tag'
    end

    methods
        function obj = Tag(h)
            obj@nix.NamedEntity(h); % this should be first
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'position', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'extent', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'units', 'rw');

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'references', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'features', @nix.Feature);
        end

        % ------------------
        % References methods
        % ------------------

        function [] = add_reference(obj, add_this)
            nix.Utils.add_entity(obj, 'addReference', add_this, 'nix.DataArray');
        end

        function [] = add_references(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, 'addReferences', add_cell_array, 'nix.DataArray');
        end

        function r = has_reference(obj, id_or_name)
            fname = strcat(obj.alias, '::hasReference');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = remove_reference(obj, del)
            r = nix.Utils.delete_entity(obj, 'removeReference', del, 'nix.DataArray');
        end

        function r = open_reference(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openReferenceDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_reference_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieve_data(obj, id_or_name)
            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nix_handle, id_or_name);
            r = nix.Utils.transpose_array(data);
        end

        function r = retrieve_data_idx(obj, idx)
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, idx);
            r = nix.Utils.transpose_array(data);
        end

        function r = reference_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'referenceCount');
        end

        function r = filter_references(obj, filter, val)
            r = nix.Utils.filter(obj, 'referencesFiltered', filter, val, @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = add_feature(obj, add_this, link_type)
            id = nix.Utils.parseEntityId(add_this, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nix_handle, id, link_type);
            r = nix.Utils.createEntity(h, @nix.Feature);
        end

        function r = has_feature(obj, id_or_name)
            fname = strcat(obj.alias, '::hasFeature');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = remove_feature(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteFeature', del, 'nix.Feature');
        end

        function r = open_feature(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openFeature', id_or_name, @nix.Feature);
        end

        function r = open_feature_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieve_feature_data(obj, id_or_name)
            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nix_handle, id_or_name);
            r = nix.Utils.transpose_array(data);
        end

        function r = retrieve_feature_data_idx(obj, idx)
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, idx);
            r = nix.Utils.transpose_array(data);
        end

        function r = feature_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filter_features(obj, filter, val)
            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end
    end

end
