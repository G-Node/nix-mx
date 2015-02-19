function funcs = testDataArray
%TESTDATAARRAY tests for DataArray
%   Detailed explanation goes here

    funcs{1} = @test_open_data;
    funcs{2} = @test_has_metadata;
    funcs{3} = @test_open_metadata;
end

%% Test: Read all data from DataArray
function [] = test_open_data( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);

    assert(size(getDataArray.read_all(),2) == 36);
end

%% Test: Has metadata
function [] = test_has_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    %-- ToDo implement test for empty metadata
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    %assert(~getDataArray.has_metadata());
    disp('Test DataArray: has empty metadata ... TODO (proper testfile)');
    
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    assert(getDataArray.has_metadata())
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    %-- ToDo implement test for empty metadata
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    %assert(isempty(getDataArray.open_metadata()))
    disp('Test DataArray: open empty metadata ... TODO (proper testfile)');
    
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    assert(~isempty(getDataArray.open_metadata()))
end

