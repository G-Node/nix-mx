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

    end;
end

