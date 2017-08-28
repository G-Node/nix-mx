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
            fname = strcat(obj.alias, '::addReference');
            nix.Utils.add_entity(obj, add_this, 'nix.DataArray', fname);
        end

        function [] = add_references(obj, add_cell_array)
            fname = strcat(obj.alias, '::addReferences');
            nix.Utils.add_entity_array(obj, add_cell_array, 'nix.DataArray', fname);
        end

        function r = has_reference(obj, id_or_name)
            fname = strcat(obj.alias, '::hasReference');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = remove_reference(obj, del)
            fname = strcat(obj.alias, '::removeReference');
            r = nix.Utils.delete_entity(obj, del, 'nix.DataArray', fname);
        end

        function r = open_reference(obj, id_or_name)
            fname = strcat(obj.alias, '::openReferenceDataArray');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.DataArray);
        end

        function r = open_reference_idx(obj, idx)
            fname = strcat(obj.alias, '::openReferenceIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.DataArray);
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
            fname = strcat(obj.alias, '::referenceCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_references(obj, filter, val)
            fname = strcat(obj.alias, '::referencesFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = add_feature(obj, add_this, link_type)
            if (strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end

            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nix_handle, addID, link_type);

            r = {};
            if (h ~= 0)
                r = nix.Feature(h);
            end
        end

        function r = has_feature(obj, id_or_name)
            fname = strcat(obj.alias, '::hasFeature');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = remove_feature(obj, del)
            fname = strcat(obj.alias, '::deleteFeature');
            r = nix.Utils.delete_entity(obj, del, 'nix.Feature', fname);
        end

        function r = open_feature(obj, id_or_name)
            fname = strcat(obj.alias, '::openFeature');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Feature);
        end

        function r = open_feature_idx(obj, idx)
            fname = strcat(obj.alias, '::openFeatureIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Feature);
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
            fname = strcat(obj.alias, '::featureCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_features(obj, filter, val)
            fname = strcat(obj.alias, '::featuresFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Feature);
        end
    end

end
