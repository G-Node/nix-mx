classdef DataArray < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %DataArray nix DataArray object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'DataArray'
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
        end;
        
        function dimensions = get.dimensions(obj)
           dimensions = obj.info.dimensions;
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
        
        function write_all(obj, data)  % TODO add (optional) offset
           % data must agree with file & dimensions
           % see mkarray.cc(42)
           tmp = permute(data, length(size(data)):-1:1);
           nix_mx('DataArray::writeAll', obj.nix_handle, tmp);
        end;
        
    end;
end
