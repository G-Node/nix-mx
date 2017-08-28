% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Utils

    methods(Static)

        function r = parseEntityId(idEntity, nixEntity)
            if (isa(idEntity, nixEntity))
                r = idEntity.id;
            elseif (isa(idEntity, 'char'))
                r = idEntity;
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

        function r = fetchHasEntity(obj, mxMethodName, identifier)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            r = nix_mx(mxMethod, obj.nix_handle, identifier);
        end

        function r = fetchObjList(obj, mxMethodName, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % This method calls the nix-mx function specified by 'nixMxFunc', handing 
        % over 'handle' as the main nix entity handle and 'relatedHandle' as a 
        % second nix entity handle related to the first one.
        % 'objConstructor' requires the Matlab entity constructor of the expected 
        % returned nix Entities.
        function r = fetchObjListByEntity(obj, mxMethodName, relatedHandle, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle, relatedHandle);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        function r = fetchObj(obj, mxMethodName, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            h = nix_mx(mxMethod, obj.nix_handle);
            r = nix.Utils.createEntity(h, objConstructor);
        end

        function [] = addEntity(obj, mxMethodName, idNameEntity, nixEntity)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            id = nix.Utils.parseEntityId(idNameEntity, nixEntity);
            nix_mx(mxMethod, obj.nix_handle, id);
        end

        function [] = addEntityArray(obj, mxMethodName, entityArray, nixEntity)
            if (~iscell(entityArray))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Expected cell array';
                error(err);
            end

            handleArray = cell(1, length(entityArray));
            for i = 1:length(entityArray)
                if (~strcmpi(class(entityArray{i}), nixEntity))
                    err.identifier = 'NIXMX:InvalidArgument';
                    err.message = sprintf('Element #%s is not a %s.', num2str(i), nixEntity);
                    error(err);
                end
                handleArray{i} = entityArray{i}.nix_handle;
            end

            mxMethod = strcat(obj.alias, '::', mxMethodName);
            nix_mx(mxMethod, obj.nix_handle, handleArray);
        end

        % Function can be used for both nix delete and remove methods.
        % The first actually removes the entity, the latter
        % removes only the reference to the entity.
        function r = deleteEntity(obj, mxMethodName, idNameEntity, nixEntity)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            id = nix.Utils.parseEntityId(idNameEntity, nixEntity);
            r = nix_mx(mxMethod, obj.nix_handle, id);
        end

        function r = openEntity(obj, mxMethodName, idName, objConstructor)
            mxMethod = strcat(obj.alias, '::', mxMethodName);
            h = nix_mx(mxMethod, obj.nix_handle, idName);
            r = nix.Utils.createEntity(h, objConstructor);
        end

        % -----------------------------------------------------------
        % nix.Filter helper functions
        % -----------------------------------------------------------

        function [] = validFilter(filter, val)
            if (~isa(filter, 'nix.Filter'))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Valid nix.Filter required';
                error(err);
            end

            % Currently matlab will crash, if anything other than
            % a cell array is handed over to a nix.Filter.ids.
            if (filter == nix.Filter.ids && ~iscell(val))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'nix.Filter.ids requires a cell array';
                error(err)
            end
        end

        function r = filter(obj, mxMethodName, filter, val, objConstructor)
            nix.Utils.validFilter(filter, val);

            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle, uint8(filter), val);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % -----------------------------------------------------------
        % findXXX helper functions
        % -----------------------------------------------------------

        function r = find(obj, mxMethodName, maxDepth, filter, val, objConstructor)
            if (~isnumeric(maxDepth))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Provide a valid search depth';
                error(err);
            end

            nix.Utils.validFilter(filter, val);

            % transform matlab to c++ style index
            md = nix.Utils.handleIndex(maxDepth);

            mxMethod = strcat(obj.alias, '::', mxMethodName);
            list = nix_mx(mxMethod, obj.nix_handle, md, uint8(filter), val);
            r = nix.Utils.createEntityArray(list, objConstructor);
        end

        % -----------------------------------------------------------
        % c++ vs matlab helper functions
        % -----------------------------------------------------------

        function r = transposeArray(data)
        % Data must agree with file & dimensions; see mkarray.cc(42)
            r = permute(data, length(size(data)):-1:1);
        end

        function r = handleIndex(idx)
        % Matlab uses 1-based indexing opposed to 0 based indexing in C++.
        % handleIndex transforms a Matlab style index to a C++ style
        % index and raises the appropriate Matlab error in case of an
        % invalid subscript.
            if (idx < 1)
                err.identifier = 'MATLAB:badsubscript';
                err.message = 'Subscript indices must either be real positive integers or logicals.';
                error(err);
            end
            r = idx - 1;
        end
    end

end
