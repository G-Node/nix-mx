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
    funcs{end+1} = @test_parent;
    funcs{end+1} = @test_has_section;
    funcs{end+1} = @test_section_count;
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_properties;
    funcs{end+1} = @test_create_property;
    funcs{end+1} = @test_create_property_with_value;
    funcs{end+1} = @test_delete_property;
    funcs{end+1} = @test_open_property;
    funcs{end+1} = @test_property_count;
    funcs{end+1} = @test_link;
    funcs{end+1} = @test_inherited_properties;
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
