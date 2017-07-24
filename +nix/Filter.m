classdef Filter < uint8
    %FILTER available nix custom filters

    enumeration
        accept_all (0); % requires an empty value
        id (1);
        ids (2); % requires a cell array
        type (3);
        name (4);
        metadata (5);
        source (6);
    end
    
end
