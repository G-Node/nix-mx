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
    end;
end

