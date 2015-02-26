function funcs = TestTag
%TESTTag tests for Tag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_list_fetch_references;
    funcs{end+1} = @test_list_fetch_sources;
    funcs{end+1} = @test_list_fetch_features;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_feature;
    funcs{end+1} = @test_open_reference;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
end

%% Test: List/fetch references
function [] = test_list_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    assert(size(getTag.list_references(), 1) == 1);
    assert(size(getTag.references(), 1) == 1);
end

%% Test: List/fetch sources
function [] = test_list_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.list_sources(),1) == 0);
    disp('Test Tag: list sources from tag ... TODO (proper testfile)');

    assert(size(getTag.sources(),1) == 0);
    disp('Test Tag: fetch sources ... TODO (proper testfile)');
end


%% Test: List/fetch features
function [] = test_list_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.list_features(),1) == 0);
    disp('Test Tag: list features ... TODO (proper testfile)');

    assert(size(getTag.features(),1) == 0);
    disp('Test Tag: fetch features ... TODO (proper testfile)');
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with source referenced from a tag
    %getSourceByID = getTag.open_source(getTag.sources{1,1}.id);
    %assert(strcmp(getSourceByID.id, ''));
    disp('Test Tag: open source by ID ... TODO (proper testfile)');

    %getSourceByName = getTag.open_source(getTag.sources{1,1}.name);
    %assert(strcmp(getSourceByName.id, ''));
    disp('Test Tag: open source by name ... TODO (proper testfile)');
    
    %-- test open non existing source
    getSource = getTag.open_source('I dont exist');
    assert(isempty(getSource));
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
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    getRefByID = getTag.open_reference(getTag.references{1,1}.id);
    assert(strcmp(getRefByID.id, '75138768-edc3-482e-894d-301f1dd66f8d'));

    getRefByName = getTag.open_reference(getTag.references{1,1}.name);
    assert(strcmp(getRefByName.id, '75138768-edc3-482e-894d-301f1dd66f8d'));
    
    %-- test open non existing source
    getRef = getTag.open_reference('I dont exist');
    assert(isempty(getRef));
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
