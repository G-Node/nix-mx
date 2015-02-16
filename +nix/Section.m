classdef Section < nix.Entity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties
    end
    
    methods
        function obj = Section(h)
           obj@nix.Entity(h);
           %obj.info = nix_mx('Block::describe', obj.nix_handle);
        end;
        
    end
    
end

