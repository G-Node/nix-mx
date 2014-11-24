classdef file < nix.entity
    %FILE nix File object
    
    properties
    end
    
    methods
        function obj = file(path)
           h = nix_mx('File::open', path); 
           obj@nix.entity(h);
        end
        
        function blocks = listBlocks(obj)
            blocks = nix_mx('File::listBlocks', obj.nix_handle);
        end
        
        function b = block(obj, name)
            b = nix_mx('File::openBlock', obj.nix_handle, name);
        end
    end
    
end

