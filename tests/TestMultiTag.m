function funcs = TestMultiTag
%TESTMultiTag tests for MultiTag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_list_fetch_references;
    funcs{end+1} = @test_list_fetch_sources;
    funcs{end+1} = @test_list_fetch_features;
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

%% Test: List/fetch references
function [] = test_list_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    assert(size(getMultiTag.references(), 1) == 1);
end

%% Test: List/fetch sources
function [] = test_list_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    assert(size(getMultiTag.sources(),1) == 1);
end

%% Test: List/fetch features
function [] = test_list_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getMultiTag.features(),1) == 0);
    disp('Test MultiTag: fetch features ... TODO (proper testfile)');
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    getSourceByID = getMultiTag.open_source(getMultiTag.sources{1,1}.id);
    assert(strcmp(getSourceByID.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));

    getSourceByName = getMultiTag.open_source(getMultiTag.sources{1,1}.name);
    assert(strcmp(getSourceByName.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    
    %-- test open non existing source
    getSource = getMultiTag.open_source('I dont exist');
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
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    getRefByID = getMultiTag.open_reference(getMultiTag.references{1,1}.id);
    assert(strcmp(getRefByID.id, 'd21318e2-151e-4afd-afd3-1d86c8c20a85'));

    getRefByName = getMultiTag.open_reference(getMultiTag.references{1,1}.name);
    assert(strcmp(getRefByName.id, 'd21318e2-151e-4afd-afd3-1d86c8c20a85'));
    
    %-- test open non existing reference
    getRef = getMultiTag.open_reference('I dont exist');
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
