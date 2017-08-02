% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Utils

    methods(Static)

        function r = parseEntityId(id_or_entity, nixEntity)
            if (isa(id_or_entity, nixEntity))
                r = id_or_entity.id;
            elseif (isa(id_or_entity, 'char'))
                r = id_or_entity;
            else
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = sprintf('Expected an id, name or %s entity', nixEntity);
                error(err);
            end
        end

        function r = createEntity(handle, objConstructor)
            r = {};
            if (handle ~= 0)
                r = objConstructor(handle);
            end
        end

        function r = createEntityArray(list, objConstructor)
            r = cell(length(list), 1);
            for i = 1:length(list)
                r{i} = nix.Utils.createEntity(list{i}, objConstructor);
            end
        end

        function r = fetchEntityCount(obj, mxMethodName)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            r = nix_mx(mxMethod, obj.nix_handle);
        end

        function r = fetchObjList(obj, mxMethodName, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % This method calls the nix-mx function specified by 'nixMxFunc', handing 
        % over 'handle' as the main nix entity handle and 'related_handle' as a 
        % second nix entity handle related to the first one.
        % 'objConstructor' requires the Matlab entity constructor of the expected 
        % returned nix Entities.
        function r = fetchObjListByEntity(obj, mxMethodName, related_handle, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle, related_handle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        function r = fetchObj(obj, mxMethodName, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            h = nix_mx(mxMethod, obj.nix_handle);
            r = nix.Utils.createEntity(h, objConstructor);
        end

        function [] = add_entity(obj, mxMethodName, idNameEntity, nixEntity)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            id = nix.Utils.parseEntityId(idNameEntity, nixEntity);
            nix_mx(mxMethod, obj.nix_handle, id);
        end

        function [] = add_entity_array(obj, mxMethodName, add_cell_array, nixEntity)
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
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            nix_mx(mxMethod, obj.nix_handle, handle_array);
        end

        % Function can be used for both nix delete and remove methods.
        % The first actually removes the entity, the latter
        % removes only the reference to the entity.
        function r = delete_entity(obj, mxMethodName, idNameEntity, nixEntity)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            id = nix.Utils.parseEntityId(idNameEntity, nixEntity);
            r = nix_mx(mxMethod, obj.nix_handle, id);
        end

        function r = open_entity(obj, mxMethodName, id_or_name, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            h = nix_mx(mxMethod, obj.nix_handle, id_or_name);
            r = nix.Utils.createEntity(h, objConstructor);
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

        function r = filter(obj, mxMethodName, filter, val, objConstructor)
            valid = nix.Utils.valid_filter(filter, val);
            if (~isempty(valid))
                error(valid);
            end

            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle, uint8(filter), val);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % -----------------------------------------------------------
        % findXXX helper functions
        % -----------------------------------------------------------

        function r = find(obj, mxMethodName, max_depth, filter, val, objConstructor)
            if (~isnumeric(max_depth))
                error('Provide a valid search depth');
            end

            valid = nix.Utils.valid_filter(filter, val);
            if (~isempty(valid))
                error(valid);
            end

            mxMethod = strcat(obj.alias, '::', mxMethodName);
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
