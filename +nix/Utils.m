% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Utils
    methods(Static)

        function currData = fetchObjList(nixMxFunc, handle, objConstructor)
            currList = nix_mx(nixMxFunc, handle);
            currData = cell(length(currList), 1);
            for i = 1:length(currList)
                currData{i} = objConstructor(currList{i});
            end;
        end;

        % This method calls the nix-mx function specified by 'nixMxFunc', handing 
        % over 'handle' as the main nix entity handle and 'related_handle' as a 
        % second nix entity handle related to the first one.
        % 'objConstrucor' requires the Matlab entity constructor of the expected 
        % returned nix Entities.
        function currData = fetchObjListByEntity(nixMxFunc, handle, related_handle, objConstructor)
            currList = nix_mx(nixMxFunc, handle, related_handle);
            currData = cell(length(currList), 1);
            for i = 1:length(currList)
                currData{i} = objConstructor(currList{i});
            end;
        end;

        function retCell = fetchObj(nixMxFunc, handle, objConstructor)
            sh = nix_mx(nixMxFunc, handle);
            if sh ~= 0
                retCell = objConstructor(sh);
            else
                retCell = {};
            end;
        end;

        function [] = add_entity(obj, add_this, nixEntity, mxMethod)
            if(strcmp(class(add_this), nixEntity))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            nix_mx(mxMethod, obj.nix_handle, addID);
        end;

        function [] = add_entity_array(obj, add_cell_array, nixEntity, mxMethod)
            if(~iscell(add_cell_array))
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
        function delCheck = delete_entity(obj, del, nixEntity, mxMethod)
            if(strcmp(class(del), nixEntity))
                delID = del.id;
            else
                delID = del;
            end;
            delCheck = nix_mx(mxMethod, obj.nix_handle, delID);
        end;
        
        function retObj = open_entity(obj, mxMethod, id_or_name, objConstructor)
            handle = nix_mx(mxMethod, obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = objConstructor(handle);
            end;
        end;

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

        function currData = filter(obj, filter, val, mxMethod, objConstructor)
            valid = nix.Utils.valid_filter(filter, val);
            if(~isempty(valid))
                error(valid);
            end

            currList = nix_mx(mxMethod, obj.nix_handle, uint8(filter), val);
            currData = cell(length(currList), 1);
            for i = 1:length(currList)
                currData{i} = objConstructor(currList{i});
            end;
        end

        % -----------------------------------------------------------
        % findXXX helper functions
        % -----------------------------------------------------------

        function currData = find(obj, max_depth, filter, val, ...
                                                mxMethod, objConstructor)
            if (~isnumeric(max_depth))
                error('Provide a valid search depth');
            end

            valid = nix.Utils.valid_filter(filter, val);
            if(~isempty(valid))
                error(valid);
            end

            currList = nix_mx(mxMethod, ...
                            obj.nix_handle, max_depth, uint8(filter), val);

            currData = cell(length(currList), 1);
            for i = 1:length(currList)
                currData{i} = objConstructor(currList{i});
            end;
        end

    end;
end
