function funcs = testTag
%TESTTag tests for Tag
%   Detailed explanation goes here

    funcs{1} = @test_list_fetch_references;
    funcs{2} = @test_list_fetch_sources;
    funcs{3} = @test_list_fetch_features;
    funcs{4} = @test_open_source;
    funcs{5} = @test_open_feature;
    funcs{6} = @test_open_reference;
    funcs{7} = @test_has_metadata;
    funcs{8} = @test_open_metadata;
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
end


%% Test: Has metadata
function [] = test_has_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    assert(~getTag.has_metadata());
    
    getTag = getBlock.open_tag(getBlock.tags{2,1}.id);
    assert(getTag.has_metadata());
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

