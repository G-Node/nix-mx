% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef MultiTag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %MultiTag nix MultiTag object
    
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
        end;
        
        % ------------------
        % References methods
        % ------------------

        function [] = add_reference(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.DataArray', 'MultiTag::addReference');
        end;

        function [] = add_references(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.DataArray', strcat(obj.alias, '::addReferences'));
        end

        function hasRef = has_reference(obj, id_or_name)
            hasRef = nix_mx('MultiTag::hasReference', ...
                obj.nix_handle, id_or_name);
        end;
        
        function delCheck = remove_reference(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'MultiTag::removeReference');
        end;

        function retObj = open_reference(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openReferences', id_or_name, @nix.DataArray);
        end;

        function retObj = open_reference_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openReferenceIdx', idx, @nix.DataArray);
        end;

        function data = retrieve_data(obj, pos_index, ref_index)
            % convert Matlab-like to C-like index
            assert(pos_index > 0, 'Position index must be positive');
            assert(ref_index > 0, 'Reference index must be positive');
            tmp = nix_mx('MultiTag::retrieveData', obj.nix_handle, ...
                pos_index - 1, ref_index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;

        function c = reference_count(obj)
            c = nix_mx('MultiTag::referenceCount', obj.nix_handle);
        end

        function filtered = filter_references(obj, filter, val)
            filtered = nix.Utils.filter(obj, filter, val, ...
                'MultiTag::referencesFiltered', @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function retObj = add_feature(obj, add_this, link_type)
            if(strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            retObj = nix.Feature(nix_mx('MultiTag::createFeature', ...
                obj.nix_handle, addID, link_type));
        end;

        function hasFeature = has_feature(obj, id_or_name)
            hasFeature = nix_mx('MultiTag::hasFeature', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = remove_feature(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Feature', 'MultiTag::deleteFeature');
        end;

        function retObj = open_feature(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openFeature', id_or_name, @nix.Feature);
        end;

        function retObj = open_feature_idx(obj, idx)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openFeatureIdx', idx, @nix.Feature);
        end;

        function data = retrieve_feature_data(obj, pos_index, fea_index)
            % convert Matlab-like to C-like index
            assert(pos_index > 0, 'Position index must be positive');
            assert(fea_index > 0, 'Feature index must be positive');
            tmp = nix_mx('MultiTag::featureRetrieveData', obj.nix_handle, ...
                pos_index - 1, fea_index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        function c = feature_count(obj)
            c = nix_mx('MultiTag::featureCount', obj.nix_handle);
        end

        % ------------------
        % Positions methods
        % ------------------

        function hasPositions = has_positions(obj)
            hasPositions = nix_mx('MultiTag::hasPositions', obj.nix_handle);
        end;
        
        function retObj = open_positions(obj)
            handle = nix_mx('MultiTag::openPositions', obj.nix_handle);
            retObj = {};
            if handle ~= 0
                retObj = nix.DataArray(handle);
            end;
        end;

        function [] = add_positions(obj, add_this)
            if(strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            nix_mx('MultiTag::addPositions', obj.nix_handle, addID);
        end;

        % ------------------
        % Extents methods
        % ------------------

        function retObj = open_extents(obj)
            handle = nix_mx('MultiTag::openExtents', obj.nix_handle);
            retObj = {};
            if handle ~= 0
                retObj = nix.DataArray(handle);
            end;
        end;

        function [] = set_extents(obj, add_this)
            if(isempty(add_this))
                nix_mx('MultiTag::setNoneExtents', obj.nix_handle, 0);
            else
                if(strcmp(class(add_this), 'nix.DataArray'))
                    addID = add_this.id;
                else
                    addID = add_this;
                end;
                nix_mx('MultiTag::setExtents', obj.nix_handle, addID);
            end;
        end;

    end;
end
