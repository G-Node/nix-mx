% Tests for the nix.Source object

%% Test: List/fetch sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.id);
    getSourceFromBlock = getBlock.open_source(getBlock.sources{1,1}.id);

    %-- TODO: get a testfile with nested sources
    assert(size(getSourceFromBlock.list_sources(),1) == 0);
    disp('Test Source: list sources ... TODO (proper testfile)');
    
    assert(size(getSourceFromBlock.sources(), 1) == 0);
    disp('Test Source: fetch sources ... TODO (proper testfile)');

    clear; %-- close handles

catch me
    disp('Test Source: list/fetch sources ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.id);
    getSFromB = getBlock.open_source(getBlock.sources{1,1}.id);
    
    %-- TODO: comment in, when testfile with nested sources is available
    %getSourceByID = getSFromB.open_source(getSFromB.sources{1,1}.id);
    %assert(strcmp(getSourceByID.id, ''));
    disp('Test Source: open source by ID ... TODO (proper testfile)');

    %getSourceByName = getSFromB.open_source(getSFromB.sources{1,1}.name);
    %assert(strcmp(getSourceByName.id, ''));
    disp('Test Source: open source by name ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test Source: open source by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Has metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    
    getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    assert(~getSource.has_metadata());
    disp('Test Source: has empty metadata ... OK');
    
    %-- ToDo implement test for empty metadata
    %getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    %assert(getSource.has_metadata())
    disp('Test Source: has existing metadata ... TODO (proper testfile)');
    
    clear; %-- close handles

catch me
    disp('Test Source: has empty/existing metadata ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    assert(isempty(getSource.open_metadata()))
    disp('Test Source: open empty metadata ... OK');
    
    %-- ToDo implement test for empty metadata
    %getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    %assert(~isempty(getSource.open_metadata()))
    disp('Test Source: open existing metadata ... TODO (proper testfile)');
    
    clear; %-- close handles

catch me
    disp('Test Source: open empty/existing metadata ... ERROR');
    rethrow(me);
end;


