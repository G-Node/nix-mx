classdef File < nix.Entity
    %File nix File object
    methods
        function obj = File(path, mode)
            if ~exist('mode', 'var')
                mode = FileMode.ReadWrite; %default to ReadWrite
            end
           h = nix_mx('File::open', path, mode); 
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

