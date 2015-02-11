buildpath = fullfile(pwd, 'build');
addpath(buildpath);
dbgpath = fullfile(buildpath, 'Debug');
if exist(dbgpath, 'file')
    addpath(dbgpath);
end
addpath(pwd);