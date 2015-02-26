classdef CacheStruct < handle
    % A simple class to cache cell arrays of objects
    
    properties
        lastUpdate = 0;
        data = {};
    end
end