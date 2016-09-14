% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef LinkType
    %LINKTYPE nix link types

    properties (Constant)
        Tagged = uint8(0)
        Untagged = uint8(1)
        Indexed = uint8(2)
    end

end
