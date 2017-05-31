% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef DataArray < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %DataArray nix DataArray object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'DataArray'
    end;

    properties(Dependent)
        dimensions % should not be dynamic due to complex set operation
    end;
   
    methods
        function obj = DataArray(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'label', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'unit', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'expansionOrigin', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'polynom_coefficients', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'shape', 'rw');
        end;

        % -----------------
        % Dimensions
        % -----------------
        
        function dimensions = get.dimensions(obj)
            dimensions = {};
            currList = nix_mx('DataArray::dimensions', obj.nix_handle);
            for i = 1:length(currList)
                switch currList(i).dtype
                    case 'set'
                        dimensions{i} = nix.SetDimension(currList(i).dimension);
                    case 'sample'
                        dimensions{i} = nix.SampledDimension(currList(i).dimension);
                    case 'range'
                        dimensions{i} = nix.RangeDimension(currList(i).dimension);
                    otherwise
                       disp('some dimension type is unknown! skip')
                end;
            end;
        end;
        
        function dim = append_set_dimension(obj)
            func_name = strcat(obj.alias, '::appendSetDimension');
            dim = nix.SetDimension(nix_mx(func_name, obj.nix_handle));
        end
        
        function dim = append_sampled_dimension(obj, interval)
            func_name = strcat(obj.alias, '::appendSampledDimension');
            dim = nix.SampledDimension(nix_mx(func_name, obj.nix_handle, interval));
        end

        function dim = append_range_dimension(obj, ticks)
            func_name = strcat(obj.alias, '::appendRangeDimension');
            dim = nix.RangeDimension(nix_mx(func_name, obj.nix_handle, ticks));
        end

        function dim = append_alias_range_dimension(obj)
            func_name = strcat(obj.alias, '::appendAliasRangeDimension');
            dim = nix.RangeDimension(nix_mx(func_name, obj.nix_handle));
        end
        
        function delCheck = delete_dimensions(obj)
            func_name = strcat(obj.alias, '::deleteDimensions');
            delCheck = nix_mx(func_name, obj.nix_handle);
        end

        function c = dimension_count(obj)
            c = nix_mx('DataArray::dimensionCount', obj.nix_handle);
        end

        % -----------------
        % Data access methods
        % -----------------

        function data = read_all(obj)
           tmp = nix_mx('DataArray::readAll', obj.nix_handle);
           % data must agree with file & dimensions
           % see mkarray.cc(42)
           data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        %-- TODO add (optional) offset
        %-- If a DataArray has been created as boolean or numeric,
        %-- provide that only values of the proper DataType can be written.
        function write_all(obj, data)
            if(isinteger(obj.read_all) && isfloat(data))
                disp('Warning: Writing Float data to an Integer DataArray');
            end;
            
            errorStruct.identifier = 'DataArray:improperDataType';
            if(islogical(obj.read_all) && ~islogical(data))
                errorStruct.message = strcat('Trying to write', ...
                    32, class(data), ' to a logical DataArray.');
                error(errorStruct);
            elseif(isnumeric(obj.read_all) && ~isnumeric(data))
                errorStruct.message = strcat('Trying to write', ...
                    32, class(data), ' to a ', 32, class(obj.read_all), ...
                    ' DataArray.');
                error(errorStruct);
            elseif(ischar(data))
                %-- Should actually not be reachable at the moment, 
                %-- since writing Strings to DataArrays is not supported,
                %-- but safety first.
                errorStruct.identifier = 'DataArray:unsupportedDataType';
                errorStruct.message = ('Writing char/string DataArrays is not supported as of yet.');
                error(errorStruct);
            else
                % data must agree with file & dimensions
                % see mkarray.cc(42)
                tmp = permute(data, length(size(data)):-1:1);
                nix_mx('DataArray::writeAll', obj.nix_handle, tmp);
            end;
        end;

    end;
end
