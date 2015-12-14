classdef Utils
    methods(Static)

        function [currData] = fetchObjList(nixMxFunc, handle, objConstructor)
            currList = nix_mx(nixMxFunc, handle);
            currData = cell(length(currList), 1);
            for i = 1:length(currList)
                currData{i} = objConstructor(currList{i});
            end;
        end;
        
        function [currCache, retCell] = fetchPropList(currUpdatedAt, nixMxFunc, handle, currCache)
            if currCache.lastUpdate ~= currUpdatedAt
                currCache.data = nix_mx(nixMxFunc, handle);
                currCache.lastUpdate = currUpdatedAt;
            end;
            retCell = currCache.data;
        end;

        function [currCache, retCell] = fetchObj(currUpdatedAt, nixMxFunc, handle, currCache, objConstructor)
            if currCache.lastUpdate ~= currUpdatedAt
                sh = nix_mx(nixMxFunc, handle);
                if sh ~= 0
                    currCache.data = objConstructor(sh);
                else
                    currCache.data = {};
                end;
                currCache.lastUpdate = currUpdatedAt;
            end;
            retCell = currCache.data;
        end;

        function currCache = add_entity(obj, add_this, nixEntity, mxMethod, currCache)
            if(strcmp(class(add_this), nixEntity))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            nix_mx(mxMethod, obj.nix_handle, addID);
            currCache.lastUpdate = 0;
        end;

        % function can be used for both nix delete and remove methods
        % the first actually removes the entity, the latter
        % removes only the reference to the entity
        function [delCheck, currCache] = delete_entity(obj, del, nixEntity, mxMethod, currCache)
            if(strcmp(class(del), nixEntity))
                delID = del.id;
            else
                delID = del;
            end;
            delCheck = nix_mx(mxMethod, obj.nix_handle, delID);
            currCache.lastUpdate = 0;
        end;

        %-- functions for the transition between cache and no-cache;
        %-- remove above at the end of the refactoring step and rename
        %-- to appropriate functions.
        function retCell = fetchObj_(nixMxFunc, handle, objConstructor)
            sh = nix_mx(nixMxFunc, handle);
            if sh ~= 0
                retCell = objConstructor(sh);
            else
                retCell = {};
            end;
        end;

        function [] = add_entity_(obj, add_this, nixEntity, mxMethod)
            if(strcmp(class(add_this), nixEntity))
                addID = add_this.id;
            else
                addID = add_this;
            end;
            nix_mx(mxMethod, obj.nix_handle, addID);
        end;

        % function can be used for both nix delete and remove methods
        % the first actually removes the entity, the latter
        % removes only the reference to the entity
        function delCheck = delete_entity_(obj, del, nixEntity, mxMethod)
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
        
    end;
end

