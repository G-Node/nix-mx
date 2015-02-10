classdef Entity < handle
    %Entity base class for nix entities
    %   handles object lifetime
    
    properties
        nix_handle
    end
    
    methods
        function obj = Entity(h)
            obj.nix_handle = h;
        end
        function delete(obj)
            nix_mx('Entity::destroy', obj.nix_handle);
        end
    end
    
end

