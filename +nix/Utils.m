% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Utils

    methods(Static)

        function r = createEntityArray(list, objConstructor)
            r = cell(length(list), 1);
            for i = 1:length(list)
                r{i} = objConstructor(list{i});
            end
        end

        function r = fetchObjList(nixMxFunc, handle, objConstructor)
            list = nix_mx(nixMxFunc, handle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % This method calls the nix-mx function specified by 'nixMxFunc', handing 
        % over 'handle' as the main nix entity handle and 'related_handle' as a 
        % second nix entity handle related to the first one.
        % 'objConstructor' requires the Matlab entity constructor of the expected 
        % returned nix Entities.
        function r = fetchObjListByEntity(nixMxFunc, handle, related_handle, objConstructor)
            list = nix_mx(nixMxFunc, handle, related_handle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        function r = fetchObj(nixMxFunc, handle, objConstructor)
            r = {};
            h = nix_mx(nixMxFunc, handle);
            if (h ~= 0)
                r = objConstructor(h);
            end
        end

        function [] = add_entity(obj, add_this, nixEntity, mxMethod)
            if (isa(add_this, nixEntity))
                addID = add_this.id;
            else
                addID = add_this;
            end
            nix_mx(mxMethod, obj.nix_handle, addID);
        end

        function [] = add_entity_array(obj, add_cell_array, nixEntity, mxMethod)
            if (~iscell(add_cell_array))
                error('Expected cell array');
            end
            handle_array = cell(1, length(add_cell_array));
            for i = 1:length(add_cell_array)
                if (~strcmpi(class(add_cell_array{i}), nixEntity))
                    error(sprintf('Element #%s is not a %s.', num2str(i), nixEntity));
                end
                handle_array{i} = add_cell_array{i}.nix_handle;
            end
            nix_mx(mxMethod, obj.nix_handle, handle_array);
        end

        % Function can be used for both nix delete and remove methods.
        % The first actually removes the entity, the latter
        % removes only the reference to the entity.
        function r = delete_entity(obj, del, nixEntity, mxMethod)
            if (isa(del, nixEntity))
                delID = del.id;
            else
                delID = del;
            end
            r = nix_mx(mxMethod, obj.nix_handle, delID);
        end

        function r = open_entity(obj, mxMethod, id_or_name, objConstructor)
            handle = nix_mx(mxMethod, obj.nix_handle, id_or_name);
            r = {};
            if (handle ~= 0)
                r = objConstructor(handle);
            end
        end

        % -----------------------------------------------------------
        % nix.Filter helper functions
        % -----------------------------------------------------------

        function err = valid_filter(filter, val)
            err = '';
            if (~isa(filter, 'nix.Filter'))
                err = 'Valid nix.Filter required';
                return
            end

            % Currently matlab will crash, if anything other than
            % a cell array is handed over to a nix.Filter.ids.
            if (filter == nix.Filter.ids && ~iscell(val))
                err = 'nix.Filter.ids requires a cell array';
                return
            end
        end

        function r = filter(obj, filter, val, mxMethod, objConstructor)
            valid = nix.Utils.valid_filter(filter, val);
            if (~isempty(valid))
                error(valid);
            end

            list = nix_mx(mxMethod, obj.nix_handle, uint8(filter), val);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % -----------------------------------------------------------
        % findXXX helper functions
        % -----------------------------------------------------------

        function r = find(obj, max_depth, filter, val, mxMethod, objConstructor)
            if (~isnumeric(max_depth))
                error('Provide a valid search depth');
            end

            valid = nix.Utils.valid_filter(filter, val);
            if (~isempty(valid))
                error(valid);
            end

            list = nix_mx(mxMethod, obj.nix_handle, max_depth, uint8(filter), val);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % -----------------------------------------------------------
        % c++ to matlab array functions
        % -----------------------------------------------------------

        function r = transpose_array(data)
        % Data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end
    end

end
