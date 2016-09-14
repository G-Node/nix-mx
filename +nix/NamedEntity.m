% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef NamedEntity < nix.Entity
    %NamedEntity
    % base class for nix entities with name/type/definition

    methods
        function obj = NamedEntity(h)
            obj = obj@nix.Entity(h);
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'id', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'name', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'type', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'definition', 'rw');
        end
    end
    
end
