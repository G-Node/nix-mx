classdef SetDimension < nix.Entity
    %SetDimension nix SetDimension object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'SetDimension'
    end
    
    methods
        function obj = SetDimension(h)
            obj@nix.Entity(h);
        end
        
        function ua = updatedAt(obj)
            ua = 0;
        end;
    end
end
   