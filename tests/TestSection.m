% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestSection
% TESTSECTION Tests for the nix.Section object

    funcs = {};
    funcs{end+1} = @testCreateSection;
    funcs{end+1} = @testDeleteSection;
    funcs{end+1} = @testListSubsections;
    funcs{end+1} = @testOpenSection;
    funcs{end+1} = @testOpenSectionIdx;
    funcs{end+1} = @testParent;
    funcs{end+1} = @testHasSection;
    funcs{end+1} = @testSectionCount;
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testProperties;
    funcs{end+1} = @testCreateProperty;
    funcs{end+1} = @testCreatePropertyWithValue;
    funcs{end+1} = @testDeleteProperty;
    funcs{end+1} = @testOpenProperty;
    funcs{end+1} = @testOpenPropertyIdx;
    funcs{end+1} = @testPropertyCount;
    funcs{end+1} = @testLink;
    funcs{end+1} = @testInheritedProperties;
    funcs{end+1} = @testReferringDataArrays;
    funcs{end+1} = @testReferringBlockDataArrays;
    funcs{end+1} = @testReferringTags;
    funcs{end+1} = @testReferringBlockTags;
    funcs{end+1} = @testReferringMultiTags;
    funcs{end+1} = @testReferringBlockMultiTags;
    funcs{end+1} = @testReferringSources;
    funcs{end+1} = @testReferringBlockSources;
    funcs{end+1} = @testReferringBlocks;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSection;
    funcs{end+1} = @testFilterProperty;
    funcs{end+1} = @testFindSection;
    funcs{end+1} = @testFilterFindSections;
    funcs{end+1} = @testFindRelated;
end

%% Test: Create Section
function [] = testCreateSection( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    assert(isempty(s.sections));
    tmp = s.createSection('testSection1', 'nixSection');
    tmp = s.createSection('testSection2', 'nixSection');
    assert(size(s.sections, 1) == 2);
end

%% Test: Delete Section by entity or ID
function [] = testDeleteSection( varargin )
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

function [] = testListSubsections( varargin )
%% Test: List/fetch subsections
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(size(s1.sections, 1) == 4);
end

function [] = testOpenSection( varargin )
%% Test: Open subsection by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    sid = s1.sections{1}.id;
    s2 = s1.openSection(sid);
    assert(strcmp(s2.id, sid));

    name = s1.sections{1}.name;
    s2 = s1.openSection(name);
    assert(strcmp(s2.id, s1.sections{1}.id));
    
    %-- test open non existing section
    getSection = s1.openSection('I dont exist');
    assert(isempty(getSection));
end

function [] = testOpenSectionIdx( varargin )
%% Test Open Section by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('testSection', 'nixSection');
    s1 = s.createSection('testSection1', 'nixSection');
    s2 = s.createSection('testSection2', 'nixSection');
    s3 = s.createSection('testSection3', 'nixSection');

    assert(strcmp(f.sections{1}.openSectionIdx(1).name, s1.name));
    assert(strcmp(f.sections{1}.openSectionIdx(2).name, s2.name));
    assert(strcmp(f.sections{1}.openSectionIdx(3).name, s3.name));
end

function [] = testParent( varargin )
%% Test: get parent section
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(isempty(s1.parent));

    s2 = s1.sections{1};
    assert(strcmp(s2.parent.id, s1.id));
end

function [] = testHasSection( varargin )
%% Test: Has Section
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    root = f.sections{3};
    child = root.sections{1};

    assert(root.hasSection(child.id));
    assert(~root.hasSection('whatever'));
end

%% Test: Section count
function [] = testSectionCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    assert(s.sectionCount() == 0);
    tmp = s.createSection('testSection1', 'nixSection');
    assert(s.sectionCount() == 1);
    tmp = s.createSection('testSection2', 'nixSection');

    clear tmp s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.sectionCount() == 2);
end


function [] = testAttributes( varargin )
%% Test: Access Attributes / Links
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('foo', 'bar');

    assert(~isempty(s.id));

    assert(strcmp(s.name, 'foo'));
    assert(strcmp(s.type, 'bar'));
    assert(isempty(s.repository));
    assert(isempty(s.definition));

    s.type = 'nixBlock';
    s.definition = 'section definition';
    s.repository = 'rep1';
    assert(strcmp(s.type, 'nixBlock'));
    assert(strcmp(s.definition, 'section definition'));
    assert(strcmp(s.repository, 'rep1'));

    s.definition = '';
    s.repository = '';
    assert(isempty(s.definition));
    assert(isempty(s.repository));
end

function [] = testProperties( varargin )
%% Test: Properties
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};

    assert(~isempty(trial.properties));
    assert(strcmp(trial.properties{1}.name, 'ExperimentalCondition'));
    assert(isempty(f.sections{3}.properties));
end

%% Test: Create property by data type
function [] = testCreateProperty( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    s.createProperty('newProperty1', nix.DataType.Double);
    s.createProperty('newProperty2', nix.DataType.Bool);
    s.createProperty('newProperty3', nix.DataType.String);
    assert(size(s.properties, 1) == 3);
    assert(strcmp(s.properties{1}.name, 'newProperty1'));
end

%% Test: Create property with value
function [] = testCreatePropertyWithValue( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    % test create by array
    s.createPropertyWithValue('doubleProperty1', [5, 6, 7, 8]);
    assert(strcmp(s.properties{end}.name, 'doubleProperty1'));
    assert(s.properties{end}.values{1}.value == 5);
    assert(size(s.properties{end}.values, 1) == 4);
    assert(strcmpi(s.properties{end}.datatype, 'double'));

    % test create by cell array
    s.createPropertyWithValue('doubleProperty2', {5, 6, 7, 8});
    assert(strcmp(s.properties{end}.name, 'doubleProperty2'));
    assert(s.properties{end}.values{2}.value == 6);
    assert(size(s.properties{end}.values, 1) == 4);
    assert(strcmpi(s.properties{end}.datatype, 'double'));

    s.createPropertyWithValue('stringProperty1', ['a', 'string']);
    assert(strcmp(s.properties{end}.name, 'stringProperty1'));
    assert(strcmp(s.properties{end}.values{1}.value, 'a'));
    assert(size(s.properties{end}.values, 1) == 7);
    assert(strcmpi(s.properties{end}.datatype, 'char'));

    s.createPropertyWithValue('stringProperty2', {'this', 'has', 'strings'});
    assert(strcmp(s.properties{end}.name, 'stringProperty2'));
    assert(strcmp(s.properties{end}.values{1}.value, 'this'));
    assert(size(s.properties{end}.values, 1) == 3);
    assert(strcmpi(s.properties{end}.datatype, 'char'));

    s.createPropertyWithValue('booleanProperty1', [true, false, true]);
    assert(strcmp(s.properties{end}.name, 'booleanProperty1'));
    assert(s.properties{end}.values{1}.value);
    assert(~s.properties{end}.values{2}.value);
    assert(size(s.properties{end}.values, 1) == 3);
    assert(strcmpi(s.properties{end}.datatype, 'logical'));

    s.createPropertyWithValue('booleanProperty2', {true, false, true});
    assert(strcmp(s.properties{end}.name, 'booleanProperty2'));
    assert(s.properties{end}.values{1}.value);
    assert(~s.properties{end}.values{2}.value);
    assert(size(s.properties{end}.values, 1) == 3);
    assert(strcmpi(s.properties{end}.datatype, 'logical'));

    val1 = s.properties{1}.values{1};
    val2 = s.properties{1}.values{2};
    s.createPropertyWithValue('doubleByStrunct1', [val1, val2]);
    assert(strcmp(s.properties{end}.name, 'doubleByStrunct1'));
    assert(s.properties{end}.values{1}.value == 5);
    assert(size(s.properties{end}.values, 1) == 2);
    assert(strcmpi(s.properties{end}.datatype, 'double'));
    
    val3 = s.properties{1}.values{3};
    s.createPropertyWithValue('doubleByStrunct2', {val1, val2, val3});
    assert(strcmp(s.properties{end}.name, 'doubleByStrunct2'));
    assert(s.properties{end}.values{3}.value == 7);
    assert(size(s.properties{end}.values, 1) == 3);
    assert(strcmpi(s.properties{end}.datatype, 'double'));
end

%% Test: Delete property by entity, propertyStruct, ID and name
function [] = testDeleteProperty( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');
    s.createProperty('newProperty1', nix.DataType.Double);
    s.createProperty('newProperty2', nix.DataType.Bool);
    s.createProperty('newProperty3', nix.DataType.String);
    s.createProperty('newProperty4', nix.DataType.Double);

    assert(s.deleteProperty('newProperty4'));
    assert(s.deleteProperty(s.properties{3}.id));
    delProp = s.properties{2};
    assert(s.deleteProperty(delProp));
    assert(s.deleteProperty(s.properties{1}));

    assert(~s.deleteProperty('I do not exist'));
end

%% Test: Open property by ID and name
function [] = testOpenProperty( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};

    assert(~isempty(trial.openProperty(trial.properties{1}.id)));
    assert(~isempty(trial.openProperty(trial.properties{1}.name)));
end

function [] = testOpenPropertyIdx( varargin )
%% Test Open Propery by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('testSection', 'nixSection');
    p1 = s.createProperty('testProperty1', nix.DataType.Double);
    p2 = s.createProperty('testProperty2', nix.DataType.Bool);
    p3 = s.createProperty('testProperty3', nix.DataType.String);

    assert(strcmp(f.sections{1}.openPropertyIdx(1).name, p1.name));
    assert(strcmp(f.sections{1}.openPropertyIdx(2).name, p2.name));
    assert(strcmp(f.sections{1}.openPropertyIdx(3).name, p3.name));
end

%% Test: Property count
function [] = testPropertyCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    assert(s.propertyCount() == 0);
    tmp = s.createProperty('newProperty1', nix.DataType.Double);
    assert(s.propertyCount() == 1);
    tmp = s.createProperty('newProperty2', nix.DataType.Bool);

    clear tmp s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.propertyCount() == 2);
end

%% Test: set, open and remove section link
function [] = testLink( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    mainSec = f.createSection('mainSection', 'nixSection');
    tmp = f.createSection('linkSection1', 'nixSection');
    tmp = f.createSection('linkSection2', 'nixSection');
    
    assert(isempty(mainSec.openLink));
    mainSec.setLink(f.sections{3}.id);
    assert(strcmp(mainSec.openLink.name, 'linkSection2'));
    mainSec.setLink(f.sections{2});
    assert(strcmp(mainSec.openLink.name, 'linkSection1'));
    
    mainSec.setLink('');
    assert(isempty(mainSec.openLink));
end

%% Test: inherited properties
function [] = testInheritedProperties( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');
    ls = f.createSection('linkSection', 'nixSection');
    
    assert(isempty(s.inheritedProperties));

    s.setLink(ls);
    assert(isempty(s.inheritedProperties));

    lp = ls.createProperty('testProperty2', nix.DataType.String);
    assert(~isempty(s.inheritedProperties));
    assert(strcmp(s.inheritedProperties{1}.name, lp.name));
    
    s.createProperty('testProperty1', nix.DataType.String);
    assert(size(s.inheritedProperties, 1) == 2);
end

%% Test: referring data arrays
function [] = testReferringDataArrays( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    d1 = b1.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d2 = b2.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = f.createSection('testSection', 'nixSection');
    
    assert(isempty(s.referringDataArrays));

    d1.setMetadata(s);
    assert(~isempty(s.referringDataArrays));
    
    d2.setMetadata(s);
    assert(size(s.referringDataArrays, 1) == 2);
    
    b2.deleteDataArray(d2);
    d1.setMetadata('');
    assert(isempty(s.referringDataArrays));
end

%% Test: referring block data arrays
function [] = testReferringBlockDataArrays( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testDataArray1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    d1 = b1.createDataArray(testName, 'nixDataArray', nix.DataType.Double, [1 2]);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d2 = b2.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = f.createSection('testSection', 'nixSection');
    
    d1.setMetadata(s);
    d2.setMetadata(s);

    % test multiple arguments fail
    try
        s.referringDataArrays('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referringDataArrays(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testDataArray = s.referringDataArrays(b1);
    assert(size(testDataArray, 2) == 1);
    assert(strcmp(testDataArray{1}.name, testName));
end

%% Test: referring tags
function [] = testReferringTags( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    t1 = b1.createTag('testTag1', 'nixTag', [1, 2]);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    t2 = b2.createTag('testTag2', 'nixTag', [3, 4]);
    s = f.createSection('testSection', 'nixSection');
    
    assert(isempty(s.referringTags));

    t1.setMetadata(s);
    assert(~isempty(s.referringTags));
    
    t2.setMetadata(s);
    assert(size(s.referringTags, 1) == 2);
    
    b2.deleteTag(t2);
    t1.setMetadata('');
    assert(isempty(s.referringTags));
end

%% Test: referring block tags
function [] = testReferringBlockTags( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testTag1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    t1 = b1.createTag(testName, 'nixTag', [1, 2]);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    t2 = b2.createTag('testTag2', 'nixTag', [3, 4]);
    s = f.createSection('testSection', 'nixSection');

    t1.setMetadata(s);
    t2.setMetadata(s);

    % test multiple arguments fail
    try
        s.referringTags('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referringTags(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testTag = s.referringTags(b1);
    assert(size(testTag, 2) == 1);
    assert(strcmp(testTag{1}.name, testName));
end

%% Test: referring multi tags
function [] = testReferringMultiTags( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    d = b1.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b1.createMultiTag('testMultiTag1', 'nixMultiTag', d);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d = b2.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    t2 = b2.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    s = f.createSection('testSection', 'nixSection');
    
    assert(isempty(s.referringMultiTags));

    t1.setMetadata(s);
    assert(~isempty(s.referringMultiTags));
    
    t2.setMetadata(s);
    assert(size(s.referringMultiTags, 1) == 2);
    
    b2.deleteMultiTag(t2);
    t1.setMetadata('');
    assert(isempty(s.referringMultiTags));
end

%% Test: referring block multi tags
function [] = testReferringBlockMultiTags( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testMultiTag1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    d = b1.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b1.createMultiTag(testName, 'nixMultiTag', d);
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d = b2.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    t2 = b2.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    s = f.createSection('testSection', 'nixSection');

    t1.setMetadata(s);
    t2.setMetadata(s);

    % test multiple arguments fail
    try
        s.referringMultiTags('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referringMultiTags(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only tags from block 1
    testTag = s.referringMultiTags(b1);
    assert(size(testTag, 2) == 1);
    assert(strcmp(testTag{1}.name, testName));
end

%% Test: referring sources
function [] = testReferringSources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    s1 = b1.createSource('testSource1', 'nixSource');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    s2 = b2.createSource('testSource2', 'nixSource');
    s = f.createSection('testSection', 'nixSection');
    
    assert(isempty(s.referringSources));

    s1.setMetadata(s);
    assert(~isempty(s.referringSources));
    
    s2.setMetadata(s);
    assert(size(s.referringSources, 1) == 2);
    
    b2.deleteSource(s2);
    s1.setMetadata('');
    assert(isempty(s.referringSources));
end

%% Test: referring block sources
function [] = testReferringBlockSources( varargin )
    err = 'Provide either empty arguments or a single Block entity';
    testName = 'testSource1';

    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    s1 = b1.createSource(testName, 'nixSource');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    s2 = b2.createSource('testSource2', 'nixSource');
    s = f.createSection('testSection', 'nixSection');

    s1.setMetadata(s);
    s2.setMetadata(s);

    % test multiple arguments fail
    try
        s.referringSources('a', 'b');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test non block entity argument fail
    try
        s.referringSources(s);
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test return only sources from block 1
    testSource = s.referringSources(b1);
    assert(size(testSource, 2) == 1);
    assert(strcmp(testSource{1}.name, testName));
end

%% Test: referring blocks
function [] = testReferringBlocks( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    s = f.createSection('testSection', 'nixSection');
    
    assert(isempty(s.referringBlocks));

    b1.setMetadata(s);
    assert(~isempty(s.referringBlocks));
    
    b2.setMetadata(s);
    assert(size(s.referringBlocks, 1) == 2);
    
    b2.setMetadata('')
    assert(size(s.referringBlocks, 1) == 1);
end

function [] = testCompare( varargin )
%% Test: Compare group entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s1 = f.createSection('testSection1', 'nixSection');
    s2 = f.createSection('testSection2', 'nixSection');

    assert(s1.compare(s2) < 0);
    assert(s1.compare(s1) == 0);
    assert(s2.compare(s1) > 0);
end

%% Test: filter Sections
function [] = testFilterSection( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    ms = f.createSection('testSection', 'nixSection');
    s = ms.createSection(filterName, 'nixSection');
    filterID = s.id;
	s = ms.createSection('testSection1', filterType);
    filterIDs = {filterID, s.id};
    s = ms.createSection('testSection2', filterType);

    % ToDO add basic filter crash tests
    
    % test empty id filter
    assert(isempty(f.sections{1}.filterSections(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.sections{1}.filterSections(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.sections{1}.filterSections(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.sections{1}.filterSections(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.sections{1}.filterSections(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.sections{1}.filterSections(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);
    
    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.sections{1}.filterSections(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end
    
    % test fail on nix.Filter.source
    try
        f.sections{1}.filterSections(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end
end

%% Test: filter properties
function [] = testFilterProperty( varargin )
    filterName = 'filterMe';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    ms = f.createSection('testSection', 'nixSection');
    p = ms.createProperty(filterName, nix.DataType.Double);
    filterID = p.id;
	s = ms.createProperty('testProperty', nix.DataType.Bool);
    filterIDs = {filterID, s.id};
    
    % test empty id filter
    assert(isempty(f.sections{1}.filterProperties(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.sections{1}.filterProperties(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 2);
    
    % test nix.Filter.id
    filtered = f.sections{1}.filterProperties(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.sections{1}.filterProperties(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));

    % test nix.Filter.name
    filtered  = f.sections{1}.filterProperties(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));

    % test fail on nix.Filter.type
    err = 'unknown or unsupported filter';
    try
        f.sections{1}.filterProperties(nix.Filter.type, 'someType');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.sections{1}.filterProperties(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        f.sections{1}.filterProperties(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end
end

%% Test: Find sections w/o filter
function [] = testFindSection
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    main = f.createSection('testSection', 'nixSection');
    sl1 = main.createSection('sectionLvl1', 'nixSection');

    sl21 = sl1.createSection('sectionLvl2_1', 'nixSection');
    sl22 = sl1.createSection('sectionLvl2_2', 'nixSection');

    sl31 = sl21.createSection('sectionLvl3_1', 'nixSection');
    sl32 = sl21.createSection('sectionLvl3_2', 'nixSection');
    sl33 = sl21.createSection('sectionLvl3_3', 'nixSection');

    sl41 = sl31.createSection('sectionLvl4_1', 'nixSection');
    sl42 = sl31.createSection('sectionLvl4_2', 'nixSection');
    sl43 = sl31.createSection('sectionLvl4_3', 'nixSection');
    sl44 = sl31.createSection('sectionLvl4_4', 'nixSection');

    side = f.createSection('sideSection', 'nixSection');
    side1 = side.createSection('sideSubSection', 'nixSection');

    % Check invalid entry
    err = 'Provide a valid search depth';
    try
        sl1.findSections('hurra');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % find all
    filtered = sl1.findSections(5);
    assert(size(filtered, 1) == 10);

    % find until level 4
    filtered = sl1.findSections(4);
    assert(size(filtered, 1) == 10);

    % find until level 3
    filtered = sl1.findSections(3);
    assert(size(filtered, 1) == 6);

    % find until level 2
    filtered = sl1.findSections(2);
    assert(size(filtered, 1) == 3);

    % find until level 1
    filtered = sl1.findSections(1);
    assert(size(filtered, 1) == 1);
end

%% Test: Find sections with filters
function [] = testFilterFindSections
    findSection = 'nixFindSection';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    main = f.createSection('testSection', 'nixSection');
    sl1 = main.createSection('sectionLvl1', 'nixSection');

    sl21 = sl1.createSection('sectionLvl2_1', 'nixSection');
    sl22 = sl1.createSection('sectionLvl2_2', findSection);

    sl31 = sl21.createSection('sectionLvl3_1', findSection);
    sl32 = sl21.createSection('sectionLvl3_2', 'nixSection');
    sl33 = sl21.createSection('sectionLvl3_3', 'nixSection');

    sl41 = sl31.createSection('sectionLvl4_1', findSection);
    sl42 = sl31.createSection('sectionLvl4_2', 'nixSection');
    sl43 = sl31.createSection('sectionLvl4_3', 'nixSection');
    sl44 = sl31.createSection('sectionLvl4_4', 'nixSection');

    sideName = 'sideSubSection';
    side = f.createSection('sideSection', 'nixSection');
    side1 = side.createSection(sideName, 'nixSection');

    % test find by id
    filtered = sl1.filterFindSections(1, nix.Filter.id, sl41.id);
    assert(isempty(filtered));
    filtered = sl1.filterFindSections(4, nix.Filter.id, sl41.id);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, sl41.id));

    % test find by ids
    filterids = {sl1.id, sl41.id};
    filtered = sl1.filterFindSections(1, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 1);
    filtered = sl1.filterFindSections(4, nix.Filter.ids, filterids);
    assert(size(filtered, 1) == 2);

    % test find by name
    filtered = sl1.filterFindSections(5, nix.Filter.name, sideName);
    assert(isempty(filtered));
    filtered = sl1.filterFindSections(1, nix.Filter.name, sl41.name);
    assert(isempty(filtered));
    filtered = sl1.filterFindSections(4, nix.Filter.name, sl41.name);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, sl41.name));

    % test find by type
    filtered = sl1.filterFindSections(1, nix.Filter.type, findSection);
    assert(isempty(filtered));
    filtered = sl1.filterFindSections(4, nix.Filter.type, findSection);
    assert(size(filtered, 1) == 3);
    assert(strcmp(filtered{1}.type, findSection));

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        sl1.filterFindSections(1, nix.Filter.metadata, 'metadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        sl1.filterFindSections(1, nix.Filter.source, 'source');
    catch ME
        assert(strcmp(ME.message, err));
    end
end

%% Test: Find sections related to the current section
function [] = testFindRelated
    findSectionType = 'nixFindSection';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    main = f.createSection('testSection', 'nixSection');
    sl1 = main.createSection('sectionLvl1', 'nixSection');

    sl21 = sl1.createSection('sectionLvl2_1', findSectionType);
    sl22 = sl1.createSection('sectionLvl2_2', findSectionType);

    sl31 = sl21.createSection('sectionLvl3_1', findSectionType);
    sl32 = sl21.createSection('sectionLvl3_2', 'nixSection');
    sl33 = sl21.createSection('sectionLvl3_3', 'nixSection');

    sl41 = sl31.createSection('sectionLvl4_1', findSectionType);
    sl42 = sl31.createSection('sectionLvl4_2', findSectionType);
    sl43 = sl31.createSection('sectionLvl4_3', 'nixSection');
    sl44 = sl31.createSection('sectionLvl4_4', 'nixSection');

    sideName = 'sideSubSection';
    side = f.createSection('sideSection', 'nixSection');
    side1 = side.createSection(sideName, 'nixSection');

    % find first downstream by id
    rel = sl21.findRelated(nix.Filter.id, sl44.id);
    assert(size(rel, 1) == 1);

    % find first updstream by ids
    rel = sl33.findRelated(nix.Filter.ids, {sl21.id, sl1.id});
    assert(size(rel, 1) == 1);

    % find first downstream by name, one occurrence
    rel = sl21.findRelated(nix.Filter.name, 'sectionLvl4_4');
    assert(size(rel, 1) == 1);

    % find first downstream by type, one occurrence
    rel = sl21.findRelated(nix.Filter.type, findSectionType);
    assert(size(rel, 1) == 1);

    % find first downstream by type, multiple occurrences
    rel = sl31.findRelated(nix.Filter.type, findSectionType);
    assert(size(rel, 1) == 2);

    % find first upstream by name, one occurrence
    rel = sl31.findRelated(nix.Filter.name, 'sectionLvl2_1');
    assert(size(rel, 1) == 1);

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        sl1.findRelated(nix.Filter.metadata, 'metadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        sl1.findRelated(nix.Filter.source, 'source');
    catch ME
        assert(strcmp(ME.message, err));
    end
end
