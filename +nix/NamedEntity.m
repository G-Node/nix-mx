classdef NamedEntity < nix.Entity & nix.Dynamic
    %NamedEntity
    % base class for nix entities with name/type/definition
    
    properties (Access = protected)
        dynamic_base_attrs = {'id', 'name', 'type', 'definition'}
    end

    methods
        function obj = NamedEntity(h)
            obj = obj@nix.Entity(h);
            obj = obj@nix.Dynamic();
        end
    end
    
end

