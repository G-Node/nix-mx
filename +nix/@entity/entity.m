classdef entity < handle
    %ENTITY base class for nix entities
    %   handles object lifetime
    
    properties
        nix_handle
    end
    
    methods
        function obj = entity(h)
            obj.nix_handle = h;
        end
        function delete(obj)
            nix_mx('Entity::destroy', obj.nix_handle);
        end
    end
    
end

