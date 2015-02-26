classdef DataArray < nix.Entity
    %DataArray nix DataArray object
    
    properties(Hidden)
      info
      sourcesCache
      metadataCache
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        label
        shape
        unit
        dimensions
        polynom_coefficients
        
        sources
    end;
   
    methods
        function obj = DataArray(h)
            obj@nix.Entity(h);
            
            obj.sourcesCache.lastUpdate = 0;
            obj.sourcesCache.data = {};
            obj.metadataCache.lastUpdate = 0;
            obj.metadataCache.data = {};
        end;
        
        function nfo = get.info(obj)
            nfo = nix_mx('DataArray::describe', obj.nix_handle);
        end
                
        function id = get.id(obj)
           id = obj.info.id; 
        end;
        
        function type = get.type(obj)
            type = obj.info.type;
        end;
        
        function name = get.name(obj)
           name = obj.info.name;
        end;

        function definition = get.definition(obj)
           definition = obj.info.definition;
        end;

        function label = get.label(obj)
           label = obj.info.label;
        end;

        function shape = get.shape(obj)
           shape = obj.info.shape;
        end;

        function unit = get.unit(obj)
           unit = obj.info.unit;
        end;

        function dimensions = get.dimensions(obj)
           dimensions = obj.info.dimensions;
        end;

        function polynom_coefficients = get.polynom_coefficients(obj)
           polynom_coefficients = obj.info.polynom_coefficients;
        end;
        
        function data = read_all(obj)
           tmp = nix_mx('DataArray::readAll', obj.nix_handle);
           % data must agree with file & dimensions
           % see mkarray.cc(42)
           data = permute(tmp, length(size(tmp)):-1:1);
        end;
        
        % -----------------
        % Sources methods
        % -----------------
        
        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'DataArray::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;
        
        % -----------------
        % Metadata methods
        % -----------------
        
        function hasMetadata = has_metadata(obj)
            hasMetadata = nix_mx('DataArray::hasMetadataSection', obj.nix_handle);
        end;
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'DataArray::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;
    end;
end
