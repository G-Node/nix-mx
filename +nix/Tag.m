% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Tag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %Tag nix Tag object

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
        end;

        % ------------------
        % References methods
        % ------------------
        
        function [] = add_reference(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.DataArray', 'Tag::addReference');
        end;

        function [] = add_references(obj, add_cell_array)
            nix.Utils.add_entity_array(obj, add_cell_array, ...
                'nix.DataArray', strcat(obj.alias, '::addReferences'));
        end

        function hasRef = has_reference(obj, id_or_name)
            hasRef = nix_mx('Tag::hasReference', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = remove_reference(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'Tag::removeReference');
        end;

        function retObj = open_reference(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Tag::openReferenceDataArray', id_or_name, @nix.DataArray);
        end;

        function data = retrieve_data(obj, index)
            % convert Matlab-like to C-like index
            assert(index > 0, 'Subscript indices must be positive');
            tmp = nix_mx('Tag::retrieveData', obj.nix_handle, index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end;

        function c = reference_count(obj)
            c = nix_mx('Tag::referenceCount', obj.nix_handle);
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
            retObj = nix.Feature(nix_mx('Tag::createFeature', ...
                obj.nix_handle, addID, link_type));
        end;

        function hasFeature = has_feature(obj, id_or_name)
            hasFeature = nix_mx('Tag::hasFeature', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = remove_feature(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Feature', 'Tag::deleteFeature');
        end;

        function retObj = open_feature(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Tag::openFeature', id_or_name, @nix.Feature);
        end;
        
        function data = retrieve_feature_data(obj, index)
            % convert Matlab-like to C-like index
            assert(index > 0, 'Subscript indices must be positive');
            tmp = nix_mx('Tag::featureRetrieveData', obj.nix_handle, index - 1);
            
            % data must agree with file & dimensions
            % see mkarray.cc(42)
            data = permute(tmp, length(size(tmp)):-1:1);
        end

        function c = feature_count(obj)
            c = nix_mx('Tag::featureCount', obj.nix_handle);
        end
    end;
end
