function funcs = testSource
%TESTSOURCE tests for Source
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_create_source;
    funcs{end+1} = @test_delete_source;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_metadata;
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixBlock');
    getSource = getBlock.create_source('sourcetest', 'nixSource');
    tmp = getSource.create_source('nestedsource1', 'nixSource');
    tmp = getSource.create_source('nestedsource2', 'nixSource');
    
    assert(size(getSource.sources, 1) == 2);
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )

    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixBlock');
    getSource = getBlock.create_source('sourcetest', 'nixSource');
    assert(isempty(getSource.sources));

    sourceName = 'nestedsource';
    createSource = getSource.create_source(sourceName, 'nixSource');
    getSourceByID = getSource.open_source(createSource.id);
    assert(~isempty(getSourceByID));

    getSourceByName = getSource.open_source(sourceName);
    assert(~isempty(getSourceByName));

    %-- test open non existing source
    getNonSource = getSource.open_source('I dont exist');
    assert(isempty(getNonSource));
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    assert(isempty(getSource.open_metadata()))
    
    %-- ToDo implement test for empty metadata
    %getSource = getBlock.open_source(getBlock.sources{1,1}.id);
    %assert(~isempty(getSource.open_metadata()))
    disp('Test Source: open existing metadata ... TODO (proper testfile)');
end

%% Test: create source
function [] = test_create_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixBlock');
    getSource = getBlock.create_source('sourcetest', 'nixSource');
    assert(isempty(getSource.sources));

    createSource = getSource.create_source('nestedsource', 'nixSource');
    assert(~isempty(getSource.sources));
    assert(strcmp(createSource.name, 'nestedsource'));
    assert(strcmp(createSource.type, 'nixSource'));
end

%% Test: delete source
function [] = test_delete_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixBlock');
    getSource = getBlock.create_source('sourcetest', 'nixSource');
    assert(isempty(getSource.sources));

    tmp = getSource.create_source('nestedsource1', 'nixSource');
    tmp = getSource.create_source('nestedsource2', 'nixSource');
    assert(getSource.delete_source('nestedsource1'));
    assert(getSource.delete_source(getSource.sources{1}.id));
    assert(~getSource.delete_source('I do not exist'));
    assert(isempty(getSource.sources));
end
