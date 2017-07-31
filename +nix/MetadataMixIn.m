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
        function r = open_metadata(obj)
            fname = strcat(obj.alias, '::openMetadataSection');
            r = nix.Utils.fetchObj(fname, obj.nix_handle, @nix.Section);
        end

        function [] = set_metadata(obj, val)
            if (isempty(val))
                fname = strcat(obj.alias, '::setNoneMetadata');
                nix_mx(fname, obj.nix_handle, val);
            else
                fname = strcat(obj.alias, '::setMetadata');
                nix.Utils.add_entity(obj, val, 'nix.Section', fname);
            end
        end
    end

end
