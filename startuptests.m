addpath(genpath(pwd));
RunTests;
if (stats.errorCount > 0)
    exit(1);
end
exit(0);
