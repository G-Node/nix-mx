% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Property < nix.NamedEntity
    %PROPERTY Metadata Property class
    %   NIX metadata property
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'Property'
    end;
    
    properties(Dependent)
        values
    end;
    
    methods
        function obj = Property(h)
            obj@nix.NamedEntity(h);
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'unit', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'mapping', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'datatype', 'r');
        end;

        function retVals = get.values(obj)
            retVals = nix_mx('Property::values', obj.nix_handle);
        end

        function [] = set.values(obj, val)
            values = val;
            if (~iscell(values))
                values = num2cell(val);
            end
            
            for i = 1:length(values)
                if (isstruct(values{i}))
                    curr = values{i}.value;
                else
                    curr = values{i};
                end
                
                if (~strcmpi(class(curr), obj.datatype))
                    error('Values do not match property data type!');
                end
            end
            
            nix_mx('Property::updateValues', obj.nix_handle, values);
        end
        
        function c = value_count(obj)
            c = nix_mx('Property::valueCount', obj.nix_handle);
        end

        function [] = values_delete(obj)
            nix_mx('Property::deleteValues', obj.nix_handle);
        end
        
        % return value 0 means name and id of two properties are
        % identical, any other value means either name or id differ.
        function cmp_val = compare(obj, property)
            if (~strcmp(class(property), class(obj)))
               error('Function only supports comparison of Properties.');
            end
            cmp_val = nix_mx('Property::compare', obj.nix_handle, property.nix_handle);
        end

    end

end
