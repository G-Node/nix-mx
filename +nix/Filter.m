% nix.Filter provides access to all filters supported by nix filter functions.
%
% 'acceptall'  returns an unfiltered result; requires an empty value.
% 'id'         returns all entities matching the provided id string.
% 'ids'        returns all entities matching the provided ids. id strings
%                have to be provided as a cell array.
% 'type'       returns all entities where their type matches the provided string.
% 'name'       returns all entities where their name matches the provided string.
% 'metadata'   returns all entities which link to a Section with the
%                provided id string.
% 'source'     returns all entities which link to a Source with the
%                provided id or name string.
%
% Please note, that not all filter functions support every filter listed
% here. Consult the documentation for every filter function for details.
%
%
% Copyright (c) 2017, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Filter < uint8

    enumeration
        acceptall (0); % requires an empty value
        id (1);
        ids (2); % requires a cell array
        type (3);
        name (4);
        metadata (5); % filters by id
        source (6); % filters by name or id
    end

end
