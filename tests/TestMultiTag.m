function funcs = TestMultiTag
%TESTMultiTag tests for MultiTag
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
    funcs{end+1} = @test_has_positions;
    funcs{end+1} = @test_open_positions;
    funcs{end+1} = @test_open_extents;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

	assert(isempty(getMTag.sources));
	getMTag.add_source(getSource.sources{1}.id);
	getMTag.add_source(getSource.sources{2});
	assert(size(getMTag.sources, 1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

	getMTag.add_source(getSource.sources{1}.id);
	getMTag.add_source(getSource.sources{2});

	getMTag.remove_source(getSource.sources{2});
	assert(size(getMTag.sources,1) == 1);
	getMTag.remove_source(getSource.sources{1}.id);
	assert(isempty(getMTag.sources));
	assert(getMTag.remove_source('I do not exist'));
	assert(size(getSource.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = test_add_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);

	assert(isempty(getMTag.references));
	getMTag.add_reference(b.dataArrays{2}.id);
	getMTag.add_reference(b.dataArrays{3});
	assert(size(getMTag.references, 1) == 2);
end

%% Test: Remove references by entity and id
function [] = test_remove_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);
	getMTag.add_reference(b.dataArrays{2}.id);
	getMTag.add_reference(b.dataArrays{3});

	assert(getMTag.remove_reference(b.dataArrays{3}));
	assert(getMTag.remove_reference(b.dataArrays{2}.id));
	assert(isempty(getMTag.references));

	assert(~getMTag.remove_reference('I do not exist'));
	assert(size(b.dataArrays, 1) == 3);
end

%% Test: fetch references
function [] = test_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);
	getMTag.add_reference(b.dataArrays{2}.id);
	getMTag.add_reference(b.dataArrays{3});

    assert(size(getMTag.references, 1) == 2);
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
	getMTag.add_source(getSource.sources{1}.id);
	getMTag.add_source(getSource.sources{2});

    assert(size(getMTag.sources, 1) == 2);
end

%% Test: fetch features
function [] = test_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getMultiTag.features(), 1) == 0);
    disp('Test MultiTag: fetch features ... TODO (proper testfile)');
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    sName = 'nestedSource';
    tmp = getSource.create_source(sName, 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
	getMTag.add_source(getSource.sources{1});

    getSourceByID = getMTag.open_source(getMTag.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = getMTag.open_source(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = getMTag.open_source('I do not exist');
    assert(isempty(getSource));
end

%% Test: Open feature by ID or name
function [] = test_open_feature( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    %-- TODO: implement testfile with feature referenced from a tag
    %getFeatByID = getMultiTag.open_feature(getMultiTag.features{1,1}.id);
    %assert(strcmp(getFeatByID.id, ''));
    disp('Test MultiTag: open feature by ID ... TODO (proper testfile)');

    %getFeatByName = getTag.open_feature(getTag.features{1,1}.name);
    %assert(strcmp(getFeatByName.id, ''));
    disp('Test MultiTag: open feature by name ... TODO (proper testfile)');
    
    %-- test open non existing feature
    getFeat = getMultiTag.open_feature('I dont exist');
    assert(isempty(getFeat));
end

%% Test: Open reference by ID or name
function [] = test_open_reference( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    refName = 'referenceTest';
    tmp = b.create_data_array(refName, 'nixDataArray', 'double', [3 4]);
	getMTag.add_reference(b.dataArrays{2}.id);

    getRefByID = getMTag.open_reference(getMTag.references{1,1}.id);
    assert(~isempty(getRefByID));

    getRefByName = getMTag.open_reference(refName);
    assert(~isempty(getRefByName));

    %-- test open non existing reference
    getRef = getMTag.open_reference('I do not exist');
    assert(isempty(getRef));
end

%% Test: Has positions
function [] = test_has_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    %-- ToDo implement test for non existing positions
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    %assert(~getMultiTag.hasPositions);
    disp('Test MultiTag: has no existing positions ... TODO (proper testfile)');
   
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(getMultiTag.has_positions);
end

%% Test: Open positions
function [] = test_open_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    %-- ToDo implement test for non existing positions
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    %assert(isempty(getMultiTag.open_positions));
    disp('Test MultiTag: open non existing positions ... TODO (proper testfile)');
   
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(~isempty(getMultiTag.open_positions));
end

%% Test: Open extents
function [] = test_open_extents( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(isempty(getMultiTag.open_extents));
   
    %-- ToDo implement test for existing extents
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    %assert(~isempty(getMultiTag.open_positions));
    disp('Test MultiTag: open existing extents ... TODO (proper testfile)');
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(isempty(getMultiTag.open_metadata()))
    
    %-- ToDo implement test for existing metadata
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{2,1}.id);
    %assert(~isempty(getMultiTag.open_metadata()));
    disp('Test MultiTag: open existing metadata ... TODO (proper testfile)');
end

%% Test: Retrieve data
function [] = test_retrieve_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    tag = b.multiTags{1};
    
    data = tag.retrieve_data(1, 1);
    assert(~isempty(data));
end

%% Test: Retrieve feature data
function [] = test_retrieve_feature_data( varargin )
    % TODO
    disp('Test MultiTag: retrieve feature ... TODO (proper testfile)');
end
