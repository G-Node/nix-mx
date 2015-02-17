%-- Runner for all other tests.

%-- add required paths for matlab
addpath(fullfile(pwd, 'build'));

%-- ToDo: create proper testfile, loose the 24mb one

%-- All current tests use the first block from file 'test.h5' with
%--     id: 7b59c0b9-b200-4b53-951d-6851dbd1cdc8
%--     name: joe097

TestFile;

TestBlock;

TestSource;

TestDataArray;

TestTag;

disp('Tests completed successfully. Bye.');

