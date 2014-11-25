classdef DataArray < nix.Entity
    %FILE nix DataArray object
    
    properties
    end
    
    methods
        function obj = DataArray(h)
           obj@nix.Entity(h);
        end
        
        function data = read_all_double(obj)
           data = nix_mx('DataArray::readAll', obj.nix_handle); 
        end
    end
    
end
