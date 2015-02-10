classdef DataArray < nix.Entity
    %DataArray nix DataArray object
    
    properties
    end
    
    properties (Dependent)
      info
    end
   
    methods
        function obj = DataArray(h)
           obj@nix.Entity(h);
        end
        function nfo = get.info(obj)
            nfo = nix_mx('DataArray::describe', obj.nix_handle);
        end
        
        function data = read_all_double(obj)
           data = nix_mx('DataArray::readAll', obj.nix_handle); 
        end
    end
    
end
