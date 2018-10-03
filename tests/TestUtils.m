% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef TestUtils

    methods(Static)

        function printErrorStack(me)
            disp([9 me.message]);
            printStack = {me.stack(:).name; me.stack(:).file; me.stack(:).line}';
            disp(vertcat({'Name', 'File', 'Line'}, printStack));
        end

    end

end
