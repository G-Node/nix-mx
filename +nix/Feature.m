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
            fname = strcat(obj.alias, '::getLinkType');
            r = nix_mx(fname, obj.nix_handle);
        end

        function [] = set.linkType(obj, linkType)
            fname = strcat(obj.alias, '::setLinkType');
            nix_mx(fname, obj.nix_handle, linkType);
        end

        function r = open_data(obj)
            fname = strcat(obj.alias, '::openData');
            h = nix_mx(fname, obj.nix_handle);
            r = nix.DataArray(h);
        end

        function [] = set_data(obj, setData)
            if(strcmp(class(setData), 'nix.DataArray'))
                setData = setData.id;
            end
            fname = strcat(obj.alias, '::setData');
            nix_mx(fname, obj.nix_handle, setData);
        end
    end

end
