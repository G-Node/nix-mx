% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestFile
% TESTFILE tests for File

    funcs = {};
    funcs{end+1} = @testReadOnly;
    funcs{end+1} = @testReadWrite;
    funcs{end+1} = @testOverwrite;
    funcs{end+1} = @testIsOpen;
    funcs{end+1} = @testFileMode;
    funcs{end+1} = @testValidate;
    funcs{end+1} = @testCreateBlock;
    funcs{end+1} = @testBlockCount;
    funcs{end+1} = @testCreateSection;
    funcs{end+1} = @testSectionCount;
    funcs{end+1} = @testFetchBlock;
    funcs{end+1} = @testFetchSection;
    funcs{end+1} = @testOpenSection;
    funcs{end+1} = @testOpenSectionIdx;
    funcs{end+1} = @testOpenBlock;
    funcs{end+1} = @testOpenBlockIdx;
    funcs{end+1} = @testDeleteBlock;
    funcs{end+1} = @testDeleteSection;
    funcs{end+1} = @testHasBlock;
    funcs{end+1} = @testHasSection;
    funcs{end+1} = @testFilterSection;
    funcs{end+1} = @testFilterBlock;
    funcs{end+1} = @testFindSection;
    funcs{end+1} = @testFindSectionFiltered;
end

%% Test: Open HDF5 file in ReadOnly mode
function [] = testReadOnly( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
end

%% Test: Open HDF5 file in ReadWrite mode
function [] = testReadWrite( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadWrite);
end

%% Test: Open HDF5 file in Overwrite mode
function [] = testOverwrite( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
end

%% Test: File is open
function [] = testIsOpen( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadOnly);
    assert(f.isOpen());
end

%% Test: File mode
function [] = testFileMode( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.fileMode() == nix.FileMode.ReadOnly);

    clear f;
    f = nix.File(testFile, nix.FileMode.ReadWrite);
    assert(f.fileMode() == nix.FileMode.ReadWrite);

    clear f;
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(f.fileMode() == nix.FileMode.Overwrite);
end

%% Test: Validate
function [] = testValidate( varargin )
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
function [] = testCreateBlock( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testBlock 1';
    b = f.createBlock(useName, 'testType 1');
    assert(strcmp(b.name(), useName));
end

%% Test: Block Count
function [] = testBlockCount( varargin )
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
function [] = testCreateSection( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = f.createSection(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
end

%% Test: Section Count
function [] = testSectionCount( varargin )
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
function [] = testFetchBlock( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    blockName = 'blockName';
    blockType = 'testBlock';
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(isempty(f.blocks));

    b1 = f.createBlock(strcat(blockName, '1'), blockType);
    assert(size(f.blocks, 1) == 1);

    checkFile = f;
    b2 = f.createBlock(strcat(blockName, '2'), blockType);
    assert(size(f.blocks, 1) == 2);
    assert(size(checkFile.blocks, 1) == 2);

    clear b2 b1 checkFile f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks, 1) == 2);
end

%% Test: Fetch Block
function [] = testFetchSection( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    sectionName = 'sectionName';
    sectionType = 'testSection';
    f = nix.File(testFile, nix.FileMode.Overwrite);
    assert(isempty(f.sections));

    s1 = f.createSection(strcat(sectionName, '1'), sectionType);
    assert(size(f.sections, 1) == 1);

    checkFile = f;
    s2 = f.createSection(strcat(sectionName, '2'), sectionType);
    assert(size(f.sections, 1) == 2);
    assert(size(checkFile.sections, 1) == 2);

    clear s2 s1 checkFile f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.sections, 1) == 2);
end

%% Test: Delete Block
function [] = testDeleteBlock( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testBlock 1';
    newBlock = f.createBlock(useName, 'testType 1');
    assert(strcmp(newBlock.name(), useName));
    
    %-- test delete block by object
    checkDelete = f.deleteBlock(f.blocks{1});
    assert(checkDelete);
    assert(size(f.blocks, 1) == 0);
    
    %-- test delete block by id
    newBlock = f.createBlock('name', 'type');
    checkDelete = f.deleteBlock(newBlock.id);
    assert(checkDelete);
    assert(size(f.blocks, 1) == 0);

    %-- test delete non existing block
    checkDelete = f.deleteBlock('I do not exist');
    assert(~checkDelete);
end

%% Test: Delete Section
function [] = testDeleteSection( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    useName = 'testSection 1';
    newSection = f.createSection(useName, 'testType 1');
    assert(strcmp(newSection.name(), useName));
    
    %-- test delete section by object
    checkDelete = f.deleteSection(f.sections{1});
    assert(checkDelete);
    assert(size(f.sections, 1) == 0);
    
    %-- test delete section by id
    newSection = f.createSection('name', 'type');
    checkDelete = f.deleteSection(newSection.id);
    assert(checkDelete);
    assert(size(f.sections, 1) == 0);

    %-- test delete non existing section
    checkDelete = f.deleteSection('I do not exist');
    assert(~checkDelete);
end

function [] = testOpenSection( varargin )
%% Test open section
    f = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = f.openSection(f.sections{1,1}.id);
    assert(strcmp(getSection.name, 'General'));
    
    %-- test open non existing section
    getSection = f.openSection('I dont exist');
    assert(isempty(getSection));
end

function [] = testOpenSectionIdx( varargin )
%% Test Open Section by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s1 = f.createSection('testSection1', 'nixSection');
    s2 = f.createSection('testSection2', 'nixSection');
    s3 = f.createSection('testSection3', 'nixSection');

    assert(strcmp(f.openSectionIdx(1).name, s1.name));
    assert(strcmp(f.openSectionIdx(2).name, s2.name));
    assert(strcmp(f.openSectionIdx(3).name, s3.name));
end

function [] = testOpenBlock( varargin )
%% Test Open Block by ID or name
    f = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    getBlockByID = f.openBlock(f.blocks{1,1}.id);
    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));

    getBlockByName = f.openBlock(f.blocks{1,1}.name);
    assert(strcmp(getBlockByName.name, 'joe097'));

    %-- test open non existing block
    getBlock = f.openBlock('I dont exist');
    assert(isempty(getBlock));
end

function [] = testOpenBlockIdx( varargin )
%% Test Open Block by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    b3 = f.createBlock('testBlock3', 'nixBlock');

    assert(strcmp(f.openBlockIdx(1).name, b1.name));
    assert(strcmp(f.openBlockIdx(2).name, b2.name));
    assert(strcmp(f.openBlockIdx(3).name, b3.name));
end

%% Test: nix.File has nix.Block by ID or name
function [] = testHasBlock( varargin )
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
function [] = testHasSection( varargin )
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

function [] = testFilterSection( varargin )
%% Test: filter Sections
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);

    s = f.createSection(filterName, 'nixSection');
    filterID = s.id;
	s = f.createSection('testSection1', filterType);
    filterIDs = {filterID, s.id};
    s = f.createSection('testSection2', filterType);

    % ToDO add basic filter crash tests
    
    % test empty id filter
    assert(isempty(f.filterSections(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.filterSections(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.filterSections(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.filterSections(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.filterSections(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.filterSections(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);
    
    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.filterSections(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end
    
    % test fail on nix.Filter.source
    try
        f.filterSections(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end

end

function [] = testFilterBlock( varargin )
%% Test: filter Blocks
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);

    b = f.createBlock(filterName, 'nixBlock');
    filterID = b.id;
	b = f.createBlock('testBlock1', filterType);
    filterIDs = {filterID, b.id};
    b = f.createBlock('testBlock2', filterType);

    % ToDO add basic filter crash tests
    
    % test empty id filter
    assert(isempty(f.filterBlocks(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.filterBlocks(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.filterBlocks(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.filterBlocks(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.filterBlocks(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.filterBlocks(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);
    
    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.filterBlocks(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end
    
    % test fail on nix.Filter.source
    try
        f.filterBlocks(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end

end

%% Test: Find sections w/o filter
function [] = testFindSection
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    sl1 = f.createSection('sectionLvl1', 'nixSection');

    sl21 = sl1.createSection('sectionLvl2_1', 'nixSection');
    sl22 = sl1.createSection('sectionLvl2_2', 'nixSection');

    sl31 = sl21.createSection('sectionLvl3_1', 'nixSection');
    sl32 = sl21.createSection('sectionLvl3_2', 'nixSection');
    sl33 = sl21.createSection('sectionLvl3_3', 'nixSection');

    sl41 = sl31.createSection('sectionLvl4_1', 'nixSection');
    sl42 = sl31.createSection('sectionLvl4_2', 'nixSection');
    sl43 = sl31.createSection('sectionLvl4_3', 'nixSection');
    sl44 = sl31.createSection('sectionLvl4_4', 'nixSection');

    % Check invalid entry
    err = 'Provide a valid search depth';
    try
        f.findSections('hurra');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % find all
    filtered = f.findSections(5);
    assert(size(filtered, 1) == 10);

    % find until level 4
    filtered = f.findSections(4);
    assert(size(filtered, 1) == 10);

    % find until level 3
    filtered = f.findSections(3);
    assert(size(filtered, 1) == 6);

    % find until level 2
    filtered = f.findSections(2);
    assert(size(filtered, 1) == 3);

    % find until level 1
    filtered = f.findSections(1);
    assert(size(filtered, 1) == 1);
end

%% Test: Find sections with filter
function [] = testFindSectionFiltered
    findSection = 'nixFindSection';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    sl1 = f.createSection('sectionLvl1', 'nixSection');

    sl21 = sl1.createSection('sectionLvl2_1', 'nixSection');
    sl22 = sl1.createSection('sectionLvl2_2', findSection);

    sl31 = sl21.createSection('sectionLvl3_1', 'nixSection');
    sl32 = sl21.createSection('sectionLvl3_2', 'nixSection');
    sl33 = sl21.createSection('sectionLvl3_3', findSection);

    sl41 = sl31.createSection('sectionLvl4_1', 'nixSection');
    sl42 = sl31.createSection('sectionLvl4_2', 'nixSection');
    sl43 = sl31.createSection('sectionLvl4_3', findSection);
    sl44 = sl31.createSection('sectionLvl4_4', 'nixSection');

    % test find by id
    filtered = f.filterFindSections(1, nix.Filter.id, sl41.id);
    assert(isempty(filtered));
    filtered = f.filterFindSections(4, nix.Filter.id, sl41.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl41.id));

    % test find by ids
    filterids = {sl1.id, sl41.id};
    filtered = f.filterFindSections(1, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 1);
    filtered = f.filterFindSections(4, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 2);

    % test find by name
    filtered = f.filterFindSections(1, nix.Filter.name, sl41.name);
    assert(isempty(filtered));
    filtered = f.filterFindSections(4, nix.Filter.name, sl41.name);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, sl41.name));

    % test find by type
    filtered = f.filterFindSections(1, nix.Filter.type, findSection);
    assert(isempty(filtered));
    filtered = f.filterFindSections(4, nix.Filter.type, findSection);
    assert(size(filtered, 1) == 3);
    assert(strcmp(filtered{1}.type, findSection));

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.filterFindSections(1, nix.Filter.metadata, 'metadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        f.filterFindSections(1, nix.Filter.source, 'source');
    catch ME
        assert(strcmp(ME.message, err));
    end
end
