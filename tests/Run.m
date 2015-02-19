%-- Runner for all other tests.
clear all;

stats.okCount = 0;
stats.errorCount = 0;

%-- add required paths for matlab
addpath(fullfile(pwd, 'build'));

disp([10 'starting tests']);

%-- ToDo: create proper testfile, loose the 24mb one

%-- All current tests use the first block from file 'test.h5' with
%--     id: 7b59c0b9-b200-4b53-951d-6851dbd1cdc8
%--     name: joe097

% individual tests
t1 = TestFile();
t2 = TestBlock();
t3 = TestSource();
t4 = TestDataArray();
t5 = TestTag();
t6 = TestMultiTag();
t7 = TestSection();

%-- TODO: TestFeature

% concatenate all test handles
all_tests = {t1{:}, t2{:}, t3{:}, t4{:}, t5{:}, t6{:}, t7{:}};

for i = 1:length(all_tests)
    stats = wrapper(all_tests{i}, stats);
end;

disp([10 'Tests: ' num2str(stats.okCount) ' succeeded, ' num2str(stats.errorCount) ' failed']);

