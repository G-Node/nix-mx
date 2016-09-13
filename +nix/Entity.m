% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Entity < dynamicprops
    %Entity base class for nix entities
    %   handles object lifetime
    
    properties (Hidden)
        nix_handle
        info
    end
    
    properties (Abstract, Hidden)
        alias
    end
    
    methods
        function obj = Entity(h)
            obj.nix_handle = h;
            
            % fetch all object attrs
            obj.info = nix_mx(strcat(obj.alias, '::describe'), obj.nix_handle);
        end
        
        function delete(obj)
            nix_mx('Entity::destroy', obj.nix_handle);
        end
        
        function ua = updatedAt(obj)
            ua = nix_mx('Entity::updatedAt', obj.nix_handle);
        end;
    end
    
end
