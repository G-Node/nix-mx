function funcs = TestMultiTag
%TESTMultiTag tests for MultiTag
%   Detailed explanation goes here

    funcs{1} = @test_list_fetch_references;
    funcs{2} = @test_list_fetch_sources;
    funcs{3} = @test_list_fetch_features;
    funcs{4} = @test_open_source;
    funcs{5} = @test_open_feature;
    funcs{6} = @test_open_reference;
    funcs{7} = @test_has_metadata;
    funcs{8} = @test_open_metadata;
    funcs{9} = @test_retrieve_data;
    funcs{10} = @test_retrieve_feature_data;
end

%% Test: List/fetch references
function [] = test_list_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    assert(size(getMultiTag.list_references(), 1) == 1);
    assert(size(getMultiTag.references(), 1) == 1);
end

%% Test: List/fetch sources
function [] = test_list_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    assert(size(getMultiTag.list_sources(),1) == 1);
    assert(size(getMultiTag.sources(),1) == 1);
end

%% Test: List/fetch features
function [] = test_list_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getMultiTag.list_features(),1) == 0);
    disp('Test MultiTag: list features ... TODO (proper testfile)');

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
end

%% Test: Has metadata
function [] = test_has_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(~getMultiTag.has_metadata());
   
    %-- ToDo implement test for existing metadata
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{2,1}.id);
    %assert(getMultiTag.has_metadata());
    disp('Test MultiTag: has existing metadata ... TODO (proper testfile)');
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
