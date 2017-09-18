% nix.FileMode provides access to the Modes a NIX file can be opened.
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef FileMode

    properties (Constant)
        ReadOnly = uint8(0);
        ReadWrite = uint8(1);
        Overwrite = uint8(2);
    end

end
