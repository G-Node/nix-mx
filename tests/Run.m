%-- Runner for all other tests.

stats.okCount = 0;
stats.errorCount = 0;

%-- add required paths for matlab
addpath(fullfile(pwd, 'build'));

disp('');
disp('starting tests');

%-- ToDo: create proper testfile, loose the 24mb one

%-- All current tests use the first block from file 'test.h5' with
%--     id: 7b59c0b9-b200-4b53-951d-6851dbd1cdc8
%--     name: joe097

% individual tests
t1 = testFile();
t2 = testBlock();
%t2 = testSource();
%t2 = testDataArray();
%t2 = testTag();
%t2 = testMultiTag();
t7 = testSection();

%-- TODO: TestFeature

% concatenate all test handles
all_tests = {t1{:}, t2{:}, t7{:}};

for i = 1:length(all_tests)
    wrapper(all_tests{i}, stats);
end;

disp('Tests completed successfully. Bye.');