classdef Feature < nix.Entity
    %Feature nix Feature object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Feature'
    end
    
    properties(Dependent)
        id
        linkType
    end;
    
    methods
        function obj = Feature(h)
           obj@nix.Entity(h);
        end;

        function id = get.id(obj)
           id = obj.info.id; 
        end;

        function linkType = get.linkType(obj)
            linkType = obj.info.linkType;
        end;

        function dataArray = open_data(obj)
           dataArray = nix.DataArray(nix_mx('Feature::openData', obj.nix_handle));
        end;
    end;

end