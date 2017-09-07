% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SampledDimension < nix.Entity
    % SampledDimension nix SampledDimension object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'SampledDimension'
    end

    methods
        function obj = SampledDimension(h)
            obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'dimensionType', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'label', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'unit', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'samplingInterval', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'offset', 'rw');
        end

        function r = index_of(obj, position)
            fname = strcat(obj.alias, '::indexOf');
            r = nix_mx(fname, obj.nix_handle, position);
        end

        function r = position_at(obj, index)
            index = nix.Utils.handle_index(index);
            fname = strcat(obj.alias, '::positionAt');
            r = nix_mx(fname, obj.nix_handle, index);
        end

        function r = axis(obj, count, startIndex)
            if (nargin < 3)
                startIndex = 1;
            end

            startIndex = nix.Utils.handle_index(startIndex);
            fname = strcat(obj.alias, '::axis');
            r = nix_mx(fname, obj.nix_handle, count, startIndex);
        end
    end

end
