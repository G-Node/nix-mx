% Base class for nix entities.
%
% Class provides access to the info property and handles the lifetime
% of a nix entitiy.
%
% Utility class, do not use out of context.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Entity < dynamicprops

    properties (Hidden)
        nixhandle
    end

    properties (SetAccess=private, GetAccess=public, Hidden)
        info
    end

    properties (Abstract, Hidden)
        alias
    end

    methods
        function obj = Entity(h)
            obj.nixhandle = h;
        end

        function [] = delete(obj)
            nix_mx('Entity::destroy', obj.nixhandle);
        end

        function r = updatedAt(obj)
            % Provides the time the entity was last updated.

            r = nix_mx('Entity::updatedAt', obj.nixhandle);
        end

        function r = get.info(obj)
            fname = strcat(obj.alias, '::describe');
            r = nix_mx(fname, obj.nixhandle);
        end
    end

end
