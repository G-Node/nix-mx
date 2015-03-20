classdef Property < nix.NamedEntity
    %PROPERTY Metadata Property class
    %   NIX metadata property
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'Property'
        valuesCache
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
            
            obj.valuesCache = nix.CacheStruct();
        end;

        function retVals = get.values(obj)
            [obj.valuesCache, retVals] = nix.Utils.fetchPropList(obj.updatedAt, ...
                'Property::values', obj.nix_handle, obj.valuesCache);
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
            obj.valuesCache.lastUpdate = 0;

            dispStr = 'Note: nix only supports updating the actual value at the moment.';
            dispStr = [dispStr, char(10), 'Attributes like uncertainty or checksum cannot be set at the moment.'];
            disp(dispStr);
        end
    end
    
end

