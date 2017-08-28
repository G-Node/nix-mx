% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestBlock
%TESTFILE Tests for the nix.Block object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testCreateDataArray;
    funcs{end+1} = @testCreateDataArrayFromData;
    funcs{end+1} = @testDeleteDataArray;
    funcs{end+1} = @testCreateTag;
    funcs{end+1} = @testDeleteTag;
    funcs{end+1} = @testCreateMultiTag;
    funcs{end+1} = @testDeleteMultiTag;
    funcs{end+1} = @testCreateSource;
    funcs{end+1} = @testDeleteSource;
    funcs{end+1} = @testListArrays;
    funcs{end+1} = @testListSources;
    funcs{end+1} = @testListTags;
    funcs{end+1} = @testListMultiTags;
    funcs{end+1} = @testOpenDataArray;
    funcs{end+1} = @testOpenTag;
    funcs{end+1} = @testOpenMultiTag;
    funcs{end+1} = @testOpenSource;
    funcs{end+1} = @testOpenGroupIdx;
    funcs{end+1} = @testOpenDataArrayIdx;
    funcs{end+1} = @testOpenTagIdx;
    funcs{end+1} = @testOpenMultiTagIdx;
    funcs{end+1} = @testOpenSourceIdx;
    funcs{end+1} = @testHasDataArray;
    funcs{end+1} = @testHasSource;
    funcs{end+1} = @testHasMultiTag;
    funcs{end+1} = @testHasTag;
    funcs{end+1} = @testSetMetadata;
    funcs{end+1} = @testOpenMetadata;
    funcs{end+1} = @testCreateGroup;
    funcs{end+1} = @testHasGroup;
    funcs{end+1} = @testOpenGroup;
    funcs{end+1} = @testDeleteGroup;
    funcs{end+1} = @testGroupCount;
    funcs{end+1} = @testDataArrayCount;
    funcs{end+1} = @testTagCount;
    funcs{end+1} = @testMultiTagCount;
    funcs{end+1} = @testSourceCount;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSource;
    funcs{end+1} = @testFilterGroup;
    funcs{end+1} = @testFilterTag;
    funcs{end+1} = @testFilterMultiTag;
    funcs{end+1} = @testFilterDataArray;
    funcs{end+1} = @testFindSource;
    funcs{end+1} = @testFindSourceFiltered;
end

function [] = testAttributes( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'test nixBlock');

    assert(~isempty(b.id));
    assert(strcmp(b.name, 'tagtest'));
    assert(strcmp(b.type, 'test nixBlock'));
    
    b.type = 'nixBlock';
    assert(strcmp(b.type, 'nixBlock'));
    
    assert(isempty(b.definition));
    b.definition = 'block definition';
    assert(strcmp(b.definition, 'block definition'));

    b.definition = '';
    assert(isempty(b.definition));
end

%% Test: Create Data Array
function [] = testCreateDataArray( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    dtype = 'nix.DataArray';
    doubleName = 'doubleDataArray';
    da = b.createDataArray(doubleName, dtype, nix.DataType.Double, [2 3]);
    assert(strcmp(da.name, doubleName));
    assert(strcmp(da.type, dtype));
    tmp = da.readAllData();
    assert(all(tmp(:) == 0));

    try
        b.createDataArray('stringDataArray', dtype, nix.DataType.String, [1 5]);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:UnsupportedDataType'));
    end;
    
    try
        b.createDataArray('I will crash and burn', dtype, 'Thou shalt not work!', [1 5]);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:UnsupportedDataType'));
    end;

    da = b.createDataArray('floatDataArray', dtype, nix.DataType.Float, [3 3]);
    da = b.createDataArray('Int8DataArray', dtype, nix.DataType.Int8, [3 3]);
    da = b.createDataArray('Int16DataArray', dtype, nix.DataType.Int16, [3 3]);
    da = b.createDataArray('Int32DataArray', dtype, nix.DataType.Int32, [3 3]);
    da = b.createDataArray('Int64DataArray', dtype, nix.DataType.Int64, [3 3]);
    da = b.createDataArray('UInt8DataArray', dtype, nix.DataType.UInt8, [3 3]);
    da = b.createDataArray('UInt16DataArray', dtype, nix.DataType.UInt16, [3 3]);
    da = b.createDataArray('UInt32DataArray', dtype, nix.DataType.UInt32, [3 3]);
    da = b.createDataArray('UInt64DataArray', dtype, nix.DataType.UInt64, [3 3]);
    da = b.createDataArray('logicalArray', dtype, nix.DataType.Bool, [3 3]);
    
    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 11);
end

%% Test: Create Data Array from data
function [] = testCreateDataArrayFromData( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    daType = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    numName = 'numDataArray';
    numData = [1, 2, 3; 4, 5, 6];
    da = b.createDataArrayFromData(numName, daType, numData);
    assert(strcmp(da.name, numName));
    assert(strcmp(da.type, daType));
    
    tmp = da.readAllData();
    assert(strcmp(class(tmp), class(numData)));
    assert(isequal(size(tmp), size(numData)));
    assert(isequal(tmp, numData));
    
    logName = 'logicalDataArray';
    logData = logical([1 0 1; 0 1 0; 1 0 1]);
    da = b.createDataArrayFromData(logName, daType, logData);
    assert(islogical(da.readAllData));
    assert(isequal(size(da.readAllData), size(logData)));
    assert(isequal(da.readAllData, logData));
    
    try
        b.createDataArrayFromData('stringDataArray', daType, ['a' 'b']);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:UnsupportedDataType'));
    end;
    
    try
        b.createDataArrayFromData('I will crash and burn', daType, {1 2 3});
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:UnsupportedDataType'));
    end;
    
    assert(~isempty(b.dataArrays));
end

%% Test: delete dataArray by entity and id
function [] = testDeleteDataArray( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');
    tmp = b.createDataArray('dataArrayTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('dataArrayTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    
    assert(size(b.dataArrays, 1) == 2);
    assert(b.deleteDataArray(b.dataArrays{2}.id));
    assert(size(b.dataArrays, 1) == 1);
    assert(b.deleteDataArray(b.dataArrays{1}));
    assert(isempty(b.dataArrays));
    assert(~b.deleteDataArray('I do not exist'));
end

function [] = testCreateTag( varargin )
%% Test: Create Tag
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixblock');
    
    assert(isempty(b.tags));

    position = [1.0 1.2 1.3 15.9];
    t1 = b.createTag('foo', 'bar', position);
    assert(strcmp(t1.name, 'foo'));
    assert(strcmp(t1.type, 'bar'));
    assert(isequal(t1.position, position));
    
    assert(~isempty(b.tags));
end

%% Test: delete tag by entity and id
function [] = testDeleteTag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tmp = b.createTag('tagtest1', 'nixTag', position);
    tmp = b.createTag('tagtest2', 'nixTag', position);
    
    assert(size(b.tags, 1) == 2);
    assert(b.deleteTag(b.tags{2}.id));
    assert(size(b.tags, 1) == 1);
    assert(b.deleteTag(b.tags{1}));
    assert(isempty(b.tags));

    assert(~b.deleteTag('I do not exist'));
end

function [] = testCreateMultiTag( varargin )
%% Test: Create multitag by DataArray entity and DataArray id
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.createDataArray('mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    assert(isempty(b.multiTags));

    %-- create by DataArray entity
    tmp = b.createMultiTag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    assert(~isempty(b.multiTags));
    assert(strcmp(b.multiTags{1}.name, 'mTagTest1'));

    %-- create by DataArray id
    tmp = b.createMultiTag('mTagTest2', 'nixMultiTag2', b.dataArrays{2}.id);
    assert(size(b.multiTags, 1) == 2);
    assert(strcmp(b.multiTags{2}.type, 'nixMultiTag2'));
end

%% Test: delete multitag by entity and id
function [] = testDeleteMultiTag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.createDataArray('mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createMultiTag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    tmp = b.createMultiTag('mTagTest2', 'nixMultiTag2', b.dataArrays{1});

    assert(size(b.multiTags, 1) == 2);
    assert(b.deleteMultiTag(b.multiTags{2}.id));
    assert(size(b.multiTags, 1) == 1);
    assert(b.deleteMultiTag(b.multiTags{1}));
    assert(isempty(b.multiTags));
    assert(size(b.dataArrays, 1) == 1);

    assert(~b.deleteMultiTag('I do not exist'));
end

%% Test: create source
function [] = testCreateSource ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixblock');
    assert(isempty(b.sources));

    s = b.createSource('sourcetest','nixsource');
    assert(~isempty(b.sources));
    assert(strcmp(s.name, 'sourcetest'));
    assert(strcmp(s.type, 'nixsource'));
end

%% Test: delete source by entity and id
function [] = testDeleteSource( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixblock');
    tmp = b.createSource('sourcetest1','nixsource');
    tmp = b.createSource('sourcetest2','nixsource');
    tmp = b.createSource('sourcetest3','nixsource');

    assert(b.deleteSource('sourcetest1'));
    assert(b.deleteSource(b.sources{1}.id));
    assert(b.deleteSource(b.sources{1}));
    assert(isempty(b.sources));
    
    assert(~b.deleteSource('I do not exist'));
end

%% Test: Fetch nix.DataArrays
function [] = testListArrays( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');

    assert(isempty(b.dataArrays));
    tmp = b.createDataArray('arrayTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('arrayTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    assert(size(b.dataArrays, 1) == 2);
    assert(size(f.blocks{1}.dataArrays, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 2);
end

%% Test: Fetch nix.Sources
function [] = testListSources( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');

    assert(isempty(b.sources));
    tmp = b.createSource('sourcetest1','nixSource');
    assert(size(b.sources, 1) == 1);
    assert(size(f.blocks{1}.sources, 1) == 1);
    tmp = b.createSource('sourcetest2','nixSource');
    assert(size(b.sources, 1) == 2);
    assert(size(f.blocks{1}.sources, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.sources, 1) == 2);
end

%% Test: Fetch nix.Tags
function [] = testListTags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];

    assert(isempty(b.tags));
    tmp = b.createTag('tagtest1', 'nixTag', position);
    assert(size(b.tags, 1) == 1);
    assert(size(f.blocks{1}.tags, 1) == 1);
    tmp = b.createTag('tagtest2', 'nixTag', position);
    assert(size(b.tags, 1) == 2);
    assert(size(f.blocks{1}.tags, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags, 1) == 2);
end

%% Test: fetch multitags
function [] = testListMultiTags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.createDataArray('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(b.multiTags));
    tmp = b.createMultiTag('mTagTest1', 'nixMultiTag', b.dataArrays{1});
    assert(size(b.multiTags, 1) == 1);
    assert(size(f.blocks{1}.multiTags, 1) == 1);
    tmp = b.createMultiTag('mTagTest2', 'nixMultiTag', b.dataArrays{1});
    assert(size(b.multiTags, 1) == 2);
    assert(size(f.blocks{1}.multiTags, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags, 1) == 2);
end

function [] = testOpenDataArray( varargin )
%% Test: Open data array by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');
    daName = 'arrayTest1';
    
    assert(isempty(b.dataArrays));
    tmp = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [1 2]);

    getDataArrayByID = b.openDataArray(b.dataArrays{1,1}.id);
    assert(~isempty(getDataArrayByID));

    getDataArrayByName = b.openDataArray(daName);
    assert(~isempty(getDataArrayByName));
    
    %-- test open non existing dataarray
    getDataArray = b.openDataArray('I do not exist');
    assert(isempty(getDataArray));
end

function [] = testOpenTag( varargin )
%% Test: Open tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tagName = 'tagtest1';
    tmp = b.createTag(tagName, 'nixTag', position);

    getTagByID = b.openTag(b.tags{1,1}.id);
    assert(~isempty(getTagByID));

    getTagByName = b.openTag(tagName);
    assert(~isempty(getTagByName));
    
    %-- test open non existing tag
    getTag = b.openTag('I do not exist');
    assert(isempty(getTag));
end

function [] = testOpenMultiTag( varargin )
%% Test: Open multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.createDataArray('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    mTagName = 'mTagTest1';
    tmp = b.createMultiTag(mTagName, 'nixMultiTag', b.dataArrays{1});

    getMultiTagByID = b.openMultiTag(b.multiTags{1,1}.id);
    assert(~isempty(getMultiTagByID));

    getMultiTagByName = b.openMultiTag(mTagName);
    assert(~isempty(getMultiTagByName));
    
    %-- test open non existing multitag
    getMultiTag = b.openMultiTag('I do not exist');
    assert(isempty(getMultiTag));
end

function [] = testOpenSource( varargin )
%% Test: Open source by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    sName = 'sourcetest1';
    tmp = b.createSource(sName, 'nixSource');
    
    getSourceByID = b.openSource(b.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = b.openSource(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = b.openSource('I do not exist');
    assert(isempty(getSource));
end

function [] = testOpenGroupIdx( varargin )
%% Test Open Group by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g1 = b.createGroup('testGroup1', 'nixGroup');
    g2 = b.createGroup('testGroup2', 'nixGroup');
    g3 = b.createGroup('testGroup3', 'nixGroup');

    assert(strcmp(f.blocks{1}.openGroupIdx(1).name, g1.name));
    assert(strcmp(f.blocks{1}.openGroupIdx(2).name, g2.name));
    assert(strcmp(f.blocks{1}.openGroupIdx(3).name, g3.name));
end

function [] = testOpenDataArrayIdx( varargin )
%% Test Open DataArray by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d1 = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [3 2]);
    d2 = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [6 2]);
    d3 = b.createDataArray('testDataArray3', 'nixDataArray', nix.DataType.Double, [9 2]);

    assert(strcmp(f.blocks{1}.openDataArrayIdx(1).name, d1.name));
    assert(strcmp(f.blocks{1}.openDataArrayIdx(2).name, d2.name));
    assert(strcmp(f.blocks{1}.openDataArrayIdx(3).name, d3.name));
end

function [] = testOpenTagIdx( varargin )
%% Test Open Tag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t1 = b.createTag('testTag1', 'nixTag', [1 2]);
    t2 = b.createTag('testTag2', 'nixTag', [1 2]);
    t3 = b.createTag('testTag3', 'nixTag', [1 2]);

    assert(strcmp(f.blocks{1}.openTagIdx(1).name, t1.name));
    assert(strcmp(f.blocks{1}.openTagIdx(2).name, t2.name));
    assert(strcmp(f.blocks{1}.openTagIdx(3).name, t3.name));
end

function [] = testOpenMultiTagIdx( varargin )
%% Test Open MultiTag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 3]);
    t1 = b.createMultiTag('testMultiTag1', 'nixMultiTag', d);
    t2 = b.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    t3 = b.createMultiTag('testMultiTag3', 'nixMultiTag', d);

    assert(strcmp(f.blocks{1}.openMultiTagIdx(1).name, t1.name));
    assert(strcmp(f.blocks{1}.openMultiTagIdx(2).name, t2.name));
    assert(strcmp(f.blocks{1}.openMultiTagIdx(3).name, t3.name));
end

function [] = testOpenSourceIdx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s1 = b.createSource('testSource1', 'nixSource');
    s2 = b.createSource('testSource2', 'nixSource');
    s3 = b.createSource('testSource3', 'nixSource');

    assert(strcmp(f.blocks{1}.openSourceIdx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.openSourceIdx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.openSourceIdx(3).name, s3.name));
end

function [] = testHasMultiTag( varargin )
%% Test: Block has multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.createDataArray('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createMultiTag('mTagTest1', 'nixMultiTag', b.dataArrays{1});

    assert(b.hasMultiTag(b.multiTags{1,1}.id));
    assert(b.hasMultiTag(b.multiTags{1,1}.name));
    
    assert(~b.hasMultiTag('I do not exist'));
end

function [] = testHasTag( varargin )
%% Test: Block has tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    tmp = b.createTag('tagtest1', 'nixTag', [1.0 1.2 1.3 15.9]);

    assert(b.hasTag(b.tags{1,1}.id));
    assert(b.hasTag(b.tags{1,1}.name));
    
    assert(~b.hasTag('I do not exist'));
end

%% Test: Set metadata
function [] = testSetMetadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection(secName1, 'nixSection');
    tmp = f.createSection(secName2, 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    
    assert(isempty(b.open_metadata));
    assert(isempty(f.blocks{1}.open_metadata));

    b.set_metadata(f.sections{1});
    assert(strcmp(b.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.open_metadata.name, secName1));

    b.set_metadata(f.sections{2});
    assert(strcmp(b.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.open_metadata.name, secName2));
    b.set_metadata('');
    assert(isempty(b.open_metadata));
    assert(isempty(f.blocks{1}.open_metadata));

    b.set_metadata(f.sections{2});
    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
	assert(strcmp(f.blocks{1}.open_metadata.name, secName2));
end

function [] = testOpenMetadata( varargin )
%% Test: Open metadata
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    b.set_metadata(f.sections{1});

    assert(strcmp(b.open_metadata.name, 'testSection'));
end

%% Test: nix.Block has nix.DataArray by ID or name
function [] = testHasDataArray( varargin )
    fileName = 'testRW.h5';
    daName = 'hasDataArrayTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    da = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    daID = da.id;
    
    assert(~b.hasDataArray('I do not exist'));
    assert(b.hasDataArray(daName));

    clear da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.hasDataArray(daID));
end

%% Test: nix.Block has nix.Source by ID or name
function [] = testHasSource( varargin )
    fileName = 'testRW.h5';
    sName = 'sourcetest1';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    s = b.createSource(sName, 'nixSource');
    sID = s.id;

    assert(~b.hasSource('I do not exist'));
    assert(b.hasSource(sName));

    clear s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.hasSource(sID));
end

%% Test: Create nix.Group
function [] = testCreateGroup( varargin )
    fileName = 'testRW.h5';
    groupName = 'testGroup';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');

    assert(isempty(b.groups));

    g = b.createGroup(groupName, groupType);
    assert(strcmp(g.name, groupName));
    assert(strcmp(g.type, groupType));
    assert(~isempty(b.groups));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(~isempty(f.blocks{1}.groups));
    assert(strcmp(f.blocks{1}.groups{1}.name, groupName));
end

%% Test: nix.Block has nix.Group by name or id
function [] = testHasGroup( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');

    assert(~b.hasGroup('I do not exist'));
    
    g = b.createGroup(groupName, 'nixGroup');
    assert(b.hasGroup(b.groups{1}.id));
    assert(b.hasGroup(groupName));

    b.deleteGroup(b.groups{1});
    assert(~b.hasGroup(g.id));
end

%% Test: Get nix.Group by name or id
function [] = testOpenGroup( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');
    g = b.createGroup(groupName, 'nixGroup');
    gID = g.id;

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.openGroup(gID).name, groupName));
    assert(strcmp(f.blocks{1}.openGroup(groupName).name, groupName));
end

%% Test: Delete nix.Group by entity and id
function [] = testDeleteGroup( varargin )
    fileName = 'testRW.h5';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');
    g1 = b.createGroup('testGroup1', groupType);
    g2 = b.createGroup('testGroup2', groupType);

    assert(size(b.groups, 1) == 2);
    assert(b.deleteGroup(b.groups{2}.id));
    assert(size(b.groups, 1) == 1);
    assert(b.deleteGroup(b.groups{1}));
    assert(isempty(b.groups));

    assert(~b.deleteGroup('I do not exist'));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isempty(f.blocks{1}.groups));
end

%% Test: Group count
function [] = testGroupCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    assert(b.groupCount() == 0);
    g = b.createGroup('testGroup', 'nixGroup');
    assert(b.groupCount() == 1);
    g = b.createGroup('testGroup2', 'nixGroup');
    
    clear g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groupCount() == 2);
end

%% Test: DataArray count
function [] = testDataArrayCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    assert(b.dataArrayCount() == 0);
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    assert(b.dataArrayCount() == 1);
    d = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    
    clear d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.dataArrayCount() == 2);
end

%% Test: Tag count
function [] = testTagCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    assert(b.tagCount() == 0);
    t = b.createTag('testTag1', 'nixTag', [1.0 1.2 1.3 15.9]);
    assert(b.tagCount() == 1);
    t = b.createTag('testTag2', 'nixTag', [1.0 1.2 1.3 15.9]);
    
    clear t b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tagCount() == 2);
end

%% Test: MultiTag count
function [] = testMultiTagCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(b.multiTagCount() == 0);
    t = b.createMultiTag('testMultiTag1', 'nixMultiTag', b.dataArrays{1});
    assert(b.multiTagCount() == 1);
    t = b.createMultiTag('testMultiTag2', 'nixMultiTag', b.dataArrays{1});
    
    clear t d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTagCount() == 2);
end

%% Test: Source count
function [] = testSourceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    assert(b.sourceCount() == 0);
    s = b.createSource('testSource1', 'nixSource');
    assert(b.sourceCount() == 1);
    s = b.createSource('testSource2', 'nixSource');
    
    clear s b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.sourceCount() == 2);
end

function [] = testCompare( varargin )
%% Test: Compare block entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');

    assert(b1.compare(b2) < 0);
    assert(b1.compare(b1) == 0);
    assert(b2.compare(b1) > 0);
end

%% Test: filter sources
function [] = testFilterSource( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    s = b.createSource(filterName, 'nixSource');
    filterID = s.id;
	s = b.createSource('testSource1', filterType);
    filterIDs = {filterID, s.id};
    s = b.createSource('testSource2', filterType);
    
    % test empty id filter
    assert(isempty(f.blocks{1}.filterSources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filterSources(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.filterSources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filterSources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.filterSources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.filterSources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.createSource(mainName, 'nixSource');
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filterSources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filterSources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainSource = b.createSource(mainName, 'nixSource');
    mainID = mainSource.id;
    subName = 'testSubSource1';
    s = mainSource.createSource(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.filterSources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.filterSources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.filterSources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end


%% Test: filter groups
function [] = testFilterGroup( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup(filterName, 'nixGroup');
    filterID = g.id;
	g = b.createGroup('testGroup1', filterType);
    filterIDs = {filterID, g.id};
    g = b.createGroup('testGroup2', filterType);
    
    % test empty id filter
    assert(isempty(f.blocks{1}.filterGroups(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filterGroups(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.filterGroups(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filterGroups(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.filterGroups(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.filterGroups(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainEntity = b.createGroup(mainName, 'nixGroup');
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainEntity.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filterGroups(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filterGroups(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainEntity = b.createGroup(mainName, 'nixGroup');
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    mainEntity.add_source(s);
    subID = s.id;

    % filter works only for ID, not for name
    filtered = f.blocks{1}.filterGroups(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter tags
function [] = testFilterTag( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag(filterName, 'nixTag', [1 2 3]);
    filterID = t.id;
	t = b.createTag('testTag1', filterType, [1 2 3 4]);
    filterIDs = {filterID, t.id};
    t = b.createTag('testTag2', filterType, [1 2]);

    % test empty id filter
    assert(isempty(f.blocks{1}.filterTags(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filterTags(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.filterTags(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filterTags(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.filterTags(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.filterTags(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainEntity = b.createTag(mainName, 'nixTag', [1 8]);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainEntity.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filterTags(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filterTags(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainEntity = b.createTag(mainName, 'nixTag', [12 3]);
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    mainEntity.add_source(s);
    subID = s.id;

    % filter works only for ID, not for name
    filtered = f.blocks{1}.filterTags(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter multi tags
function [] = testFilterMultiTag( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 9]);
    t = b.createMultiTag(filterName, 'nixMultiTag', d);
    filterID = t.id;
	t = b.createMultiTag('testMultiTag1', filterType, d);
    filterIDs = {filterID, t.id};
    t = b.createMultiTag('testMultiTag2', filterType, d);

    % test empty id filter
    assert(isempty(f.blocks{1}.filterMultiTags(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));

    % test nix.Filter.name
    filtered  = f.blocks{1}.filterMultiTags(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));

    % test nix.Filter.type
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainEntity = b.createMultiTag(mainName, 'nixMultiTag', d);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainEntity.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filterMultiTags(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainEntity = b.createMultiTag(mainName, 'nixMultiTag', d);
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    mainEntity.add_source(s);
    subID = s.id;

    % filter works only for ID, not for name
    filtered = f.blocks{1}.filterMultiTags(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
    
    % test filters work only within blocks, not between them
    b = f.createBlock('testBlock2', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 9]);
    t = b.createMultiTag(filterName, 'nixMultiTag', d);
    assert(size( b.filterMultiTags(nix.Filter.name, filterName), 1) == 1);
end

%% Test: filter data arrays
function [] = testFilterDataArray( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray(filterName, 'nixDataArray', nix.DataType.Bool, [2 9]);
    filterID = d.id;
    d = b.createDataArray('testDataArray1', filterType, nix.DataType.Bool, [2 9]);
    filterIDs = {filterID, d.id};
    d = b.createDataArray('testDataArray2', filterType, nix.DataType.Bool, [2 9]);

    % test empty id filter
    assert(isempty(f.blocks{1}.filterDataArrays(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));

    % test nix.Filter.name
    filtered  = f.blocks{1}.filterDataArrays(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));

    % test nix.Filter.type
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainEntity = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 9]);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainEntity.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filterMultiTags(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainEntity = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 9]);
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    mainEntity.add_source(s);
    subID = s.id;

    % filter works only for ID, not for name
    filtered = f.blocks{1}.filterDataArrays(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: Find source w/o filter
function [] = testFindSource
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    sl1 = b.createSource('sourceLvl1', 'nixSource');

    sl21 = sl1.createSource('sourceLvl2_1', 'nixSource');
    sl22 = sl1.createSource('sourceLvl2_2', 'nixSource');

    sl31 = sl21.createSource('sourceLvl3_1', 'nixSource');
    sl32 = sl21.createSource('sourceLvl3_2', 'nixSource');
    sl33 = sl21.createSource('sourceLvl3_3', 'nixSource');

    sl41 = sl31.createSource('sourceLvl4_1', 'nixSource');
    sl42 = sl31.createSource('sourceLvl4_2', 'nixSource');
    sl43 = sl31.createSource('sourceLvl4_3', 'nixSource');
    sl44 = sl31.createSource('sourceLvl4_4', 'nixSource');

    % Check invalid entry
    err = 'Provide a valid search depth';
    try
        b.findSources('hurra');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % find all
    filtered = b.findSources(5);
    assert(size(filtered, 1) == 10);

    % find until level 4
    filtered = b.findSources(4);
    assert(size(filtered, 1) == 10);

    % find until level 3
    filtered = b.findSources(3);
    assert(size(filtered, 1) == 6);

    % find until level 2
    filtered = b.findSources(2);
    assert(size(filtered, 1) == 3);

    % find until level 1
    filtered = b.findSources(1);
    assert(size(filtered, 1) == 1);
end

%% Test: Find sources with filters
function [] = testFindSourceFiltered
    findSource = 'nixFindSection';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    sl1 = b.createSource('sourceLvl1', 'nixSource');

    sl21 = sl1.createSource('sourceLvl2_1', 'nixSource');
    sl22 = sl1.createSource('sourceLvl2_2', findSource);

    sl31 = sl21.createSource('sourceLvl3_1', findSource);
    sl32 = sl21.createSource('sourceLvl3_2', 'nixSource');
    sl33 = sl21.createSource('sourceLvl3_3', 'nixSource');

    sl41 = sl31.createSource('sourceLvl4_1', findSource);
    sl42 = sl31.createSource('sourceLvl4_2', 'nixSource');
    sl43 = sl31.createSource('sourceLvl4_3', 'nixSource');
    sl44 = sl31.createSource('sourceLvl4_4', 'nixSource');

    % test find by id
    filtered = b.filterFindSources(2, nix.Filter.id, sl41.id);
    assert(isempty(filtered));
    filtered = b.filterFindSources(5, nix.Filter.id, sl41.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl41.id));

    % test find by ids
    filterids = {sl1.id, sl41.id};
    filtered = b.filterFindSources(1, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 1);
    filtered = b.filterFindSources(4, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 2);

    % test find by name
    filtered = b.filterFindSources(1, nix.Filter.name, sl41.name);
    assert(isempty(filtered));
    filtered = b.filterFindSources(4, nix.Filter.name, sl41.name);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, sl41.name));

    % test find by type
    filtered = b.filterFindSources(1, nix.Filter.type, findSource);
    assert(isempty(filtered));
    filtered = b.filterFindSources(4, nix.Filter.type, findSource);
    assert(size(filtered, 1) == 3);
    assert(strcmp(filtered{1}.type, findSource));

    % test nix.Filter.metadata
    sec = f.createSection('testSection', 'nixSection');
    sl43.set_metadata(sec);
    filtered = b.filterFindSources(1, nix.Filter.metadata, sec.id);
    assert(isempty(filtered));
    filtered = b.filterFindSources(4, nix.Filter.metadata, sec.id);
    assert(size(filtered, 1) == 1);
    strcmp(filtered{1}.id, sl43.id);

    % test nix.Filter.source
    filtered = b.filterFindSources(1, nix.Filter.source, sl44.id);
    assert(isempty(filtered));
    filtered = b.filterFindSources(4, nix.Filter.source, sl44.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl31.id));
end
