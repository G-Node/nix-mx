function funcs = testSection
%TESTFILE % Tests for the nix.Section object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_create_section;
    funcs{end+1} = @test_delete_section;
    funcs{end+1} = @test_list_subsections;
    funcs{end+1} = @test_open_section;
    funcs{end+1} = @test_parent;
    funcs{end+1} = @test_has_section;
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_properties;
    funcs{end+1} = @test_create_property_data_type;
    funcs{end+1} = @test_delete_property;
    funcs{end+1} = @test_open_property;
    funcs{end+1} = @test_link;
end

%% Test: Create Section
function [] = test_create_section( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    assert(isempty(s.sections));
    tmp = s.createSection('testSection1', 'nixSection');
    tmp = s.createSection('testSection2', 'nixSection');
    assert(size(s.sections, 1) == 2);
end

%% Test: Delete Section by entity or ID
function [] = test_delete_section( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');
    tmp = s.createSection('testSection1', 'nixSection');
    tmp = s.createSection('testSection2', 'nixSection');

    assert(s.deleteSection(s.sections{2}.id));
    assert(size(s.sections, 1) == 1);
    assert(s.deleteSection(s.sections{1}));
    assert(isempty(s.sections));

    assert(~s.deleteSection('I do not exist'));
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

function [] = test_attrs( varargin )
%% Test: Access Attributes / Links
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('foo', 'bar');

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
    assert(p1.values{1} == 1);
    
    assert(trial.allPropertiesMap('ExperimentalCondition') == p1.values{1});
    
    disp(f.sections{3}.allProperties);
    
    assert(isempty(f.sections{3}.allProperties));
end

%% Test: Create property by data type
function [] = test_create_property_data_type( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    tmp = s.create_property_data_type('newProperty1', nix.DataType.Double);
    tmp = s.create_property_data_type('newProperty2', nix.DataType.Boolean);
    tmp = s.create_property_data_type('newProperty3', nix.DataType.String);
    assert(size(s.allProperties, 1) == 3);
    assert(strcmp(s.allProperties{1}.name, 'newProperty1'));
end

%% Test: Delete property by entity, propertyStruct, ID and name
function [] = test_delete_property( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');
    tmp = s.create_property_data_type('newProperty1', nix.DataType.Double);
    tmp = s.create_property_data_type('newProperty2', nix.DataType.Boolean);
    tmp = s.create_property_data_type('newProperty3', nix.DataType.String);
    tmp = s.create_property_data_type('newProperty4', nix.DataType.Double);

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

%% Test: set, open and remove section link
function [] = test_link( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    mainSec = f.createSection('mainSection', 'nixSection');
    tmp = f.createSection('linkSection1', 'nixSection');
    tmp = f.createSection('linkSection2', 'nixSection');
    
    assert(isempty(mainSec.openLink));
    mainSec.set_link(f.sections{3}.id);
    assert(strcmp(mainSec.openLink.name, 'linkSection2'));
    mainSec.set_link(f.sections{2});
    assert(strcmp(mainSec.openLink.name, 'linkSection1'));
    
    mainSec.set_link('');
    assert(isempty(mainSec.openLink));
end
