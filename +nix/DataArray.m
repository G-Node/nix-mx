classdef DataArray < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %DataArray nix DataArray object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'DataArray'
        dimsCache
    end

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
            
            obj.dimsCache = nix.CacheStruct();
        end;

        % -----------------
        % Dimensions
        % -----------------
        
        function dimensions = get.dimensions(obj)
            if obj.dimsCache.lastUpdate ~= obj.updatedAt
                currList = nix_mx('DataArray::dimensions', obj.nix_handle);
                obj.dimsCache.data = cell(length(currList), 1);
                for i = 1:length(currList)
                    
                    switch currList(i).dtype
                        case 'set'
                            obj.dimsCache.data{i} = nix.SetDimension(currList(i).dimension);
                        case 'sample'
                            obj.dimsCache.data{i} = nix.SampledDimension(currList(i).dimension);
                        case 'range'
                            obj.dimsCache.data{i} = nix.RangeDimension(currList(i).dimension);
                        otherwise
                           disp('some dimension type is unknown! skip')
                    end
                end;
                obj.dimsCache.lastUpdate = obj.updatedAt;
            end;
            dimensions = obj.dimsCache.data;
        end;
        
        function dim = append_set_dimension(obj)
            func_name = strcat(obj.alias, '::append_set_dimension');
            dim = nix.SetDimension(nix_mx(func_name, obj.nix_handle));
            obj.dimsCache.lastUpdate = 0;
        end
        
        function dim = append_sampled_dimension(obj, interval)
            func_name = strcat(obj.alias, '::append_sampled_dimension');
            dim = nix.SampledDimension(nix_mx(func_name, obj.nix_handle, interval));
            obj.dimsCache.lastUpdate = 0;
        end

        function dim = append_range_dimension(obj, ticks)
            func_name = strcat(obj.alias, '::append_range_dimension');
            dim = nix.RangeDimension(nix_mx(func_name, obj.nix_handle, ticks));
            obj.dimsCache.lastUpdate = 0;
        end

        function delCheck = delete_dimension(obj, index)
            func_name = strcat(obj.alias, '::delete_dimension');
            delCheck = nix_mx(func_name, obj.nix_handle, index);
            obj.dimsCache.lastUpdate = 0;
        end;
        
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
        function write_all(obj, data)
            %-- Bugifx: if a data array has been created as
            %-- boolean or char, provide check that only logical or char
            %-- values can be written, otherwise the
            %-- error message from nix is too cryptic.
            if(islogical(obj.read_all) && ~islogical(data))
                error(strcat('Trying to write', 32, class(data), ...
                	' to a logical DataArray. Provide data as logical.'));
            elseif(ischar(obj.read_all) && ~ischar(data))
                error(strcat('Trying to write', 32, class(data), ...
                	' to a char DataArray. Provide data as char.'));
            else
                % data must agree with file & dimensions
                % see mkarray.cc(42)
                tmp = permute(data, length(size(data)):-1:1);
                nix_mx('DataArray::writeAll', obj.nix_handle, tmp);
            end;
        end;

    end;
end
