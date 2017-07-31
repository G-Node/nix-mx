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
            nix.Utils.add_entity(obj, add_this, ...
                'nix.DataArray', 'MultiTag::addReference');
        end

        function [] = add_references(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.DataArray', strcat(obj.alias, '::addReferences'));
        end

        function r = has_reference(obj, id_or_name)
            r = nix_mx('MultiTag::hasReference', obj.nix_handle, id_or_name);
        end

        function r = remove_reference(obj, del)
            r = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'MultiTag::removeReference');
        end

        function r = open_reference(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'MultiTag::openReferences', id_or_name, @nix.DataArray);
        end

        function r = open_reference_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'MultiTag::openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieve_data(obj, pos_idx, id_or_name)
            data = nix_mx('MultiTag::retrieveData', obj.nix_handle, pos_idx, id_or_name);
            
            % data must agree with file & dimensions see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = retrieve_data_idx(obj, pos_idx, ref_idx)
            data = nix_mx('MultiTag::retrieveDataIdx', obj.nix_handle, pos_idx, ref_idx);
            
            % data must agree with file & dimensions see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = reference_count(obj)
            r = nix_mx('MultiTag::referenceCount', obj.nix_handle);
        end

        function r = filter_references(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'MultiTag::referencesFiltered', @nix.DataArray);
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
            r = nix.Feature(nix_mx('MultiTag::createFeature', ...
                obj.nix_handle, addID, link_type));
        end

        function r = has_feature(obj, id_or_name)
            r = nix_mx('MultiTag::hasFeature', obj.nix_handle, id_or_name);
        end

        function r = remove_feature(obj, del)
            r = nix.Utils.delete_entity(obj, del, ...
                'nix.Feature', 'MultiTag::deleteFeature');
        end

        function r = open_feature(obj, id_or_name)
            r = nix.Utils.open_entity(obj, ...
                'MultiTag::openFeature', id_or_name, @nix.Feature);
        end

        function r = open_feature_idx(obj, idx)
            r = nix.Utils.open_entity(obj, ...
                'MultiTag::openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieve_feature_data(obj, pos_idx, id_or_name)
            data = nix_mx('MultiTag::featureRetrieveData', ...
                            obj.nix_handle, pos_idx, id_or_name);

            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = retrieve_feature_data_idx(obj, pos_idx, feat_idx)
            data = nix_mx('MultiTag::featureRetrieveDataIdx', ...
                            obj.nix_handle, pos_idx, feat_idx);
            
            % data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = feature_count(obj)
            r = nix_mx('MultiTag::featureCount', obj.nix_handle);
        end

        function r = filter_features(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, ...
                'MultiTag::featuresFiltered', @nix.Feature);
        end

        % ------------------
        % Positions methods
        % ------------------

        function r = has_positions(obj)
            r = nix_mx('MultiTag::hasPositions', obj.nix_handle);
        end

        function r = open_positions(obj)
            h = nix_mx('MultiTag::openPositions', obj.nix_handle);
            r = {};
            if h ~= 0
                r = nix.DataArray(h);
            end
        end

        function [] = add_positions(obj, add_this)
            if(strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end

            nix_mx('MultiTag::addPositions', obj.nix_handle, addID)
        end

        % ------------------
        % Extents methods
        % ------------------

        function r = open_extents(obj)
            h = nix_mx('MultiTag::openExtents', obj.nix_handle);
            r = {};
            if h ~= 0
                r = nix.DataArray(h);
            end
        end

        function [] = set_extents(obj, add_this)
            if(isempty(add_this))
                nix_mx('MultiTag::setNoneExtents', obj.nix_handle, 0);
            else
                if(strcmp(class(add_this), 'nix.DataArray'))
                    addID = add_this.id;
                else
                    addID = add_this;
                end
                nix_mx('MultiTag::setExtents', obj.nix_handle, addID);
            end
        end
    end

end
