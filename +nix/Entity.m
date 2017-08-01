% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Entity < dynamicprops
    % Entity base class for nix entities
    %   handles object lifetime

    properties (Hidden)
        nix_handle
    end

    properties (SetAccess=private, GetAccess=public, Hidden)
        info
    end

    properties (Abstract, Hidden)
        alias
    end

    methods
        function obj = Entity(h)
            obj.nix_handle = h;
        end

        function [] = delete(obj)
            nix_mx('Entity::destroy', obj.nix_handle);
        end

        function r = updatedAt(obj)
            r = nix_mx('Entity::updatedAt', obj.nix_handle);
        end

        function r = get.info(obj)
            fname = strcat(obj.alias, '::describe');
            r = nix_mx(fname, obj.nix_handle);
        end
    end

end
