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

