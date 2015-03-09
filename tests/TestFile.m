function funcs = testFile
%TESTFILE tests for File
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_read_only;
    funcs{end+1} = @test_read_write;
    funcs{end+1} = @test_overwrite;
    funcs{end+1} = @test_create_block;
    funcs{end+1} = @test_create_section;
    funcs{end+1} = @test_list_sections;
    funcs{end+1} = @test_open_section;
    funcs{end+1} = @test_list_blocks;
    funcs{end+1} = @test_open_block;
    funcs{end+1} = @test_delete_block;
    funcs{end+1} = @test_delete_section;

end

%% Test: Open HDF5 file in ReadOnly mode
function [] = test_read_only( varargin )
    f = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
end

%% Test: Open HDF5 file in ReadWrite mode
function [] = test_read_write( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.ReadWrite);
end

%% Test: Open HDF5 file in Overwrite mode
function [] = test_overwrite( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
end

%% Test: Create Block
function [] = test_create_block( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.ReadWrite);
    useName = 'testBlock 1';
    newBlock = test_file.createBlock(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
end

%% Test: Create Section
function [] = test_create_section( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.ReadWrite);
    useName = 'testSection 1';
    newSection = test_file.createSection(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
end

%% Test: Delete Block
function [] = test_delete_block( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.ReadWrite);

    %-- test delete block by object
    checkDelete = test_file.deleteBlock(test_file.blocks{1});
    assert(checkDelete);
    assert(size(test_file.blocks, 1) == 0);
    
    %-- test delete block by id
    newBlock = test_file.createBlock('name', 'type');
    checkDelete = test_file.deleteBlock(newBlock.id);
    assert(checkDelete);
    assert(size(test_file.blocks, 1) == 0);

    %-- test delete non existing block
    checkDelete = test_file.deleteBlock('I do not exist');
    assert(~checkDelete);
end

%% Test: Delete Section
function [] = test_delete_section( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.ReadWrite);
    
    %-- test delete section by object
    checkDelete = test_file.deleteSection(test_file.sections{1});
    assert(checkDelete);
    assert(size(test_file.sections, 1) == 0);
    
    %-- test delete section by id
    newSection = test_file.createSection('name', 'type');
    checkDelete = test_file.deleteSection(newSection.id);
    assert(checkDelete);
    assert(size(test_file.sections, 1) == 0);

    %-- test delete non existing section
    checkDelete = test_file.deleteSection('I do not exist');
    assert(~checkDelete);
end

function [] = test_list_sections( varargin )
%% Test: Section listing
% Test that File handle can fetch sections from HDF5
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.sections()) == 3);
end

function [] = test_open_section( varargin )
%% Test open section
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = test_file.openSection(test_file.sections{1,1}.id);
    assert(strcmp(getSection.name, 'General'));
    
    %-- test open non existing section
    getSection = test_file.openSection('I dont exist');
    assert(isempty(getSection));
end

function [] = test_list_blocks( varargin )
%% Test list and fetch blocks
% Test that File handle can fetch blocks from HDF5
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(size(test_file.blocks(),1) == 4);
end

function [] = test_open_block( varargin )
%% Test Open Block by ID or name
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    getBlockByID = test_file.openBlock(test_file.blocks{1,1}.id);
    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));

    getBlockByName = test_file.openBlock(test_file.blocks{1,1}.name);
    assert(strcmp(getBlockByName.name, 'joe097'));

    %-- test open non existing block
    getBlock = test_file.openBlock('I dont exist');
    assert(isempty(getBlock));
end
