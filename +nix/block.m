classdef Block < nix.Entity
    %FILE nix Block object
    
    properties
    end
    
    methods
        function obj = Block(h)
           obj@nix.Entity(h);
        end
        
        function das = data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end
        
        function da = data_array(obj, id_or_name)
           da = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
        end
    end
    
end