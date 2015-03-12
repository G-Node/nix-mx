classdef Feature < nix.Entity
    %Feature nix Feature object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Feature'
    end
    
    properties(Dependent)
        id
    end;
    
    methods
        function obj = Feature(h)
           obj@nix.Entity(h);
        end;
        
        function id = get.id(obj)
           id = obj.info.id; 
        end;
        
        function linkType = link_type(obj)
            linkType = nix_mx('Feature::linkType', obj.nix_handle);
        end;
        
        function dataArray = open_data(obj, id_or_name)
           daHandle = nix_mx('Feature::openData', obj.nix_handle, id_or_name); 
           dataArray = nix.Feature(daHandle);
        end;
    end;

end