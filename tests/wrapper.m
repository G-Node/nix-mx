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

