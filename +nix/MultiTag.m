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
            obj.referencesCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.DataArray', 'MultiTag::addReference', obj.referencesCache);
        end;

        function delCheck = remove_reference(obj, del)
            [delCheck, obj.referencesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.DataArray', 'MultiTag::removeReference', obj.referencesCache);
        end;

        function retObj = open_reference(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openReferences', id_or_name, @nix.DataArray);
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
        
        % ------------------
        % Features methods
        % ------------------
        
        function retObj = open_feature(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'MultiTag::openFeature', id_or_name, @nix.Feature);
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

    end;
end