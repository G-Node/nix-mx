classdef File < nix.Entity
    %File nix File object
    
    properties
    end
    
    methods
        function obj = File(path)
           h = nix_mx('File::open', path); 
           obj@nix.Entity(h);
        end
        
        function blocks = listBlocks(obj)
            blocks = nix_mx('File::listBlocks', obj.nix_handle);
        end
        
        function b = block(obj, name)
            bh = nix_mx('File::openBlock', obj.nix_handle, name);
            b = nix.Block(bh);
        end
    end
    
end

