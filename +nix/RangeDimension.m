% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef RangeDimension < nix.Entity
    %RangeDimension nix RangeDimension object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'RangeDimension'
    end
    
    methods
        function obj = RangeDimension(h)
            obj@nix.Entity(h);
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'dimensionType', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'isAlias', 'r');
            nix.Dynamic.add_dyn_attr(obj, 'label', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'unit', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'ticks', 'rw');
        end

        function tickAt = tick_at(obj, index)
            if index > 0
                index = index - 1;
            end
            func_name = strcat(obj.alias, '::tick_at');
            tickAt = nix_mx(func_name, obj.nix_handle, index);
        end
        
        function indexOf = index_of(obj, position)
            func_name = strcat(obj.alias, '::index_of');
            indexOf = nix_mx(func_name, obj.nix_handle, position);
        end

        function axis = axis(obj, count, startIndex)
            if nargin < 3
                startIndex = 0;
            end
            if(startIndex > 0)
                startIndex = startIndex - 1;
            end
            
            func_name = strcat(obj.alias, '::axis');
            axis = nix_mx(func_name, obj.nix_handle, count, startIndex);
        end

    end
end
