% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestSource
%TESTSOURCE tests for Source
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_create_source;
    funcs{end+1} = @test_delete_source;
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_has_source;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_source_idx;
    funcs{end+1} = @test_source_count;
    funcs{end+1} = @test_parent_source;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_referring_data_arrays;
    funcs{end+1} = @test_referring_tags;
    funcs{end+1} = @test_referring_multi_tags;
    funcs{end+1} = @test_compare;
    funcs{end+1} = @test_filter_source;
    funcs{end+1} = @test_find_source;
    funcs{end+1} = @test_find_source_filtered;
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    s = b.createSource('sourcetest', 'nixSource');

    assert(isempty(s.sources));
    assert(isempty(f.blocks{1}.sources{1}.sources));
    tmp = s.create_source('nestedsource1', 'nixSource');
    assert(size(s.sources, 1) == 1);
    assert(size(f.blocks{1}.sources{1}.sources, 1) == 1);
    tmp = s.create_source('nestedsource2', 'nixSource');
    assert(size(s.sources, 1) == 2);
    assert(size(f.blocks{1}.sources{1}.sources, 1) == 2);
    
    clear tmp s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.sources{1}.sources, 1) == 2);
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    s = b.createSource('sourcetest', 'nixSource');
    assert(isempty(s.sources));

    sourceName = 'nestedsource';
    createSource = s.create_source(sourceName, 'nixSource');
    getSourceByID = s.open_source(createSource.id);
    assert(~isempty(getSourceByID));

    getSourceByName = s.open_source(sourceName);
    assert(~isempty(getSourceByName));

    %-- test open non existing source
    getNonSource = s.open_source('I dont exist');
    assert(isempty(getNonSource));
end

function [] = test_open_source_idx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');
    s1 = s.create_source('testSource1', 'nixSource');
    s2 = s.create_source('testSource2', 'nixSource');
    s3 = s.create_source('testSource3', 'nixSource');

    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(3).name, s3.name));
end

%% Test: Source count
function [] = test_source_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');

    assert(s.source_count() == 0);
    s.create_source('testSource1', 'nixSource');
    assert(s.source_count() == 1);
    s.create_source('testSource2', 'nixSource');

    clear s b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.sources{1}.source_count() == 2);
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection('testSection1', 'nixSection');
    tmp = f.createSection('testSection2', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');

    assert(isempty(s.open_metadata));
    assert(isempty(f.blocks{1}.sources{1}.open_metadata));

    s.set_metadata(f.sections{1});
    assert(strcmp(s.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.sources{1}.open_metadata.name, secName1));

    s.set_metadata(f.sections{2});
    assert(strcmp(s.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.sources{1}.open_metadata.name, secName2));

    s.set_metadata('');
    assert(isempty(s.open_metadata));
    assert(isempty(f.blocks{1}.sources{1}.open_metadata));

	s.set_metadata(f.sections{2});
    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.sources{1}.open_metadata.name, secName2));
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');
    s.set_metadata(f.sections{1});

    assert(strcmp(s.open_metadata.name, 'testSection'));
end

%% Test: create source
function [] = test_create_source ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    s = b.createSource('sourcetest', 'nixSource');
    assert(isempty(s.sources));

    createSource = s.create_source('nestedsource', 'nixSource');
    assert(~isempty(s.sources));
    assert(strcmp(createSource.name, 'nestedsource'));
    assert(strcmp(createSource.type, 'nixSource'));
end

%% Test: delete source
function [] = test_delete_source( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    s = b.createSource('sourcetest', 'nixSource');
    assert(isempty(s.sources));

    tmp = s.create_source('nestedsource1', 'nixSource');
    tmp = s.create_source('nestedsource2', 'nixSource');
    assert(s.delete_source('nestedsource1'));
    assert(s.delete_source(s.sources{1}.id));
    assert(~s.delete_source('I do not exist'));
    assert(isempty(s.sources));
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'test nixBlock');
    s = b.createSource('sourcetest', 'test nixSource');

    assert(~isempty(s.id));
    assert(strcmp(s.name, 'sourcetest'));
    assert(strcmp(s.type, 'test nixSource'));
    
    s.type = 'nixSource';
    assert(strcmp(s.type, 'nixSource'));
    
    assert(isempty(s.definition));
    s.definition = 'source definition';
    assert(strcmp(s.definition, 'source definition'));

    s.definition = '';
    assert(isempty(s.definition));
end

%% Test: nix.Source has nix.Source by ID or name
function [] = test_has_source( varargin )
    fileName = 'testRW.h5';
    sName = 'nestedsource';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    s = b.createSource('sourcetest', 'nixSource');
    nested = s.create_source(sName, 'nixSource');
    nestedID = nested.id;

    assert(~s.has_source('I do not exist'));
    assert(s.has_source(sName));

    clear nested s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.sources{1}.has_source(nestedID));
end

%% Test: Get parent source
function [] = test_parent_source( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    sourceName1 = 'testSource1';
    sourceName2 = 'testSource2';
    s1 = b.createSource(sourceName1, 'nixSource');
    s2 = s1.create_source(sourceName2, 'nixSource');
    s3 = s2.create_source('testSource3', 'nixSource');

    assert(strcmp(s3.parent_source.name, sourceName2));
    assert(strcmp(s2.parent_source.name, sourceName1));
end

%% Test: Referring data arrays
function [] = test_referring_data_arrays( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');

    assert(isempty(s.referring_data_arrays));

    d1 = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    d1.add_source(s);
    assert(~isempty(s.referring_data_arrays));
    assert(strcmp(s.referring_data_arrays{1}.name, d1.name));

    d2 = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    d2.add_source(s);
    assert(size(s.referring_data_arrays, 1) == 2);
end

%% Test: Referring tags
function [] = test_referring_tags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('testSource', 'nixSource');

    assert(isempty(s.referring_tags));

    t1 = b.createTag('testTag1', 'nixTag', [1, 2]);
    t1.add_source(s);
    assert(~isempty(s.referring_tags));
    assert(strcmp(s.referring_tags{1}.name, t1.name));

    t2 = b.createTag('testTag2', 'nixTag', [1, 2]);
    t2.add_source(s);
    assert(size(s.referring_tags, 1) == 2);
end

%% Test: Referring multi tags
function [] = test_referring_multi_tags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.createSource('testSource', 'nixSource');

    assert(isempty(s.referring_multi_tags));

    t1 = b.createMultiTag('testMultiTag1', 'nixMultiTag', d);
    t1.add_source(s);
    assert(~isempty(s.referring_multi_tags));
    assert(strcmp(s.referring_multi_tags{1}.name, t1.name));

    t2 = b.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    t2.add_source(s);
    assert(size(s.referring_multi_tags, 1) == 2);
end

function [] = test_compare( varargin )
%% Test: Compare Source entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    s1 = b1.createSource('testSource1', 'nixSource');
    s2 = b1.createSource('testSource2', 'nixSource');
    s3 = b2.createSource('testSource1', 'nixSource');

    assert(s1.compare(s2) < 0);
    assert(s1.compare(s1) == 0);
    assert(s2.compare(s1) > 0);
    assert(s1.compare(s3) ~= 0);
end

%% Test: filter sources
function [] = test_filter_source( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    ms = b.createSource('testSource', 'nixSource');
    s = ms.create_source(filterName, 'nixSource');
    filterID = s.id;
	s = ms.create_source('testSource1', filterType);
    filterIDs = {filterID, s.id};
    s = ms.create_source('testSource2', filterType);

    % test empty id filter
    assert(isempty(f.blocks{1}.sources{1}.filter_sources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.sources{1}.filter_sources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = ms.create_source(mainName, 'nixSource');
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.sources{1}.filter_sources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = ms.create_source(mainName, 'nixSource');
    mainID = main.id;
    subName = 'testSubSource1';
    s = main.create_source(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.sources{1}.filter_sources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.sources{1}.filter_sources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: Find source w/o filter
function [] = test_find_source
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('mainSource', 'nixSource');
    sl1 = s.create_source('sourceLvl1', 'nixSource');

    sl21 = sl1.create_source('sourceLvl2_1', 'nixSource');
    sl22 = sl1.create_source('sourceLvl2_2', 'nixSource');

    sl31 = sl21.create_source('sourceLvl3_1', 'nixSource');
    sl32 = sl21.create_source('sourceLvl3_2', 'nixSource');
    sl33 = sl21.create_source('sourceLvl3_3', 'nixSource');

    sl41 = sl31.create_source('sourceLvl4_1', 'nixSource');
    sl42 = sl31.create_source('sourceLvl4_2', 'nixSource');
    sl43 = sl31.create_source('sourceLvl4_3', 'nixSource');
    sl44 = sl31.create_source('sourceLvl4_4', 'nixSource');

    % Check invalid entry
    err = 'Provide a valid search depth';
    try
        s.find_sources('hurra');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % find all
    filtered = s.find_sources(5);
    assert(size(filtered, 1) == 11);

    % find until level 3
    filtered = s.find_sources(4);
    assert(size(filtered, 1) == 7);

    % find until level 2
    filtered = s.find_sources(3);
    assert(size(filtered, 1) == 4);

    % find until level 1
    filtered = s.find_sources(2);
    assert(size(filtered, 1) == 2);

    % find until level 0
    filtered = s.find_sources(1);
    assert(size(filtered, 1) == 1);
end

%% Test: Find sources with filters
function [] = test_find_source_filtered
    findSource = 'nixFindSource';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource('mainSource', 'nixSource');
    sl1 = s.create_source('sourceLvl1', 'nixSource');

    sl21 = sl1.create_source('sourceLvl2_1', 'nixSource');
    sl22 = sl1.create_source('sourceLvl2_2', findSource);

    sl31 = sl21.create_source('sourceLvl3_1', findSource);
    sl32 = sl21.create_source('sourceLvl3_2', 'nixSource');
    sl33 = sl21.create_source('sourceLvl3_3', 'nixSource');

    sl41 = sl31.create_source('sourceLvl4_1', 'nixSource');
    sl42 = sl31.create_source('sourceLvl4_2', 'nixSource');
    sl43 = sl31.create_source('sourceLvl4_3', findSource);
    sl44 = sl31.create_source('sourceLvl4_4', 'nixSource');

    % test find by id
    filtered = s.find_filtered_sources(1, nix.Filter.id, sl41.id);
    assert(isempty(filtered));
    filtered = s.find_filtered_sources(5, nix.Filter.id, sl41.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl41.id));

    % test find by ids
    filterids = {sl1.id, sl41.id};
    filtered = s.find_filtered_sources(2, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 1);
    filtered = s.find_filtered_sources(5, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 2);

    % test find by name
    filtered = s.find_filtered_sources(1, nix.Filter.name, sl41.name);
    assert(isempty(filtered));
    filtered = s.find_filtered_sources(5, nix.Filter.name, sl41.name);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, sl41.name));

    % test find by type
    filtered = s.find_filtered_sources(1, nix.Filter.type, findSource);
    assert(isempty(filtered));
    filtered = s.find_filtered_sources(5, nix.Filter.type, findSource);
    assert(size(filtered, 1) == 3);
    assert(strcmp(filtered{1}.type, findSource));

    % test nix.Filter.metadata
    sec = f.createSection('testSection', 'nixSection');
    sl43.set_metadata(sec);
    filtered = s.find_filtered_sources(1, nix.Filter.metadata, sec.id);
    assert(isempty(filtered));
    filtered = s.find_filtered_sources(5, nix.Filter.metadata, sec.id);
    assert(size(filtered, 1) == 1);
    strcmp(filtered{1}.id, sl43.id);

    % test nix.Filter.source
    filtered = s.find_filtered_sources(1, nix.Filter.source, sl44.id);
    assert(isempty(filtered));
    filtered = s.find_filtered_sources(5, nix.Filter.source, sl44.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl31.id));
end
