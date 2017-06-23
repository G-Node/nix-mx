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
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_create_data_array;
    funcs{end+1} = @test_create_data_array_from_data;
    funcs{end+1} = @test_delete_data_array;
    funcs{end+1} = @test_create_tag;
    funcs{end+1} = @test_delete_tag;
    funcs{end+1} = @test_create_multi_tag;
    funcs{end+1} = @test_delete_multi_tag;
    funcs{end+1} = @test_create_source;
    funcs{end+1} = @test_delete_source;
    funcs{end+1} = @test_list_arrays;
    funcs{end+1} = @test_list_sources;
    funcs{end+1} = @test_list_tags;
    funcs{end+1} = @test_list_multitags;
    funcs{end+1} = @test_open_array;
    funcs{end+1} = @test_open_tag;
    funcs{end+1} = @test_open_multitag;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_group_idx;
    funcs{end+1} = @test_open_data_array_idx;
    funcs{end+1} = @test_open_tag_idx;
    funcs{end+1} = @test_open_multi_tag_idx;
    funcs{end+1} = @test_open_source_idx;
    funcs{end+1} = @test_has_data_array;
    funcs{end+1} = @test_has_source;
    funcs{end+1} = @test_has_multitag;
    funcs{end+1} = @test_has_tag;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_create_group;
    funcs{end+1} = @test_has_group;
    funcs{end+1} = @test_get_group;
    funcs{end+1} = @test_delete_group;
    funcs{end+1} = @test_group_count;
    funcs{end+1} = @test_data_array_count;
    funcs{end+1} = @test_tag_count;
    funcs{end+1} = @test_multi_tag_count;
    funcs{end+1} = @test_source_count;
    funcs{end+1} = @test_compare;
    funcs{end+1} = @test_filter_source;
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'test nixBlock');

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
function [] = test_create_data_array( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    dtype = 'nix.DataArray';
    doubleName = 'doubleDataArray';
    da = b.create_data_array(doubleName, dtype, nix.DataType.Double, [2 3]);
    assert(strcmp(da.name, doubleName));
    assert(strcmp(da.type, dtype));
    tmp = da.read_all();
    assert(all(tmp(:) == 0));

    try
        b.create_data_array('stringDataArray', dtype, nix.DataType.String, [1 5]);
    catch ME
        assert(strcmp(ME.identifier, 'Block:unsupportedDataType'));
    end;
    
    try
        b.create_data_array('I will crash and burn', dtype, 'Thou shalt not work!', [1 5]);
    catch ME
        assert(strcmp(ME.identifier, 'Block:unsupportedDataType'));
    end;

    da = b.create_data_array('floatDataArray', dtype, nix.DataType.Float, [3 3]);
    da = b.create_data_array('Int8DataArray', dtype, nix.DataType.Int8, [3 3]);
    da = b.create_data_array('Int16DataArray', dtype, nix.DataType.Int16, [3 3]);
    da = b.create_data_array('Int32DataArray', dtype, nix.DataType.Int32, [3 3]);
    da = b.create_data_array('Int64DataArray', dtype, nix.DataType.Int64, [3 3]);
    da = b.create_data_array('UInt8DataArray', dtype, nix.DataType.UInt8, [3 3]);
    da = b.create_data_array('UInt16DataArray', dtype, nix.DataType.UInt16, [3 3]);
    da = b.create_data_array('UInt32DataArray', dtype, nix.DataType.UInt32, [3 3]);
    da = b.create_data_array('UInt64DataArray', dtype, nix.DataType.UInt64, [3 3]);
    da = b.create_data_array('logicalArray', dtype, nix.DataType.Bool, [3 3]);
    
    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 11);
end

%% Test: Create Data Array from data
function [] = test_create_data_array_from_data( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    daType = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    numName = 'numDataArray';
    numData = [1, 2, 3; 4, 5, 6];
    da = b.create_data_array_from_data(numName, daType, numData);
    assert(strcmp(da.name, numName));
    assert(strcmp(da.type, daType));
    
    tmp = da.read_all();
    assert(strcmp(class(tmp), class(numData)));
    assert(isequal(size(tmp), size(numData)));
    assert(isequal(tmp, numData));
    
    logName = 'logicalDataArray';
    logData = logical([1 0 1; 0 1 0; 1 0 1]);
    da = b.create_data_array_from_data(logName, daType, logData);
    assert(islogical(da.read_all));
    assert(isequal(size(da.read_all), size(logData)));
    assert(isequal(da.read_all, logData));
    
    try
        b.create_data_array_from_data('stringDataArray', daType, ['a' 'b']);
    catch ME
        assert(strcmp(ME.identifier, 'Block:unsupportedDataType'));
    end;
    
    try
        b.create_data_array_from_data('I will crash and burn', daType, {1 2 3});
    catch ME
        assert(strcmp(ME.identifier, 'Block:unsupportedDataType'));
    end;
    
    assert(~isempty(b.dataArrays));
end

%% Test: delete dataArray by entity and id
function [] = test_delete_data_array( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('arraytest', 'nixBlock');
    tmp = b.create_data_array('dataArrayTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array('dataArrayTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    
    assert(size(b.dataArrays, 1) == 2);
    assert(b.delete_data_array(b.dataArrays{2}.id));
    assert(size(b.dataArrays, 1) == 1);
    assert(b.delete_data_array(b.dataArrays{1}));
    assert(isempty(b.dataArrays));
    assert(~b.delete_data_array('I do not exist'));
end

function [] = test_create_tag( varargin )
%% Test: Create Tag
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'nixblock');
    
    assert(isempty(b.tags));

    position = [1.0 1.2 1.3 15.9];
    t1 = b.create_tag('foo', 'bar', position);
    assert(strcmp(t1.name, 'foo'));
    assert(strcmp(t1.type, 'bar'));
    assert(isequal(t1.position, position));
    
    assert(~isempty(b.tags));
end

%% Test: delete tag by entity and id
function [] = test_delete_tag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tmp = b.create_tag('tagtest1', 'nixTag', position);
    tmp = b.create_tag('tagtest2', 'nixTag', position);
    
    assert(size(b.tags, 1) == 2);
    assert(b.delete_tag(b.tags{2}.id));
    assert(size(b.tags, 1) == 1);
    assert(b.delete_tag(b.tags{1}));
    assert(isempty(b.tags));

    assert(~b.delete_tag('I do not exist'));
end

function [] = test_create_multi_tag( varargin )
%% Test: Create multitag by data_array entity and data_array id
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array('mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    assert(isempty(b.multiTags));

    %-- create by data_array entity
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    assert(~isempty(b.multiTags));
    assert(strcmp(b.multiTags{1}.name, 'mTagTest1'));

    %-- create by data_array id
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag2', b.dataArrays{2}.id);
    assert(size(b.multiTags, 1) == 2);
    assert(strcmp(b.multiTags{2}.type, 'nixMultiTag2'));
end

%% Test: delete multitag by entity and id
function [] = test_delete_multi_tag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag2', b.dataArrays{1});

    assert(size(b.multiTags, 1) == 2);
    assert(b.delete_multi_tag(b.multiTags{2}.id));
    assert(size(b.multiTags, 1) == 1);
    assert(b.delete_multi_tag(b.multiTags{1}));
    assert(isempty(b.multiTags));
    assert(size(b.dataArrays, 1) == 1);

    assert(~b.delete_multi_tag('I do not exist'));
end

%% Test: create source
function [] = test_create_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.create_block('sourcetest', 'nixblock');
    assert(isempty(getBlock.sources));

    createSource = getBlock.create_source('sourcetest','nixsource');
    assert(~isempty(getBlock.sources));
    assert(strcmp(createSource.name, 'sourcetest'));
    assert(strcmp(createSource.type, 'nixsource'));
end

%% Test: delete source by entity and id
function [] = test_delete_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.create_block('sourcetest', 'nixblock');
    tmp = getBlock.create_source('sourcetest1','nixsource');
    tmp = getBlock.create_source('sourcetest2','nixsource');
    tmp = getBlock.create_source('sourcetest3','nixsource');

    assert(getBlock.delete_source('sourcetest1'));
    assert(getBlock.delete_source(getBlock.sources{1}.id));
    assert(getBlock.delete_source(getBlock.sources{1}));
    assert(isempty(getBlock.sources));
    
    assert(~getBlock.delete_source('I do not exist'));
end

%% Test: Fetch nix.DataArrays
function [] = test_list_arrays( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('arraytest', 'nixBlock');

    assert(isempty(b.dataArrays));
    tmp = b.create_data_array('arrayTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_data_array('arrayTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    assert(size(b.dataArrays, 1) == 2);
    assert(size(f.blocks{1}.dataArrays, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 2);
end

%% Test: Fetch nix.Sources
function [] = test_list_sources( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('sourcetest', 'nixBlock');

    assert(isempty(b.sources));
    tmp = b.create_source('sourcetest1','nixSource');
    assert(size(b.sources, 1) == 1);
    assert(size(f.blocks{1}.sources, 1) == 1);
    tmp = b.create_source('sourcetest2','nixSource');
    assert(size(b.sources, 1) == 2);
    assert(size(f.blocks{1}.sources, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.sources, 1) == 2);
end

%% Test: Fetch nix.Tags
function [] = test_list_tags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];

    assert(isempty(b.tags));
    tmp = b.create_tag('tagtest1', 'nixTag', position);
    assert(size(b.tags, 1) == 1);
    assert(size(f.blocks{1}.tags, 1) == 1);
    tmp = b.create_tag('tagtest2', 'nixTag', position);
    assert(size(b.tags, 1) == 2);
    assert(size(f.blocks{1}.tags, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags, 1) == 2);
end

%% Test: fetch multitags
function [] = test_list_multitags( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.create_block('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(b.multiTags));
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag', b.dataArrays{1});
    assert(size(b.multiTags, 1) == 1);
    assert(size(f.blocks{1}.multiTags, 1) == 1);
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag', b.dataArrays{1});
    assert(size(b.multiTags, 1) == 2);
    assert(size(f.blocks{1}.multiTags, 1) == 2);

    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags, 1) == 2);
end

function [] = test_open_array( varargin )
%% Test: Open data array by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('arraytest', 'nixBlock');
    daName = 'arrayTest1';
    
    assert(isempty(b.dataArrays));
    tmp = b.create_data_array(daName, 'nixDataArray', nix.DataType.Double, [1 2]);

    getDataArrayByID = b.data_array(b.dataArrays{1,1}.id);
    assert(~isempty(getDataArrayByID));

    getDataArrayByName = b.data_array(daName);
    assert(~isempty(getDataArrayByName));
    
    %-- test open non existing dataarray
    getDataArray = b.data_array('I do not exist');
    assert(isempty(getDataArray));
end

function [] = test_open_tag( varargin )
%% Test: Open tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tagName = 'tagtest1';
    tmp = b.create_tag(tagName, 'nixTag', position);

    getTagByID = b.open_tag(b.tags{1,1}.id);
    assert(~isempty(getTagByID));

    getTagByName = b.open_tag(tagName);
    assert(~isempty(getTagByName));
    
    %-- test open non existing tag
    getTag = b.open_tag('I do not exist');
    assert(isempty(getTag));
end

function [] = test_open_multitag( varargin )
%% Test: Open multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    mTagName = 'mTagTest1';
    tmp = b.create_multi_tag(mTagName, 'nixMultiTag', b.dataArrays{1});

    getMultiTagByID = b.open_multi_tag(b.multiTags{1,1}.id);
    assert(~isempty(getMultiTagByID));

    getMultiTagByName = b.open_multi_tag(mTagName);
    assert(~isempty(getMultiTagByName));
    
    %-- test open non existing multitag
    getMultiTag = b.open_multi_tag('I do not exist');
    assert(isempty(getMultiTag));
end

function [] = test_open_source( varargin )
%% Test: Open source by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('sourcetest', 'nixBlock');
    sName = 'sourcetest1';
    tmp = b.create_source(sName, 'nixSource');
    
    getSourceByID = b.open_source(b.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = b.open_source(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = b.open_source('I do not exist');
    assert(isempty(getSource));
end

function [] = test_open_group_idx( varargin )
%% Test Open Group by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    g1 = b.create_group('testGroup1', 'nixGroup');
    g2 = b.create_group('testGroup2', 'nixGroup');
    g3 = b.create_group('testGroup3', 'nixGroup');

    assert(strcmp(f.blocks{1}.open_group_idx(0).name, g1.name));
    assert(strcmp(f.blocks{1}.open_group_idx(1).name, g2.name));
    assert(strcmp(f.blocks{1}.open_group_idx(2).name, g3.name));
end

function [] = test_open_data_array_idx( varargin )
%% Test Open DataArray by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d1 = b.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [3 2]);
    d2 = b.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [6 2]);
    d3 = b.create_data_array('testDataArray3', 'nixDataArray', nix.DataType.Double, [9 2]);

    assert(strcmp(f.blocks{1}.open_data_array_idx(0).name, d1.name));
    assert(strcmp(f.blocks{1}.open_data_array_idx(1).name, d2.name));
    assert(strcmp(f.blocks{1}.open_data_array_idx(2).name, d3.name));
end

function [] = test_open_tag_idx( varargin )
%% Test Open Tag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    t1 = b.create_tag('testTag1', 'nixTag', [1 2]);
    t2 = b.create_tag('testTag2', 'nixTag', [1 2]);
    t3 = b.create_tag('testTag3', 'nixTag', [1 2]);

    assert(strcmp(f.blocks{1}.open_tag_idx(0).name, t1.name));
    assert(strcmp(f.blocks{1}.open_tag_idx(1).name, t2.name));
    assert(strcmp(f.blocks{1}.open_tag_idx(2).name, t3.name));
end

function [] = test_open_multi_tag_idx( varargin )
%% Test Open MultiTag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 3]);
    t1 = b.create_multi_tag('testMultiTag1', 'nixMultiTag', d);
    t2 = b.create_multi_tag('testMultiTag2', 'nixMultiTag', d);
    t3 = b.create_multi_tag('testMultiTag3', 'nixMultiTag', d);

    assert(strcmp(f.blocks{1}.open_multi_tag_idx(0).name, t1.name));
    assert(strcmp(f.blocks{1}.open_multi_tag_idx(1).name, t2.name));
    assert(strcmp(f.blocks{1}.open_multi_tag_idx(2).name, t3.name));
end

function [] = test_open_source_idx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s1 = b.create_source('testSource1', 'nixSource');
    s2 = b.create_source('testSource2', 'nixSource');
    s3 = b.create_source('testSource3', 'nixSource');

    assert(strcmp(f.blocks{1}.open_source_idx(0).name, s1.name));
    assert(strcmp(f.blocks{1}.open_source_idx(1).name, s2.name));
    assert(strcmp(f.blocks{1}.open_source_idx(2).name, s3.name));
end

function [] = test_has_multitag( varargin )
%% Test: Block has multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag', b.dataArrays{1});

    assert(b.has_multi_tag(b.multiTags{1,1}.id));
    assert(b.has_multi_tag(b.multiTags{1,1}.name));
    
    assert(~b.has_multi_tag('I do not exist'));
end

function [] = test_has_tag( varargin )
%% Test: Block has tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('tagtest', 'nixBlock');
    tmp = b.create_tag('tagtest1', 'nixTag', [1.0 1.2 1.3 15.9]);

    assert(b.has_tag(b.tags{1,1}.id));
    assert(b.has_tag(b.tags{1,1}.name));
    
    assert(~b.has_tag('I do not exist'));
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.create_section(secName1, 'nixSection');
    tmp = f.create_section(secName2, 'nixSection');
    b = f.create_block('testBlock', 'nixBlock');
    
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

function [] = test_open_metadata( varargin )
%% Test: Open metadata
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.create_section('testSection', 'nixSection');
    b = f.create_block('testBlock', 'nixBlock');
    b.set_metadata(f.sections{1});

    assert(strcmp(b.open_metadata.name, 'testSection'));
end

%% Test: nix.Block has nix.DataArray by ID or name
function [] = test_has_data_array( varargin )
    fileName = 'testRW.h5';
    daName = 'hasDataArrayTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('testblock', 'nixBlock');
    da = b.create_data_array(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    daID = da.id;
    
    assert(~b.has_data_array('I do not exist'));
    assert(b.has_data_array(daName));

    clear da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.has_data_array(daID));
end

%% Test: nix.Block has nix.Source by ID or name
function [] = test_has_source( varargin )
    fileName = 'testRW.h5';
    sName = 'sourcetest1';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('testblock', 'nixBlock');
    s = b.create_source(sName, 'nixSource');
    sID = s.id;

    assert(~b.has_source('I do not exist'));
    assert(b.has_source(sName));

    clear s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.has_source(sID));
end

%% Test: Create nix.Group
function [] = test_create_group( varargin )
    fileName = 'testRW.h5';
    groupName = 'testGroup';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('grouptest', 'nixBlock');

    assert(isempty(b.groups));

    g = b.create_group(groupName, groupType);
    assert(strcmp(g.name, groupName));
    assert(strcmp(g.type, groupType));
    assert(~isempty(b.groups));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(~isempty(f.blocks{1}.groups));
    assert(strcmp(f.blocks{1}.groups{1}.name, groupName));
end

%% Test: nix.Block has nix.Group by name or id
function [] = test_has_group( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('grouptest', 'nixBlock');

    assert(~b.has_group('I do not exist'));
    
    g = b.create_group(groupName, 'nixGroup');
    assert(b.has_group(b.groups{1}.id));
    assert(b.has_group(groupName));

    b.delete_group(b.groups{1});
    assert(~b.has_group(g.id));
end

%% Test: Get nix.Group by name or id
function [] = test_get_group( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('grouptest', 'nixBlock');
    g = b.create_group(groupName, 'nixGroup');
    gID = g.id;

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.get_group(gID).name, groupName));
    assert(strcmp(f.blocks{1}.get_group(groupName).name, groupName));
end

%% Test: Delete nix.Group by entity and id
function [] = test_delete_group( varargin )
    fileName = 'testRW.h5';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.create_block('grouptest', 'nixBlock');
    g1 = b.create_group('testGroup1', groupType);
    g2 = b.create_group('testGroup2', groupType);

    assert(size(b.groups, 1) == 2);
    assert(b.delete_group(b.groups{2}.id));
    assert(size(b.groups, 1) == 1);
    assert(b.delete_group(b.groups{1}));
    assert(isempty(b.groups));

    assert(~b.delete_group('I do not exist'));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isempty(f.blocks{1}.groups));
end

%% Test: Group count
function [] = test_group_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    assert(b.group_count() == 0);
    g = b.create_group('testGroup', 'nixGroup');
    assert(b.group_count() == 1);
    g = b.create_group('testGroup2', 'nixGroup');
    
    clear g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.group_count() == 2);
end

%% Test: DataArray count
function [] = test_data_array_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');

    assert(b.data_array_count() == 0);
    d = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    assert(b.data_array_count() == 1);
    d = b.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    
    clear d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.data_array_count() == 2);
end

%% Test: Tag count
function [] = test_tag_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');

    assert(b.tag_count() == 0);
    t = b.create_tag('testTag1', 'nixTag', [1.0 1.2 1.3 15.9]);
    assert(b.tag_count() == 1);
    t = b.create_tag('testTag2', 'nixTag', [1.0 1.2 1.3 15.9]);
    
    clear t b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tag_count() == 2);
end

%% Test: MultiTag count
function [] = test_multi_tag_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    d = b.create_data_array('mTagTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(b.multi_tag_count() == 0);
    t = b.create_multi_tag('testMultiTag1', 'nixMultiTag', b.dataArrays{1});
    assert(b.multi_tag_count() == 1);
    t = b.create_multi_tag('testMultiTag2', 'nixMultiTag', b.dataArrays{1});
    
    clear t d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multi_tag_count() == 2);
end

%% Test: Source count
function [] = test_source_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');

    assert(b.source_count() == 0);
    s = b.create_source('testSource1', 'nixSource');
    assert(b.source_count() == 1);
    s = b.create_source('testSource2', 'nixSource');
    
    clear s b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.source_count() == 2);
end

function [] = test_compare( varargin )
%% Test: Compare block entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    b2 = f.create_block('testBlock2', 'nixBlock');

    assert(b1.compare(b2) < 0);
    assert(b1.compare(b1) == 0);
    assert(b2.compare(b1) > 0);
end

%% Test: filter sources
function [] = test_filter_source( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('testBlock', 'nixBlock');
    s = b.create_source(filterName, 'nixSource');
    filterID = s.id;
	s = b.create_source('testSource1', filterType);
    filterIDs = {filterID, s.id};
    s = b.create_source('testSource2', filterType);
    
    % test empty id filter
    assert(isempty(f.blocks{1}.filter_sources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.filter_sources(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.filter_sources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.filter_sources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.filter_sources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.filter_sources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.create_source(mainName, 'nixSource');
    subName = 'testSubSection1';
    s = f.create_section(subName, 'nixSection');
    mainSource.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.filter_sources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.filter_sources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainSource = b.create_source(mainName, 'nixSource');
    mainID = mainSource.id;
    subName = 'testSubSource1';
    s = mainSource.create_source(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.filter_sources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.filter_sources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.filter_sources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end
