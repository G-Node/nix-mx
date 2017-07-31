% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Feature < nix.Entity
    % Feature nix Feature object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Feature'
    end

    properties(Dependent)
        id
        linkType
    end

    methods
        function obj = Feature(h)
           obj@nix.Entity(h);
        end

        function r = get.id(obj)
           r = obj.info.id; 
        end

        function r = get.linkType(obj)
            r = nix_mx('Feature::getLinkType', obj.nix_handle);
        end

        function [] = set.linkType(obj, linkType)
            nix_mx('Feature::setLinkType', obj.nix_handle, linkType);
        end

        function r = open_data(obj)
           r = nix.DataArray(nix_mx('Feature::openData', obj.nix_handle));
        end

        function [] = set_data(obj, setData)
            if(strcmp(class(setData), 'nix.DataArray'))
                setData = setData.id;
            end
            nix_mx('Feature::setData', obj.nix_handle, setData);
        end
    end

end
