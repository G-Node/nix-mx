classdef Utils
    methods(Static)

        function [currCache, retCell] = fetchObjList(currUpdatedAt, nixMxFunc, handle, currCache, objConstructor)
            if currCache.lastUpdate ~= currUpdatedAt
                currList = nix_mx(nixMxFunc, handle);
                currCache.data = cell(length(currList), 1);
                for i = 1:length(currList)
                	currCache.data{i} = objConstructor(currList{i});
                end;
                currCache.lastUpdate = currUpdatedAt;
            end;
            retCell = currCache.data;
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
    end;
end

