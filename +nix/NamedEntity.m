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

        function res = compare(obj, entity)
        % Compares first name and second id, return > 0 if the entity 
        % is larger than the other, 0 if both are equal, and < 0 otherwise.
            if(~strcmp(class(obj), class(entity)))
                error('Only entities of the same class can be compared.');
            end;
            res = nix_mx(strcat(obj.alias, '::compare'), ...
                obj.nix_handle, entity.nix_handle);
        end;
    end
    
end
