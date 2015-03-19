%-- Runner for all other tests.
clear all;

stats.okCount = 0;
stats.errorCount = 0;

disp([10 'starting tests']);

%-- ToDo: create proper testfile, loose the 24mb one

%-- All current tests use the first block from file 'test.h5' with
%--     id: 7b59c0b9-b200-4b53-951d-6851dbd1cdc8
%--     name: joe097

% individual tests
t1.name = 'FILE';
t1.tests = TestFile();
t2.name = 'BLOCK';
t2.tests = TestBlock();
t3.name = 'SOURCE';
t3.tests = TestSource();
t4.name = 'DATA ARRAY';
t4.tests = TestDataArray();
t5.name = 'TAG';
t5.tests = TestTag();
t6.name = 'MULTITAG';
t6.tests = TestMultiTag();
t7.name = 'SECTION';
t7.tests = TestSection();
t8.name = 'FEATURE';
t8.tests = TestFeature();
t9.name = 'PROPERTY';
t9.tests = TestProperty();
t10.name = 'DIMENSIONS';
t10.tests = TestDimensions();

% concatenate all test handles
all_tests = {t1, t2, t3, t4, t5, t6, t7, t8, t9, t10};

for i = 1:length(all_tests)
    fprintf([10 'Execute ' all_tests{i}.name ' tests:\n\n']);
    
    for j = 1:length(all_tests{i}.tests)
        stats = wrapper(all_tests{i}.tests{j}, stats);
    end
end;

disp([10 'Tests: ' num2str(stats.okCount) ' succeeded, ' num2str(stats.errorCount) ' failed']);

