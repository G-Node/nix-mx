classdef Tag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %Tag nix Tag object

    properties (Access = protected)
        % namespace reference for nix-mx functions
        alias = 'Tag'
    end
    
    methods
        function obj = Tag(h)
            obj@nix.NamedEntity(h); % this should be first
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();
            
            % assign dynamic properties
            obj.add_dyn_attr('position', 'rw');
            obj.add_dyn_attr('extent', 'rw');
            obj.add_dyn_attr('units', 'rw');
            
            % assign relations
            obj.add_dyn_relation('references', @nix.DataArray);
            obj.add_dyn_relation('features', @nix.Feature);
        end;

        % ------------------
        % References methods
        % ------------------
        
        function [] = add_reference(obj, add_this)
            obj.referencesCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.DataArray', 'Tag::addReference', obj.referencesCache);
        end;

        function delCheck = remove_reference(obj, del)
            [delCheck, obj.referencesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'Tag::removeReference', obj.referencesCache);
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

        % ------------------
        % Features methods
        % ------------------
        
        function retObj = add_feature(obj, add_this, link_type)
            if(strcmp(class(add_this), 'nix.DataArray'))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            retObj = nix.Feature(nix_mx('Tag::createFeature', obj.nix_handle, addID, link_type));
            obj.featuresCache.lastUpdate = 0;
        end;

        function delCheck = remove_feature(obj, del)
            [delCheck, obj.featuresCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Feature', 'Tag::deleteFeature', obj.featuresCache);
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
        end;

    end;
end