% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Group < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %Group nix Group object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Group'
    end

    methods
        function obj = Group(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
        end;

        % -----------------
        % DataArray methods
        % -----------------

        function hasDataArray = has_data_array(obj, id_or_name)
            hasDataArray = nix_mx('Group::hasDataArray', ...
                obj.nix_handle, id_or_name);
        end;

        function retObj = get_data_array(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getDataArray', id_or_name, @nix.DataArray);
        end;

        function [] = add_data_array(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.DataArray', 'Group::addDataArray');
        end;

        function delCheck = remove_data_array(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.DataArray', 'Group::removeDataArray');
        end;

        % -----------------
        % Tags methods
        % -----------------

        function [] = add_tag(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.Tag', 'Group::addTag');
        end;

        function hasTag = has_tag(obj, id_or_name)
            hasTag = nix_mx('Group::hasTag', obj.nix_handle, id_or_name);
        end;

        function retObj = get_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getTag', id_or_name, @nix.Tag);
        end;

        function delCheck = remove_tag(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Tag', 'Group::removeTag');
        end;

        % -----------------
        % MultiTag methods
        % -----------------
        
        function [] = add_multi_tag(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.MultiTag', 'Group::addMultiTag');
        end;

        function hasMTag = has_multi_tag(obj, id_or_name)
            hasMTag = nix_mx('Group::hasMultiTag', ...
                obj.nix_handle, id_or_name);
        end;

        function retObj = get_multi_tag(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Group::getMultiTag', id_or_name, @nix.MultiTag);
        end;

        function delCheck = remove_multi_tag(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.MultiTag', 'Group::removeMultiTag');
        end;
    end;

end
