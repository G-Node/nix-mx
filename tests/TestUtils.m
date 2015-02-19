classdef TestUtils
    methods(Static)
        function printErrorStack(me)
            disp([9 me.message]);
            printStack = {me.stack(:).name; me.stack(:).file; me.stack(:).line}';
            disp(vertcat({'Name', 'File', 'Line'}, printStack));
        end;
    end;
end