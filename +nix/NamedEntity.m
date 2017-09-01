% MixIn class for NIX entites with basic dynamic properties.
%
% In addition to the properties defined by nix.Entity most entities of the NIX data model
% further provide the properties id, name, type and definition.
%
% The id property of an entity is automatically assigned and serves as a machine readable 
% unique identifier. The name property of an entity serves as a human readable identifier 
% and can be set at the creation of an entity. The type property is used to allow the 
% specification of additional semantic meaning for an entity and therefore can introduce 
% domain-specificity into the generic data model. The optional definition property allows 
% the user to add a freely assignable textual definition to the entity.
%
% Dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, additional description of the entity.
%
% See also: nix.Block, nix.Group, nix.DataArray, nix.Source, nix.Tag,
% nix.MultiTag, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef NamedEntity < nix.Entity

    methods
        function obj = NamedEntity(h)
            obj = obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'id', 'r');
            nix.Dynamic.addProperty(obj, 'name', 'r');
            nix.Dynamic.addProperty(obj, 'type', 'rw');
            nix.Dynamic.addProperty(obj, 'definition', 'rw');
        end

        function r = compare(obj, entity)
            % Checks two NIX entities of the same class for equality.
            %
            % The name property is the first comparison. If they are the same, 
            % the ids of the entities will be compared.
            %
            % Returns:  (double)  0 if both entities are equal.
            %                     > or < 0 if the entities are different.
            %
            % Example:  check = currSource.compare(otherSource);

            if (~isa(obj, class(entity)))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Only entities of the same class can be compared.';
                error(err);
            end
            fname = strcat(obj.alias, '::compare');
            r = nix_mx(fname, obj.nixhandle, entity.nixhandle);
        end
    end

end
