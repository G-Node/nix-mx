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
            nix.Utils.add_entity(obj, add_this, 'nix.DataArray', 'Tag::addReference');
        end

        function [] = add_references(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.DataArray', strcat(obj.alias, '::addReferences'));
        end

        function r = has_reference(obj, id_or_name)
            r = nix_mx('Tag::hasReference', obj.nix_handle, id_or_name);
        end

        function r = remove_reference(obj, del)
            r = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'Tag::removeReference');
        end

        function r = open_reference(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'Tag::openReferenceDataArray', id_or_name, @nix.DataArray);
        end

        function r = open_reference_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'Tag::openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieve_data(obj, id_or_name)
            data = nix_mx('Tag::retrieveData', obj.nix_handle, id_or_name);

            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = retrieve_data_idx(obj, idx)
            data = nix_mx('Tag::retrieveDataIdx', obj.nix_handle, idx);
            
            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = reference_count(obj)
            r = nix_mx('Tag::referenceCount', obj.nix_handle);
        end

        function r = filter_references(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'Tag::referencesFiltered', @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = add_feature(obj, add_this, link_type)
            if(strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end
            r = nix.Feature(nix_mx('Tag::createFeature', ...
                obj.nix_handle, addID, link_type));
        end

        function r = has_feature(obj, id_or_name)
            r = nix_mx('Tag::hasFeature', obj.nix_handle, id_or_name);
        end

        function r = remove_feature(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Feature', 'Tag::deleteFeature');
        end

        function r = open_feature(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'Tag::openFeature', id_or_name, @nix.Feature);
        end

        function r = open_feature_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'Tag::openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieve_feature_data(obj, id_or_name)
            data = nix_mx('Tag::featureRetrieveData', obj.nix_handle, id_or_name);

            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = retrieve_feature_data_idx(obj, idx)
            data = nix_mx('Tag::featureRetrieveDataIdx', obj.nix_handle, idx);

            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = feature_count(obj)
            r = nix_mx('Tag::featureCount', obj.nix_handle);
        end

        function r = filter_features(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'Tag::featuresFiltered', @nix.Feature);
        end
    end

end
