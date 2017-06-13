% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestFile
%TESTFILE tests for File
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_read_only;
    funcs{end+1} = @test_read_write;
    funcs{end+1} = @test_overwrite;
    funcs{end+1} = @test_create_block;
    funcs{end+1} = @test_block_count;
    funcs{end+1} = @test_create_section;
    funcs{end+1} = @test_section_count;
    funcs{end+1} = @test_fetch_block;
    funcs{end+1} = @test_fetch_section;
    funcs{end+1} = @test_open_section;
    funcs{end+1} = @test_open_block;
    funcs{end+1} = @test_delete_block;
    funcs{end+1} = @test_delete_section;
    funcs{end+1} = @test_has_block;
    funcs{end+1} = @test_has_section;
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
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testBlock 1';
    newBlock = test_file.createBlock(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
end

%% Test: Block Count
function [] = test_block_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.blockCount() == 0);
    b = f.createBlock('testBlock 1', 'testType 1');
    assert(f.blockCount() == 1);
    b = f.createBlock('testBlock 2', 'testType 2');

    clear b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blockCount() == 2);
end

%% Test: Create Section
function [] = test_create_section( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = test_file.createSection(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
end

%% Test: Section Count
function [] = test_section_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.sectionCount() == 0);
    b = f.createSection('testSection 1', 'testType 1');
    assert(f.sectionCount() == 1);
    b = f.createSection('testSection 2', 'testType 2');

    clear b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sectionCount() == 2);
end

%% Test: Fetch Block
function [] = test_fetch_block( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    blockName = 'blockName';
    blockType = 'testBlock';
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(isempty(f.blocks));

    b1 = f.createBlock(strcat(blockName, '1'), blockType);
    assert(size(f.blocks, 1) == 1);

    check_file = f;
    b2 = f.createBlock(strcat(blockName, '2'), blockType);
    assert(size(f.blocks, 1) == 2);
    assert(size(check_file.blocks, 1) == 2);

    clear b2 b1 check_file f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks, 1) == 2);
end

%% Test: Fetch Block
function [] = test_fetch_section( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    sectionName = 'sectionName';
    sectionType = 'testSection';
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(isempty(f.sections));

    s1 = f.createSection(strcat(sectionName, '1'), sectionType);
    assert(size(f.sections, 1) == 1);

    check_file = f;
    s2 = f.createSection(strcat(sectionName, '2'), sectionType);
    assert(size(f.sections, 1) == 2);
    assert(size(check_file.sections, 1) == 2);

    clear s2 s1 check_file f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.sections, 1) == 2);
end

%% Test: Delete Block
function [] = test_delete_block( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testBlock 1';
    newBlock = test_file.createBlock(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
    
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
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = test_file.createSection(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
    
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

function [] = test_open_section( varargin )
%% Test open section
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = test_file.openSection(test_file.sections{1,1}.id);
    assert(strcmp(getSection.name, 'General'));
    
    %-- test open non existing section
    getSection = test_file.openSection('I dont exist');
    assert(isempty(getSection));
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

%% Test: nix.File has nix.Block by ID or name
function [] = test_has_block( varargin )
    fileName = 'testRW.h5';
    blockName = 'hasBlockTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock(blockName, 'nixBlock');
    bID = b.id;

    assert(~f.hasBlock('I do not exist'));
    assert(f.hasBlock(blockName));

    clear b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.hasBlock(bID));
end

%% Test: nix.File has nix.Section by ID or name
function [] = test_has_section( varargin )
    fileName = 'testRW.h5';
    secName = 'hasSectionTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    s = f.createSection(secName, 'nixSection');
    sID = s.id;

    assert(~f.hasSection('I do not exist'));
    assert(f.hasSection(secName));

    clear s f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.hasSection(sID));
end
