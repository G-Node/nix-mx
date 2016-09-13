% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function stats = wrapper( func, stats )
%WRAPPER Wrapper function for every test that catches the exception
%   and prints out detaied report.

    try
        clearvars -except stats func; %-- ensure clean workspace

        func(); % execute unit test

        fprintf('Test %s ... OK\n', func2str(func));
        stats.okCount = stats.okCount + 1;
        clearvars -except stats func; %-- close handles
        
    catch me
        fprintf('Test %s ... ERROR\n', func2str(func));
        TestUtils.printErrorStack(me);
        stats.errorCount = stats.errorCount + 1;
    end;

end
