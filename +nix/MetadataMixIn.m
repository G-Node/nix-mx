% Mixin Class for entities that can be associated with additional metadata.
%
% The data part of the NIX data model consists of six main elements which all inherit 
% from the MetadataMixin Class: nix.Block, nix.Group, nix.DataArray, nix.Tag,
% nix.MultiTag and nix.Source.
% Common to all those entities is an optional property sections which  provides a link 
% to one nix.Section entity and therefore makes it possible to annotate the entities 
% with additional metadata.
%
% Depends on nix.Entity; Utility class, do not use out of context.
%
% See also nix.Section, nix.Block, nix.Group, nix.DataArray, nix.Tag, nix.MultiTag, nix.Source, nix.Entity.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef MetadataMixIn < handle

    properties (Abstract, Hidden)
        alias
    end

    methods
        function r = openMetadata(obj)
            % Retrieves the referenced nix.Section from the invoking nix.Entity.
            %
            % Returns:  (nix.Section) The Section or an empty cell, 
            %                         if no Section was referenced.
            %
            % Example:  getSec = currEntity.openMetadata();
            %
            % See also nix.Section.

            r = nix.Utils.fetchObj(obj, 'openMetadataSection', @nix.Section);
        end

        function [] = setMetadata(obj, idEntity)
            % Set a nix.Section as metadata of the invoking nix.Entity.
            %
            % If metadata was already set, using this method again will
            % replace the reference to the previous Section with a reference
            % to the provided Section.
            %
            % The link to a Section can be removed by handing an empty string 
            % to the method. The referenced Section itself will not be removed.
            %
            % idEntity (char/nix.Section):  The id of an existing Section,
            %                                 or a valid nix.Section entity.
            %
            % Example:  currEntity.setMetadata('some-section-id');
            %           currEntity.setMetadata(currFile.sections{1});
            %           currEntity.setMetadata('');  %-- remove reference to Section.
            %
            % See also nix.Section.

            if (isempty(idEntity))
                fname = strcat(obj.alias, '::setNoneMetadata');
                nix_mx(fname, obj.nixhandle, idEntity);
            else
                nix.Utils.addEntity(obj, 'setMetadata', idEntity, 'nix.Section');
            end
        end
    end

end
