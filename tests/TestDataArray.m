% Tests for the nix.DataArray object

%% Test: Read all data from DataArray
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);

    assert(size(getDataArray.read_all(),1) == 36);
    disp('Test DataArray: read all data ... OK');

    clear; %-- close handles

catch me
    disp('Test DataArray: read all data ... ERROR');
    rethrow(me);
end;

%% Test: Has metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    %-- ToDo implement test for empty metadata
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    %assert(~getDataArray.has_metadata());
    disp('Test DataArray: has empty metadata ... TODO (proper testfile)');
    
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    assert(getDataArray.has_metadata())
    disp('Test DataArray: has existing metadata ... OK');
    
    clear; %-- close handles

catch me
    disp('Test DataArray: has empty/existing metadata ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    %-- ToDo implement test for empty metadata
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    %assert(isempty(getDataArray.open_metadata()))
    disp('Test DataArray: open empty metadata ... TODO (proper testfile)');
    
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    assert(~isempty(getDataArray.open_metadata()))
    disp('Test DataArray: open existing metadata ... OK');
    
    clear; %-- close handles

catch me
    disp('Test DataArray: open empty/existing metadata ... ERROR');
    rethrow(me);
end;

