classdef MetadataMixIn < handle
    %MetadataMixIn
    % mixin class for nix entities with metadata
    % depends on 
    % - nix.Entity
    
    properties (Abstract, Hidden)
        alias
    end
    
    properties(Hidden)
        metadataCache
    end;
    
    methods
        function obj = MetadataMixIn()
            obj.metadataCache = nix.CacheStruct();
        end
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(...
                obj.updatedAt, ...
                strcat(obj.alias, '::openMetadataSection'), ...
                obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

        function set_metadata(obj, val)
            if (isempty(val))
                nix_mx(strcat(obj.alias, '::set_none_metadata'), obj.nix_handle, val);
            else
                obj.metadataCache = nix.Utils.add_entity(obj, val, 'nix.Section', ...
                    strcat(obj.alias, '::set_metadata'), obj.metadataCache);
            end;
            obj.metadataCache.lastUpdate = 0;
        end;
    end;
    
end

