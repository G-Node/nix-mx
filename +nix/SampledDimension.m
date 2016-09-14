% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SampledDimension < nix.Entity
    %SampledDimension nix SampledDimension object
    
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

        function indexOf = index_of(obj, position)
            func_name = strcat(obj.alias, '::indexOf');
            indexOf = nix_mx(func_name, obj.nix_handle, position);
        end
        
        function posAt = position_at(obj, index)
            if index > 0
                index = index - 1;
            end
            func_name = strcat(obj.alias, '::positionAt');
            posAt = nix_mx(func_name, obj.nix_handle, index);
        end

        function axis = axis(obj, count, startIndex)
            if nargin < 3
                startIndex = 0;
            end
            if startIndex > 0
                startIndex = startIndex - 1;
            end
            func_name = strcat(obj.alias, '::axis');
            axis = nix_mx(func_name, obj.nix_handle, count, startIndex);
        end
    end
end
