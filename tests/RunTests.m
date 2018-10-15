% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

%-- Runner for all other tests.
clear all;

stats.okCount = 0;
stats.errorCount = 0;

disp([10 'starting tests']);

%-- ToDo: create proper testfile, loose the 24mb one

%-- All current tests use the first block from file 'test.h5' with
%--     id: 7b59c0b9-b200-4b53-951d-6851dbd1cdc8
%--     name: joe097

all = {};
all{end+1} = struct('name', 'FILE', 'tests', {TestFile()});
all{end+1} = struct('name', 'BLOCK', 'tests', {TestBlock()});
all{end+1} = struct('name', 'GROUP', 'tests', {TestGroup()});
all{end+1} = struct('name', 'SOURCE', 'tests', {TestSource()});
all{end+1} = struct('name', 'DATAARRAY', 'tests', {TestDataArray()});
all{end+1} = struct('name', 'TAG', 'tests', {TestTag()});
all{end+1} = struct('name', 'MULTITAG', 'tests', {TestMultiTag()});
all{end+1} = struct('name', 'SECTION', 'tests', {TestSection()});
all{end+1} = struct('name', 'FEATURE', 'tests', {TestFeature()});
all{end+1} = struct('name', 'PROPERTY', 'tests', {TestProperty()});
all{end+1} = struct('name', 'DIMENSIONS', 'tests', {TestDimensions()});

for i = 1:length(all)
    fprintf([10 'Execute ' all{i}.name ' tests:\n\n']);
    
    for j = 1:length(all{i}.tests)
        stats = wrapper(all{i}.tests{j}, stats);
    end
end

disp([10 'Tests: ' num2str(stats.okCount) ' succeeded, ' num2str(stats.errorCount) ' failed']);
