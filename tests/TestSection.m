% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestSection
%TESTFILE % Tests for the nix.Section object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_create_section;
    funcs{end+1} = @test_delete_section;
    funcs{end+1} = @test_list_subsections;
    funcs{end+1} = @test_open_section;
    funcs{end+1} = @test_open_section_idx;
    funcs{end+1} = @test_parent;
    funcs{end+1} = @test_has_section;
    funcs{end+1} = @test_section_count;
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_properties;
    funcs{end+1} = @test_create_property;
    funcs{end+1} = @test_create_property_with_value;
    funcs{end+1} = @test_delete_property;
    funcs{end+1} = @test_open_property;
    funcs{end+1} = @test_open_property_idx;
    funcs{end+1} = @test_property_count;
    funcs{end+1} = @test_link;
    funcs{end+1} = @test_inherited_properties;
    funcs{end+1} = @test_referring_data_arrays;
    funcs{end+1} = @test_referring_block_data_arrays;
    funcs{end+1} = @test_referring_tags;
    funcs{end+1} = @test_referring_block_tags;
    funcs{end+1} = @test_referring_multi_tags;
    funcs{end+1} = @test_referring_block_multi_tags;
    funcs{end+1} = @test_referring_sources;
    funcs{end+1} = @test_referring_block_sources;
    funcs{end+1} = @test_referring_blocks;
    funcs{end+1} = @test_compare;
end

%% Test: Create Section
function [] = test_create_section( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    assert(isempty(s.sections));
    tmp = s.create_section('testSection1', 'nixSection');
    tmp = s.create_section('testSection2', 'nixSection');
    assert(size(s.sections, 1) == 2);
end

%% Test: Delete Section by entity or ID
function [] = test_delete_section( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');
    tmp = s.create_section('testSection1', 'nixSection');
    tmp = s.create_section('testSection2', 'nixSection');

    assert(s.delete_section(s.sections{2}.id));
    assert(size(s.sections, 1) == 1);
    assert(s.delete_section(s.sections{1}));
    assert(isempty(s.sections));

    assert(~s.delete_section('I do not exist'));
end

function [] = test_list_subsections( varargin )
%% Test: List/fetch subsections
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(size(s1.sections, 1) == 4);
end

function [] = test_open_section( varargin )
%% Test: Open subsection by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    sid = s1.sections{1}.id;
    s2 = s1.open_section(sid);
    assert(strcmp(s2.id, sid));

    name = s1.sections{1}.name;
    s2 = s1.open_section(name);
    assert(strcmp(s2.id, s1.sections{1}.id));
    
    %-- test open non existing section
    getSection = s1.open_section('I dont exist');
    assert(isempty(getSection));
end

function [] = test_open_section_idx( varargin )
%% Test Open Section by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('testSection', 'nixSection');
    s1 = s.create_section('testSection1', 'nixSection');
    s2 = s.create_section('testSection2', 'nixSection');
    s3 = s.create_section('testSection3', 'nixSection');

    assert(strcmp(f.sections{1}.open_section_idx(0).name, s1.name));
    assert(strcmp(f.sections{1}.open_section_idx(1).name, s2.name));
    assert(strcmp(f.sections{1}.open_section_idx(2).name, s3.name));
end

function [] = test_parent( varargin )
%% Test: get parent section
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(isempty(s1.parent));

    s2 = s1.sections{1};
    assert(strcmp(s2.parent.id, s1.id));
end

function [] = test_has_section( varargin )
%% Test: Has Section
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    root = f.sections{3};
    child = root.sections{1};

    assert(root.has_section(child.id));
    assert(~root.has_section('whatever'));
end

%% Test: Section count
function [] = test_section_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    assert(s.section_count() == 0);
    tmp = s.create_section('testSection1', 'nixSection');
    assert(s.section_count() == 1);
    tmp = s.create_section('testSection2', 'nixSection');

    clear tmp s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.section_count() == 2);
end


function [] = test_attrs( varargin )
%% Test: Access Attributes / Links
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('foo', 'bar');

    assert(~isempty(s.id));

    assert(strcmp(s.name, 'foo'));
    assert(strcmp(s.type, 'bar'));
    assert(isempty(s.repository));
    assert(isempty(s.mapping));
    assert(isempty(s.definition));

    s.type = 'nixBlock';
    s.definition = 'section definition';
    s.repository = 'rep1';
    s.mapping = 'map1';
    assert(strcmp(s.type, 'nixBlock'));
    assert(strcmp(s.definition, 'section definition'));
    assert(strcmp(s.repository, 'rep1'));
    assert(strcmp(s.mapping, 'map1'));

    s.definition = '';
    s.repository = '';
    s.mapping = '';
    assert(isempty(s.definition));
    assert(isempty(s.repository));
    assert(isempty(s.mapping));
end

function [] = test_properties( varargin )
%% Test: Properties
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};
    
    assert(~isempty(trial.allProperties));
    
    p1 = trial.allProperties{1};
    assert(strcmp(p1.name, 'ExperimentalCondition'));
    
    disp(f.sections{3}.allProperties);
    
    assert(isempty(f.sections{3}.allProperties));
end

%% Test: Create property by data type
function [] = test_create_property( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    tmp = s.create_property('newProperty1', nix.DataType.Double);
    tmp = s.create_property('newProperty2', nix.DataType.Bool);
    tmp = s.create_property('newProperty3', nix.DataType.String);
    assert(size(s.allProperties, 1) == 3);
    assert(strcmp(s.allProperties{1}.name, 'newProperty1'));
end

%% Test: Create property with value
function [] = test_create_property_with_value( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    tmp = s.create_property_with_value('doubleProperty1', [5, 6, 7, 8]);
    assert(strcmp(s.allProperties{end}.name, 'doubleProperty1'));
    assert(s.allProperties{end}.values{1} == 5);
    assert(size(s.allProperties{end}.values, 2) == 4);
    assert(s.open_property(s.allProperties{end}.id).values{1}.value == 5);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 4);
    assert(strcmpi(tmp.datatype,'double'));
    
    tmp = s.create_property_with_value('doubleProperty2', {5, 6, 7, 8});
    assert(strcmp(s.allProperties{end}.name, 'doubleProperty2'));
    assert(s.open_property(s.allProperties{end}.id).values{1}.value == 5);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 4);
    assert(strcmpi(tmp.datatype,'double'));

    tmp = s.create_property_with_value('stringProperty1', ['a', 'string']);
    assert(strcmp(s.allProperties{end}.name, 'stringProperty1'));
    assert(strcmp(s.open_property(s.allProperties{end}.id).values{1}.value, 'a'));
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 7);
    assert(strcmpi(tmp.datatype, 'char'));
    
    tmp = s.create_property_with_value('stringProperty2', {'this', 'has', 'strings'});
    assert(strcmp(s.allProperties{end}.name, 'stringProperty2'));
    assert(strcmp(s.allProperties{end}.values{1}, 'this'));
    assert(size(s.allProperties{end}.values, 2) == 3);
    assert(strcmp(s.open_property(s.allProperties{end}.id).values{1}.value, 'this'));
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 3);
    assert(strcmpi(tmp.datatype, 'char'));

    tmp = s.create_property_with_value('booleanProperty1', [true, false, true]);
    assert(strcmp(s.allProperties{end}.name, 'booleanProperty1'));
    assert(s.allProperties{end}.values{1});
    assert(~s.allProperties{end}.values{2});
    assert(size(s.allProperties{end}.values, 2) == 3);
    assert(s.open_property(s.allProperties{end}.id).values{1}.value);
    assert(~s.open_property(s.allProperties{end}.id).values{2}.value);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 3);
    assert(strcmpi(tmp.datatype, 'logical'));

    tmp = s.create_property_with_value('booleanProperty2', {true, false, true});
    assert(strcmp(s.allProperties{end}.name, 'booleanProperty2'));
    assert(s.open_property(s.allProperties{end}.id).values{1}.value);
    assert(~s.open_property(s.allProperties{end}.id).values{2}.value);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 3);
    assert(strcmpi(tmp.datatype, 'logical'));
    
    val1 = s.open_property(s.allProperties{1}.id).values{1};
    val2 = s.open_property(s.allProperties{1}.id).values{2};
    tmp = s.create_property_with_value('doubleByStrunct1', [val1, val2]);
    assert(strcmp(s.allProperties{end}.name, 'doubleByStrunct1'));
    assert(s.open_property(s.allProperties{end}.id).values{1}.value == 5);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 2);
    assert(strcmpi(tmp.datatype,'double'));
    
    val3 = s.open_property(s.allProperties{1}.id).values{3};
    tmp = s.create_property_with_value('doubleByStrunct2', {val1, val2, val3});
    assert(strcmp(s.allProperties{end}.name, 'doubleByStrunct2'));
    assert(s.open_property(s.allProperties{end}.id).values{3}.value == 7);
    assert(size(s.open_property(s.allProperties{end}.id).values, 1) == 3);
    assert(strcmpi(tmp.datatype,'double'));
end

%% Test: Delete property by entity, propertyStruct, ID and name
function [] = test_delete_property( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');
    tmp = s.create_property('newProperty1', nix.DataType.Double);
    tmp = s.create_property('newProperty2', nix.DataType.Bool);
    tmp = s.create_property('newProperty3', nix.DataType.String);
    tmp = s.create_property('newProperty4', nix.DataType.Double);

    assert(s.delete_property('newProperty4'));
    assert(s.delete_property(s.allProperties{3}.id));
    delProp = s.open_property(s.allProperties{2}.id);
    assert(s.delete_property(delProp));
    assert(s.delete_property(s.allProperties{1}));
    
    assert(~s.delete_property('I do not exist'));
end

%% Test: Open property by ID and name
function [] = test_open_property( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};

    assert(~isempty(trial.open_property(trial.allProperties{1}.id)));
    assert(~isempty(trial.open_property(trial.allProperties{1}.name)));
end

function [] = test_open_property_idx( varargin )
%% Test Open Propery by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('testSection', 'nixSection');
    p1 = s.create_property('testProperty1', nix.DataType.Double);
    p2 = s.create_property('testProperty2', nix.DataType.Bool);
    p3 = s.create_property('testProperty3', nix.DataType.String);

    assert(strcmp(f.sections{1}.open_property_idx(0).name, p1.name));
    assert(strcmp(f.sections{1}.open_property_idx(1).name, p2.name));
    assert(strcmp(f.sections{1}.open_property_idx(2).name, p3.name));
end

%% Test: Property count
function [] = test_property_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    assert(s.property_count() == 0);
    tmp = s.create_property('newProperty1', nix.DataType.Double);
    assert(s.property_count() == 1);
    tmp = s.create_property('newProperty2', nix.DataType.Bool);

    clear tmp s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.property_count() == 2);
end

%% Test: set, open and remove section link
function [] = test_link( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    mainSec = f.create_section('mainSection', 'nixSection');
    tmp = f.create_section('linkSection1', 'nixSection');
    tmp = f.create_section('linkSection2', 'nixSection');
    
    assert(isempty(mainSec.openLink));
    mainSec.set_link(f.sections{3}.id);
    assert(strcmp(mainSec.openLink.name, 'linkSection2'));
    mainSec.set_link(f.sections{2});
    assert(strcmp(mainSec.openLink.name, 'linkSection1'));
    
    mainSec.set_link('');
    assert(isempty(mainSec.openLink));
end

%% Test: inherited properties
function [] = test_inherited_properties( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');
    ls = f.create_section('linkSection', 'nixSection');
    
    assert(isempty(s.inherited_properties));

    s.set_link(ls);
    assert(isempty(s.inherited_properties));

    lp = ls.create_property('testProperty2', nix.DataType.String);
    assert(~isempty(s.inherited_properties));
    assert(strcmp(s.inherited_properties{1}.name, lp.name));
    
    s.create_property('testProperty1', nix.DataType.String);
    assert(size(s.inherited_properties, 1) == 2);
end

%% Test: referring data arrays
function [] = test_referring_data_arrays( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    d1 = b1.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    b2 = f.create_block('testBlock2', 'nixBlock');
    d2 = b2.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = f.create_section('testSection', 'nixSection');
    
    assert(isempty(s.referring_data_arrays));

    d1.set_metadata(s);
    assert(~isempty(s.referring_data_arrays));
    
    d2.set_metadata(s);
    assert(size(s.referring_data_arrays, 1) == 2);
    
    b2.delete_data_array(d2);
    d1.set_metadata('');
    assert(isempty(s.referring_data_arrays));
end

%% Test: referring block data arrays
function [] = test_referring_block_data_arrays( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testDataArray1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    d1 = b1.create_data_array(testName, 'nixDataArray', nix.DataType.Double, [1 2]);
    b2 = f.create_block('testBlock2', 'nixBlock');
    d2 = b2.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = f.create_section('testSection', 'nixSection');
    
    d1.set_metadata(s);
    d2.set_metadata(s);

    % test multiple arguments fail
    try
        s.referring_data_arrays('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referring_data_arrays(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testDataArray = s.referring_data_arrays(b1);
    assert(size(testDataArray, 2) == 1);
    assert(strcmp(testDataArray{1}.name, testName));
end

%% Test: referring tags
function [] = test_referring_tags( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    t1 = b1.create_tag('testTag1', 'nixTag', [1, 2]);
    b2 = f.create_block('testBlock2', 'nixBlock');
    t2 = b2.create_tag('testTag2', 'nixTag', [3, 4]);
    s = f.create_section('testSection', 'nixSection');
    
    assert(isempty(s.referring_tags));

    t1.set_metadata(s);
    assert(~isempty(s.referring_tags));
    
    t2.set_metadata(s);
    assert(size(s.referring_tags, 1) == 2);
    
    b2.delete_tag(t2);
    t1.set_metadata('');
    assert(isempty(s.referring_tags));
end

%% Test: referring block tags
function [] = test_referring_block_tags( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testTag1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    t1 = b1.create_tag(testName, 'nixTag', [1, 2]);
    b2 = f.create_block('testBlock2', 'nixBlock');
    t2 = b2.create_tag('testTag2', 'nixTag', [3, 4]);
    s = f.create_section('testSection', 'nixSection');

    t1.set_metadata(s);
    t2.set_metadata(s);

    % test multiple arguments fail
    try
        s.referring_tags('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referring_tags(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testTag = s.referring_tags(b1);
    assert(size(testTag, 2) == 1);
    assert(strcmp(testTag{1}.name, testName));
end

%% Test: referring multi tags
function [] = test_referring_multi_tags( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    d = b1.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b1.create_multi_tag('testMultiTag1', 'nixMultiTag', d);
    b2 = f.create_block('testBlock2', 'nixBlock');
    d = b2.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    t2 = b2.create_multi_tag('testMultiTag2', 'nixMultiTag', d);
    s = f.create_section('testSection', 'nixSection');
    
    assert(isempty(s.referring_multi_tags));

    t1.set_metadata(s);
    assert(~isempty(s.referring_multi_tags));
    
    t2.set_metadata(s);
    assert(size(s.referring_multi_tags, 1) == 2);
    
    b2.delete_multi_tag(t2);
    t1.set_metadata('');
    assert(isempty(s.referring_multi_tags));
end

%% Test: referring block multi tags
function [] = test_referring_block_multi_tags( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testMultiTag1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    d = b1.create_data_array('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b1.create_multi_tag(testName, 'nixMultiTag', d);
    b2 = f.create_block('testBlock2', 'nixBlock');
    d = b2.create_data_array('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    t2 = b2.create_multi_tag('testMultiTag2', 'nixMultiTag', d);
    s = f.create_section('testSection', 'nixSection');

    t1.set_metadata(s);
    t2.set_metadata(s);

    % test multiple arguments fail
    try
        s.referring_multi_tags('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referring_multi_tags(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testTag = s.referring_multi_tags(b1);
    assert(size(testTag, 2) == 1);
    assert(strcmp(testTag{1}.name, testName));
end

%% Test: referring sources
function [] = test_referring_sources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    s1 = b1.create_source('testSource1', 'nixSource');
    b2 = f.create_block('testBlock2', 'nixBlock');
    s2 = b2.create_source('testSource2', 'nixSource');
    s = f.create_section('testSection', 'nixSection');
    
    assert(isempty(s.referring_sources));

    s1.set_metadata(s);
    assert(~isempty(s.referring_sources));
    
    s2.set_metadata(s);
    assert(size(s.referring_sources, 1) == 2);
    
    b2.delete_source(s2);
    s1.set_metadata('');
    assert(isempty(s.referring_sources));
end

%% Test: referring block sources
function [] = test_referring_block_sources( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testSource1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    s1 = b1.create_source(testName, 'nixSource');
    b2 = f.create_block('testBlock2', 'nixBlock');
    s2 = b2.create_source('testSource2', 'nixSource');
    s = f.create_section('testSection', 'nixSection');

    s1.set_metadata(s);
    s2.set_metadata(s);

    % test multiple arguments fail
    try
        s.referring_sources('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referring_sources(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only sources from block 1
    testSource = s.referring_sources(b1);
    assert(size(testSource, 2) == 1);
    assert(strcmp(testSource{1}.name, testName));
end

%% Test: referring blocks
function [] = test_referring_blocks( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.create_block('testBlock1', 'nixBlock');
    b2 = f.create_block('testBlock2', 'nixBlock');
    s = f.create_section('testSection', 'nixSection');
    
    assert(isempty(s.referring_blocks));

    b1.set_metadata(s);
    assert(~isempty(s.referring_blocks));
    
    b2.set_metadata(s);
    assert(size(s.referring_blocks, 1) == 2);
    
    b2.set_metadata('')
    assert(size(s.referring_blocks, 1) == 1);
end

function [] = test_compare( varargin )
%% Test: Compare group entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s1 = f.create_section('testSection1', 'nixSection');
    s2 = f.create_section('testSection2', 'nixSection');

    assert(s1.compare(s2) < 0);
    assert(s1.compare(s1) == 0);
    assert(s2.compare(s1) > 0);
end