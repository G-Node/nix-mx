classdef Block < nix.Entity
    %Block nix Block object
    
    properties(Hidden)
        info
    end
    
    properties(Dependent)
        name
        type
    end
    
    methods
        function obj = Block(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Block::describe', obj.nix_handle);
        end
        
        function name = get.name(block)
           name = block.info.name;
        end
        
        function type = get.type(block)
            type = block.info.type;
        end
        
        function das = data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end
        
        function da = data_array(obj, id_or_name)
           dh = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
           da = nix.DataArray(dh);
        end
    end
    
end