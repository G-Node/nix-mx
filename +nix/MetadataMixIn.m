classdef MetadataMixIn < handle
    %MetadataMixIn
    % mixin class for nix entities with metadata
    % depends on 
    % - nix.Entity
    
    properties (Abstract, Hidden)
        alias
    end
    
    methods
        function metadata = open_metadata(obj)
            metadata = nix.Utils.fetchObj_(...
                strcat(obj.alias, '::openMetadataSection'), ...
                obj.nix_handle, @nix.Section);
        end;

        function set_metadata(obj, val)
            if (isempty(val))
                nix_mx(strcat(obj.alias, '::set_none_metadata'), ...
                    obj.nix_handle, val);
            else
                nix.Utils.add_entity_(obj, val, 'nix.Section', ...
                    strcat(obj.alias, '::set_metadata'));
            end;
        end;
    end;
    
end
