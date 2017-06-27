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
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('sourcetest', 'nixBlock');
    s = b.create_source('sourcetest', 'nixSource');

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

    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.create_block('sourcetest', 'nixBlock');
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

function [] = test_open_source_idx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');
    s1 = s.create_source('testSource1', 'nixSource');
    s2 = s.create_source('testSource2', 'nixSource');
    s3 = s.create_source('testSource3', 'nixSource');

    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(0).name, s1.name));
    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(1).name, s2.name));
    assert(strcmp(f.blocks{1}.sources{1}.open_source_idx(2).name, s3.name));
end

%% Test: Source count
function [] = test_source_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');

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
    tmp = f.create_section('testSection1', 'nixSection');
    tmp = f.create_section('testSection2', 'nixSection');
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');

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
    tmp = f.create_section('testSection', 'nixSection');
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');
    s.set_metadata(f.sections{1});

    assert(strcmp(s.open_metadata.name, 'testSection'));
end

%% Test: create source
function [] = test_create_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.create_block('sourcetest', 'nixBlock');
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
    getBlock = test_file.create_block('sourcetest', 'nixBlock');
    getSource = getBlock.create_source('sourcetest', 'nixSource');
    assert(isempty(getSource.sources));

    tmp = getSource.create_source('nestedsource1', 'nixSource');
    tmp = getSource.create_source('nestedsource2', 'nixSource');
    assert(getSource.delete_source('nestedsource1'));
    assert(getSource.delete_source(getSource.sources{1}.id));
    assert(~getSource.delete_source('I do not exist'));
    assert(isempty(getSource.sources));
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'test nixBlock');
    s = b.create_source('sourcetest', 'test nixSource');

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
    b = f.create_block('testblock', 'nixBlock');
    s = b.create_source('sourcetest', 'nixSource');
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
    b = f.create_block('sourcetest', 'nixBlock');
    sourceName1 = 'testSource1';
    sourceName2 = 'testSource2';
    s1 = b.create_source(sourceName1, 'nixSource');
    s2 = s1.create_source(sourceName2, 'nixSource');
    s3 = s2.create_source('testSource3', 'nixSource');

    assert(strcmp(s3.parent_source.name, sourceName2));
    assert(strcmp(s2.parent_source.name, sourceName1));
end

%% Test: Referring data arrays
function [] = test_referring_data_arrays( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');

    assert(isempty(s.referring_data_arrays));

    d1 = b.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    d1.add_source(s);
    assert(~isempty(s.referring_data_arrays));
    assert(strcmp(s.referring_data_arrays{1}.name, d1.name));

    d2 = b.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    d2.add_source(s);
    assert(size(s.referring_data_arrays, 1) == 2);
end

%% Test: Referring tags
function [] = test_referring_tags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source('testSource', 'nixSource');

    assert(isempty(s.referring_tags));

    t1 = b.create_tag('testTag1', 'nixTag', [1, 2]);
    t1.add_source(s);
    assert(~isempty(s.referring_tags));
    assert(strcmp(s.referring_tags{1}.name, t1.name));

    t2 = b.create_tag('testTag2', 'nixTag', [1, 2]);
    t2.add_source(s);
    assert(size(s.referring_tags, 1) == 2);
end

%% Test: Referring multi tags
function [] = test_referring_multi_tags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.create_source('testSource', 'nixSource');

    assert(isempty(s.referring_multi_tags));

    t1 = b.create_multi_tag('testMultiTag1', 'nixMultiTag', d);
    t1.add_source(s);
    assert(~isempty(s.referring_multi_tags));
    assert(strcmp(s.referring_multi_tags{1}.name, t1.name));

    t2 = b.create_multi_tag('testMultiTag2', 'nixMultiTag', d);
    t2.add_source(s);
    assert(size(s.referring_multi_tags, 1) == 2);
end

function [] = test_compare( varargin )
%% Test: Compare Source entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    b2 = f.create_block('testBlock2', 'nixBlock');
    s1 = b1.create_source('testSource1', 'nixSource');
    s2 = b1.create_source('testSource2', 'nixSource');
    s3 = b2.create_source('testSource1', 'nixSource');

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
    b = f.create_block('testBlock', 'nixBlock');
    ms = b.create_source('testSource', 'nixSource');
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
    s = f.create_section(subName, 'nixSection');
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
