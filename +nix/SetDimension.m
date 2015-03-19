classdef SetDimension < nix.Entity
    %SetDimension nix SetDimension object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'SetDimension'
    end
    
    methods
        function obj = SetDimension(h)
            obj@nix.Entity(h);
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'dimensionType', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'labels', 'rw');
        end
    end
end
   