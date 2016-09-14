% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

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
            metadata = nix.Utils.fetchObj(...
                strcat(obj.alias, '::openMetadataSection'), ...
                obj.nix_handle, @nix.Section);
        end;

        function set_metadata(obj, val)
            if (isempty(val))
                nix_mx(strcat(obj.alias, '::setNoneMetadata'), ...
                    obj.nix_handle, val);
            else
                nix.Utils.add_entity(obj, val, 'nix.Section', ...
                    strcat(obj.alias, '::setMetadata'));
            end;
        end;
    end;
    
end
