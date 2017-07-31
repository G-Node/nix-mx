% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SetDimension < nix.Entity
    % SetDimension nix SetDimension object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'SetDimension'
    end

    methods
        function obj = SetDimension(h)
            obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'dimensionType', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'labels', 'rw');
        end
    end

end
