classdef NamedEntity < nix.Entity & nix.Dynamic
    %NamedEntity
    % base class for nix entities with name/type/definition

    methods
        function obj = NamedEntity(h)
            obj = obj@nix.Entity(h);
            obj = obj@nix.Dynamic();
            
            % assign dynamic properties
            obj.add_dyn_attr('id', 'r');
            obj.add_dyn_attr('name', 'r');
            obj.add_dyn_attr('type', 'rw');
            obj.add_dyn_attr('definition', 'rw');
        end
    end
    
end

