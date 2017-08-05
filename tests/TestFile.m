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
    funcs{end+1} = @test_is_open;
    funcs{end+1} = @test_file_mode;
    funcs{end+1} = @test_validate;
    funcs{end+1} = @test_create_block;
    funcs{end+1} = @test_block_count;
    funcs{end+1} = @test_create_section;
    funcs{end+1} = @test_section_count;
    funcs{end+1} = @test_fetch_block;
    funcs{end+1} = @test_fetch_section;
    funcs{end+1} = @test_open_section;
    funcs{end+1} = @test_open_section_idx;
    funcs{end+1} = @test_open_block;
    funcs{end+1} = @test_open_block_idx;
    funcs{end+1} = @test_delete_block;
    funcs{end+1} = @test_delete_section;
    funcs{end+1} = @test_has_block;
    funcs{end+1} = @test_has_section;
    funcs{end+1} = @test_filter_section;
    funcs{end+1} = @test_filter_block;
    funcs{end+1} = @test_find_section;
    funcs{end+1} = @test_find_section_filtered;
end

%% Test: Open HDF5 file in ReadOnly mode
function [] = test_read_only( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
end

%% Test: Open HDF5 file in ReadWrite mode
function [] = test_read_write( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadWrite);
end

%% Test: Open HDF5 file in Overwrite mode
function [] = test_overwrite( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
end

%% Test: File is open
function [] = test_is_open( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadOnly);
    assert(f.is_open());
end

%% Test: File mode
function [] = test_file_mode( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.file_mode() == nix.FileMode.ReadOnly);

    clear f;
    f = nix.File(testFile, nix.FileMode.ReadWrite);
    assert(f.file_mode() == nix.FileMode.ReadWrite);

    clear f;
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.file_mode() == nix.FileMode.Overwrite);
end

%% Test: Validate
function [] = test_validate( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    validation = f.validate();

    assert(validation.ok());
    assert(~validation.hasErrors());
    assert(~validation.hasWarnings());
    assert(~size(validation.errors, 1));
    assert(~size(validation.warnings, 1));
end

%% Test: Create Block
function [] = test_create_block( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testBlock 1';
    newBlock = test_file.create_block(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
end

%% Test: Block Count
function [] = test_block_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.block_count() == 0);
    b = f.create_block('testBlock 1', 'testType 1');
    assert(f.block_count() == 1);
    b = f.create_block('testBlock 2', 'testType 2');

    clear b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.block_count() == 2);
end

%% Test: Create Section
function [] = test_create_section( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = test_file.create_section(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
end

%% Test: Section Count
function [] = test_section_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.section_count() == 0);
    b = f.create_section('testSection 1', 'testType 1');
    assert(f.section_count() == 1);
    b = f.create_section('testSection 2', 'testType 2');

    clear b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.section_count() == 2);
end

%% Test: Fetch Block
function [] = test_fetch_block( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    blockName = 'blockName';
    blockType = 'testBlock';
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(isempty(f.blocks));

    b1 = f.create_block(strcat(blockName, '1'), blockType);
    assert(size(f.blocks, 1) == 1);

    check_file = f;
    b2 = f.create_block(strcat(blockName, '2'), blockType);
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

    s1 = f.create_section(strcat(sectionName, '1'), sectionType);
    assert(size(f.sections, 1) == 1);

    check_file = f;
    s2 = f.create_section(strcat(sectionName, '2'), sectionType);
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
    newBlock = test_file.create_block(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
    
    %-- test delete block by object
    checkDelete = test_file.delete_block(test_file.blocks{1});
    assert(checkDelete);
    assert(size(test_file.blocks, 1) == 0);
    
    %-- test delete block by id
    newBlock = test_file.create_block('name', 'type');
    checkDelete = test_file.delete_block(newBlock.id);
    assert(checkDelete);
    assert(size(test_file.blocks, 1) == 0);

    %-- test delete non existing block
    checkDelete = test_file.delete_block('I do not exist');
    assert(~checkDelete);
end

%% Test: Delete Section
function [] = test_delete_section( varargin )
    test_file = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = test_file.create_section(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
    
    %-- test delete section by object
    checkDelete = test_file.delete_section(test_file.sections{1});
    assert(checkDelete);
    assert(size(test_file.sections, 1) == 0);
    
    %-- test delete section by id
    newSection = test_file.create_section('name', 'type');
    checkDelete = test_file.delete_section(newSection.id);
    assert(checkDelete);
    assert(size(test_file.sections, 1) == 0);

    %-- test delete non existing section
    checkDelete = test_file.delete_section('I do not exist');
    assert(~checkDelete);
end

function [] = test_open_section( varargin )
%% Test open section
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = test_file.open_section(test_file.sections{1,1}.id);
    assert(strcmp(getSection.name, 'General'));
    
    %-- test open non existing section
    getSection = test_file.open_section('I dont exist');
    assert(isempty(getSection));
end

function [] = test_open_section_idx( varargin )
%% Test Open Section by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s1 = f.create_section('testSection1', 'nixSection');
    s2 = f.create_section('testSection2', 'nixSection');
    s3 = f.create_section('testSection3', 'nixSection');

    assert(strcmp(f.open_section_idx(1).name, s1.name));
    assert(strcmp(f.open_section_idx(2).name, s2.name));
    assert(strcmp(f.open_section_idx(3).name, s3.name));
end

function [] = test_open_block( varargin )
%% Test Open Block by ID or name
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    getBlockByID = test_file.open_block(test_file.blocks{1,1}.id);
    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));

    getBlockByName = test_file.open_block(test_file.blocks{1,1}.name);
    assert(strcmp(getBlockByName.name, 'joe097'));

    %-- test open non existing block
    getBlock = test_file.open_block('I dont exist');
    assert(isempty(getBlock));
end

function [] = test_open_block_idx( varargin )
%% Test Open Block by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    b2 = f.create_block('testBlock2', 'nixBlock');
    b3 = f.create_block('testBlock3', 'nixBlock');

    assert(strcmp(f.open_block_idx(1).name, b1.name));
    assert(strcmp(f.open_block_idx(2).name, b2.name));
    assert(strcmp(f.open_block_idx(3).name, b3.name));
end

%% Test: nix.File has nix.Block by ID or name
function [] = test_has_block( varargin )
    fileName = 'testRW.h5';
    blockName = 'has_blockTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block(blockName, 'nixBlock');
    bID = b.id;

    assert(~f.has_block('I do not exist'));
    assert(f.has_block(blockName));

    clear b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.has_block(bID));
end

%% Test: nix.File has nix.Section by ID or name
function [] = test_has_section( varargin )
    fileName = 'testRW.h5';
    secName = 'has_sectionTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    s = f.create_section(secName, 'nixSection');
    sID = s.id;

    assert(~f.has_section('I do not exist'));
    assert(f.has_section(secName));

    clear s f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.has_section(sID));
end

function [] = test_filter_section( varargin )
%% Test: filter Sections
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);

    s = f.create_section(filterName, 'nixSection');
    filterID = s.id;
	s = f.create_section('testSection1', filterType);
    filterIDs = {filterID, s.id};
    s = f.create_section('testSection2', filterType);

    % ToDO add basic filter crash tests
    
    % test empty id filter
    assert(isempty(f.filter_sections(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.filter_sections(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.filter_sections(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.filter_sections(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.filter_sections(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.filter_sections(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);
    
    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.filter_sections(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end
    
    % test fail on nix.Filter.source
    try
        f.filter_sections(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end

end

function [] = test_filter_block( varargin )
%% Test: filter Blocks
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);

    b = f.create_block(filterName, 'nixBlock');
    filterID = b.id;
	b = f.create_block('testBlock1', filterType);
    filterIDs = {filterID, b.id};
    b = f.create_block('testBlock2', filterType);

    % ToDO add basic filter crash tests
    
    % test empty id filter
    assert(isempty(f.filter_blocks(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.filter_blocks(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.filter_blocks(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.filter_blocks(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.filter_blocks(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.filter_blocks(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);
    
    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.filter_blocks(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end
    
    % test fail on nix.Filter.source
    try
        f.filter_blocks(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end

end

%% Test: Find sections w/o filter
function [] = test_find_section
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    sl1 = f.create_section('sectionLvl1', 'nixSection');

    sl21 = sl1.create_section('sectionLvl2_1', 'nixSection');
    sl22 = sl1.create_section('sectionLvl2_2', 'nixSection');

    sl31 = sl21.create_section('sectionLvl3_1', 'nixSection');
    sl32 = sl21.create_section('sectionLvl3_2', 'nixSection');
    sl33 = sl21.create_section('sectionLvl3_3', 'nixSection');

    sl41 = sl31.create_section('sectionLvl4_1', 'nixSection');
    sl42 = sl31.create_section('sectionLvl4_2', 'nixSection');
    sl43 = sl31.create_section('sectionLvl4_3', 'nixSection');
    sl44 = sl31.create_section('sectionLvl4_4', 'nixSection');

    % Check invalid entry
    err = 'Provide a valid search depth';
    try
        f.find_sections('hurra');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % find all
    filtered = f.find_sections(5);
    assert(size(filtered, 1) == 10);

    % find until level 4
    filtered = f.find_sections(4);
    assert(size(filtered, 1) == 10);

    % find until level 3
    filtered = f.find_sections(3);
    assert(size(filtered, 1) == 6);

    % find until level 2
    filtered = f.find_sections(2);
    assert(size(filtered, 1) == 3);

    % find until level 1
    filtered = f.find_sections(1);
    assert(size(filtered, 1) == 1);
end

%% Test: Find sections with filter
function [] = test_find_section_filtered
    findSection = 'nixFindSection';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    sl1 = f.create_section('sectionLvl1', 'nixSection');

    sl21 = sl1.create_section('sectionLvl2_1', 'nixSection');
    sl22 = sl1.create_section('sectionLvl2_2', findSection);

    sl31 = sl21.create_section('sectionLvl3_1', 'nixSection');
    sl32 = sl21.create_section('sectionLvl3_2', 'nixSection');
    sl33 = sl21.create_section('sectionLvl3_3', findSection);

    sl41 = sl31.create_section('sectionLvl4_1', 'nixSection');
    sl42 = sl31.create_section('sectionLvl4_2', 'nixSection');
    sl43 = sl31.create_section('sectionLvl4_3', findSection);
    sl44 = sl31.create_section('sectionLvl4_4', 'nixSection');

    % test find by id
    filtered = f.find_filtered_sections(1, nix.Filter.id, sl41.id);
    assert(isempty(filtered));
    filtered = f.find_filtered_sections(4, nix.Filter.id, sl41.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl41.id));

    % test find by ids
    filterids = {sl1.id, sl41.id};
    filtered = f.find_filtered_sections(1, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 1);
    filtered = f.find_filtered_sections(4, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 2);

    % test find by name
    filtered = f.find_filtered_sections(1, nix.Filter.name, sl41.name);
    assert(isempty(filtered));
    filtered = f.find_filtered_sections(4, nix.Filter.name, sl41.name);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, sl41.name));

    % test find by type
    filtered = f.find_filtered_sections(1, nix.Filter.type, findSection);
    assert(isempty(filtered));
    filtered = f.find_filtered_sections(4, nix.Filter.type, findSection);
    assert(size(filtered, 1) == 3);
    assert(strcmp(filtered{1}.type, findSection));

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.find_filtered_sections(1, nix.Filter.metadata, 'metadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        f.find_filtered_sections(1, nix.Filter.source, 'source');
    catch ME
        assert(strcmp(ME.message, err));
    end
end
