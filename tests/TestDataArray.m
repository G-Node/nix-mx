function funcs = TestDataArray
%TESTDATAARRAY tests for DataArray
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_open_data;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_list_sources;
    funcs{end+1} = @test_set_data;
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.create_data_array('daTest', 'test nixDataArray', 'double', [1 2]);

    assert(~isempty(da.id));
    assert(strcmp(da.name, 'daTest'));
    assert(strcmp(da.type, 'test nixDataArray'));

    %-- TODO does not work at the moment on the c++ side
    da.type = 'nixDataArray';
    assert(strcmp(da.type, 'nixDataArray'));

    assert(isempty(da.definition));
    da.definition = 'data array definition';
    assert(strcmp(da.definition, 'data array definition'));

    da.definition = '';
    assert(isempty(da.definition));

    assert(isempty(da.unit));
    da.unit = 'ms';
    assert(strcmp(da.unit, 'ms'));

    da.unit = '';
    assert(isempty(da.unit));

    assert(isempty(da.label));
    da.label = 'data array label';
    assert(strcmp(da.label, 'data array label'));

    da.label = '';
    assert(isempty(da.label));
end

%% Test: Read all data from DataArray
function [] = test_open_data( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);

    assert(size(getDataArray.read_all(),2) == 36);
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

%% Test: List sources
function [] = test_list_sources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    d1 = b.dataArrays{1};

    assert(~isempty(d1.sources));
    assert(strcmp(d1.sources{1}.name, 'Unit 5'));
end

%% Test: Set Data
function [] = test_set_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixblock');

    d1 = b.create_data_array('foo', 'bar', 'double', [2 3]);
    tmp = d1.read_all();
    assert(all(tmp(:) == 0));
    
    data = [1, 2, 3; 4, 5, 6];
    d1.write_all(data);
    assert(isequal(d1.read_all(), data));
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getDataArray = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);

    assert(isempty(getDataArray.sources));
    getDataArray.add_source(getSource.sources{1}.id);
    getDataArray.add_source(getSource.sources{2});
    assert(size(getDataArray.sources, 1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getDataArray = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);

    getDataArray.add_source(getSource.sources{1}.id);
    getDataArray.add_source(getSource.sources{2});

    assert(getDataArray.remove_source(getSource.sources{2}));
    assert(getDataArray.remove_source(getSource.sources{1}.id));
    assert(isempty(getDataArray.sources));

    assert(getDataArray.remove_source('I do not exist'));
    assert(size(getSource.sources, 1) == 2);
end
