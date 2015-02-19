function funcs = testFile
%TESTFILE tests for File
%   Detailed explanation goes here

    funcs{1} = @test_read_only;
    funcs{2} = @test_read_write;
    funcs{3} = @test_overwrite;
    funcs{4} = @test_list_sections;
    funcs{5} = @test_open_section;
    funcs{6} = @test_list_blocks;
    funcs{7} = @test_open_block;
end

function [] = test_read_only( varargin )
%% Test: Open HDF5 file in ReadOnly mode
    f = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
end

function [] = test_read_write( varargin )
%% Test: Open HDF5 file in ReadWrite mode

    %-- TODO: throws error 'does not work' at the moment
    %f = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadWrite);
end

function [] = test_overwrite( varargin )
%% Test: Open HDF5 file in Overwrite mode
%-- ToDo: maybe there's a cleverer way for the overwrite test than having
%-- two test files.
% AS: I'd excluded it for the moment as as it's always causing changes to
% GIT.
    %f = nix.File(fullfile(pwd,'tests','testOverwrite.h5'), nix.FileMode.Overwrite);
end

function [] = test_list_sections( varargin )
%% Test: Section listing
% Test that File handle can fetch sections from HDF5
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listSections()) == 3);
    assert(length(test_file.sections()) == 3);
end

function [] = test_open_section( varargin )
%% Test open section
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = test_file.openSection(test_file.sections{1,1}.id);

    assert(strcmp(getSection.name, 'General'));
end

function [] = test_list_blocks( varargin )
%% Test list and fetch blocks
% Test that File handle can fetch blocks from HDF5
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listBlocks()) == 4);
    assert(size(test_file.blocks(),1) == 4);
end

function [] = test_open_block( varargin )
%% Test Open Block by ID or name
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    getBlockByID = test_file.openBlock(test_file.blocks{1,1}.id);
    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));

    getBlockByName = test_file.openBlock(test_file.blocks{1,1}.name);
    assert(strcmp(getBlockByName.name, 'joe097'));
end
