function funcs = TestTag
%TESTTag tests for Tag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_add_reference;
    funcs{end+1} = @test_remove_reference;
    funcs{end+1} = @test_fetch_references;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_fetch_features;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_feature;
    funcs{end+1} = @test_open_reference;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourceTest', 'nixBlock');
    getSource = getBlock.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('sourcetest', 'nixTag', position);
    
    assert(isempty(getTag.sources));
    getTag.add_source(getSource.sources{1}.id);
    getTag.add_source(getSource.sources{2});
    assert(size(getTag.sources,1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('test', 'nixBlock');
    getSource = getBlock.create_source('test', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('sourcetest', 'nixTag', position);
    getTag.add_source(getSource.sources{1}.id);
    getTag.add_source(getSource.sources{2});

    assert(size(getTag.sources,1) == 2);
    getTag.remove_source(getSource.sources{2});
    assert(size(getTag.sources,1) == 1);
    getTag.remove_source(getSource.sources{1}.id);
    assert(isempty(getTag.sources));
    assert(getTag.remove_source('I do not exist'));
    assert(size(getSource.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = test_add_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = getBlock.create_data_array('referenceTest1', 'nixDataArray', 'double', [1 2]);
    tmp = getBlock.create_data_array('referenceTest2', 'nixDataArray', 'double', [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    
    assert(isempty(getTag.references));
    getTag.add_reference(getBlock.dataArrays{1}.id);
    getTag.add_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 2);
end

%% Test: Remove references by entity and id
function [] = test_remove_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixBlock');
    getRefDA1 = getBlock.create_data_array('referenceTest1', 'nixDataArray', 'double', [1 2]);
    getRefDA2 = getBlock.create_data_array('referenceTest2', 'nixDataArray', 'double', [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    getTag.add_reference(getBlock.dataArrays{1}.id);
    getTag.add_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 2);

    getTag.remove_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 1);
    getTag.remove_reference(getBlock.dataArrays{1}.id);
    assert(isempty(getTag.references));
    assert(~getTag.remove_reference('I do not exist'));
    assert(size(getBlock.dataArrays, 1) == 2);
end

%% Test: fetch references
function [] = test_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = getBlock.create_data_array('referenceTest1', 'nixDataArray', 'double', [1 2]);
    tmp = getBlock.create_data_array('referenceTest2', 'nixDataArray', 'double', [3 4]);
    tmp = getBlock.create_data_array('referenceTest3', 'nixDataArray', 'double', [5 6]);
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    
    getTag.add_reference(getBlock.dataArrays{1});
    getTag.add_reference(getBlock.dataArrays{2});
    getTag.add_reference(getBlock.dataArrays{3});
    assert(size(getTag.references, 1) == 3);
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('test', 'nixBlock');
    getSource = getBlock.create_source('test','nixSource');
    tmp = getSource.create_source('nestedsource1', 'nixSource');
    tmp = getSource.create_source('nestedsource2', 'nixSource');
    tmp = getSource.create_source('nestedsource3', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('tagtest', 'nixTag', position);
    
    getTag.add_source(getSource.sources{1});
    getTag.add_source(getSource.sources{2});
    getTag.add_source(getSource.sources{3});
    assert(size(getTag.sources, 1) == 3);
end


%% Test: fetch features
function [] = test_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.features(),1) == 0);
    disp('Test Tag: fetch features ... TODO (proper testfile)');
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('test', 'nixBlock');
    getSource = getBlock.create_source('test', 'nixSource');
    sourceName = 'nestedsource';
    createSource = getSource.create_source(sourceName, 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('tagtest', 'nixTag', position);
    getTag.add_source(getSource.sources{1});

    getSourceByID = getTag.open_source(createSource.id);
    assert(~isempty(getSourceByID));
    
    getSourceByName = getTag.open_source(sourceName);
	assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getNonSource = getTag.open_source('I dont exist');
    assert(isempty(getNonSource));
end


%% Test: Open feature by ID or name
function [] = test_open_feature( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with feature referenced from a tag
    %getFeatByID = getTag.open_feature(getTag.features{1,1}.id);
    %assert(strcmp(getFeatByID.id, ''));
    disp('Test Tag: open feature by ID ... TODO (proper testfile)');

    %getFeatByName = getTag.open_feature(getTag.features{1,1}.name);
    %assert(strcmp(getFeatByName.id, ''));
    disp('Test Tag: open feature by name ... TODO (proper testfile)');
    
    %-- test open non existing feature
    getFeat = getTag.open_feature('I dont exist');
    assert(isempty(getFeat));
end


%% Test: Open reference by ID or name
function [] = test_open_reference( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = getBlock.create_data_array('referenceTest', 'nixDataArray', 'double', [1 2]);
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    getTag.add_reference(getBlock.dataArrays{1});

    getRefByID = getTag.open_reference(getTag.references{1,1}.id);
    assert(~isempty(getRefByID));
    
    getRefByName = getTag.open_reference(getTag.references{1,1}.name);
    assert(~isempty(getRefByName));
    
    %-- test open non existing source
    getNonRef = getTag.open_reference('I dont exist');
    assert(isempty(getNonRef));
end


%% Test: Open metadata
function [] = test_open_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    assert(isempty(getTag.open_metadata()))
    
    getTag = getBlock.open_tag(getBlock.tags{2,1}.id);
    assert(~isempty(getTag.open_metadata()));
end

%% Test: Retrieve data
function [] = test_retrieve_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    tag = b.tags{1};
    
    data = tag.retrieve_data(1);
    assert(~isempty(data));
end

%% Test: Retrieve feature data
function [] = test_retrieve_feature_data( varargin )
    % TODO
    disp('Test Tag: retrieve feature ... TODO (proper testfile)');
end
