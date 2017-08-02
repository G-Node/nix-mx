% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef MultiTag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % MultiTag nix MultiTag object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'MultiTag'
    end

    methods
        function obj = MultiTag(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
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
            r = nix.Utils.open_entity(obj, 'openReferences', id_or_name, @nix.DataArray);
        end

        function r = open_reference_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieve_data(obj, pos_idx, id_or_name)
            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nix_handle, pos_idx, id_or_name);
            r = nix.Utils.transpose_array(data);
        end

        function r = retrieve_data_idx(obj, pos_idx, ref_idx)
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, pos_idx, ref_idx);
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
            addId = nix.Utils.parseEntityId(add_this, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nix_handle, addId, link_type);
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

        function r = retrieve_feature_data(obj, pos_idx, id_or_name)
            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nix_handle, pos_idx, id_or_name);
            r = nix.Utils.transpose_array(data);
        end

        function r = retrieve_feature_data_idx(obj, pos_idx, feat_idx)
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, pos_idx, feat_idx);
            r = nix.Utils.transpose_array(data);
        end

        function r = feature_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filter_features(obj, filter, val)
            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end

        % ------------------
        % Positions methods
        % ------------------

        function r = has_positions(obj)
            fname = strcat(obj.alias, '::hasPositions');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = open_positions(obj)
            r = nix.Utils.fetchObj(obj, 'openPositions', @nix.DataArray);
        end

        function [] = add_positions(obj, add_this)
            nix.Utils.add_entity(obj, 'addPositions', add_this, 'nix.DataArray');
        end

        % ------------------
        % Extents methods
        % ------------------

        function r = open_extents(obj)
            r = nix.Utils.fetchObj(obj, 'openExtents', @nix.DataArray);
        end

        function [] = set_extents(obj, add_this)
            if (isempty(add_this))
                fname = strcat(obj.alias, '::setNoneExtents');
                nix_mx(fname, obj.nix_handle, 0);
            else
                nix.Utils.add_entity(obj, 'setExtents', add_this, 'nix.DataArray');
            end
        end
    end

end
