% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestProperty
%TESTPROPERTY % Tests for the nix.Property object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_update_values;
    funcs{end+1} = @test_values;
    funcs{end+1} = @test_value_count;
    funcs{end+1} = @test_values_delete;
    funcs{end+1} = @test_property_compare;
end

%% Test: Access Attributes
function [] = test_attrs( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('testSectionProperty', 'nixSection');
    p = s.create_property('testProperty1', nix.DataType.String);

    assert(~isempty(p.id));
    assert(strcmpi(p.datatype, 'char'));
    assert(strcmp(p.name, 'testProperty1'));

    assert(isempty(p.definition));
    assert(isempty(p.unit));
    assert(isempty(s.mapping));

    p.definition = 'property definition';
    p.unit = 'ms';
    p.mapping = 'property mapping';
    assert(strcmp(p.definition, 'property definition'));
    assert(strcmp(p.unit, 'ms'));
    assert(strcmp(p.mapping, 'property mapping'));

    p.definition = 'next property definition';
    p.unit = 'mm';
    p.mapping = 'next property mapping';

    p.definition = '';
    p.unit = '';
    p.mapping = '';
    assert(isempty(p.definition));
    assert(isempty(p.unit));
    assert(isempty(s.mapping));
end

%% Test: Access values
function [] = test_values( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');
    currProp = s.create_property_with_value('booleanProperty', {true, false, true});

    assert(size(currProp.values, 1) == 3);
    assert(currProp.values{1}.value);
    assert(currProp.values{1}.uncertainty == 0);
end

%% Test: Update values and uncertainty
function [] = test_update_values( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.create_section('mainSection', 'nixSection');

    %-- test update boolean
    updateBool = s.create_property_with_value('booleanProperty', {true, false, true});
    assert(updateBool.values{1}.value);
    updateBool.values{1}.value = false;
    assert(~updateBool.values{1}.value);

    %-- test update string
    updateString = s.create_property_with_value('stringProperty', {'this', 'has', 'strings'});
    assert(strcmp(updateString.values{3}.value, 'strings'));
    updateString.values{3}.value = 'more strings';
    assert(strcmp(updateString.values{3}.value, 'more strings'));

    %-- test update double / test set uncertainty
    updateDouble = s.create_property_with_value('doubleProperty', {2, 3, 4, 5});
    assert(updateDouble.values{1}.value == 2);
    updateDouble.values{1}.value = 2.2;
    assert(updateDouble.values{1}.value == 2.2);

    assert(updateDouble.values{1}.uncertainty == 0);
    updateDouble.values{1}.uncertainty = 0.5;
    assert(f.sections{1}.properties{end}.values{1}.uncertainty == 0.5);
    assert(f.sections{1}.properties{1}.values{1}.uncertainty == 0);

    %-- test remove values from property
    delValues = s.properties{3};
    assert(size(delValues.values, 1) == 4);
    delValues.values = {};
    assert(size(delValues.values, 1) == 0);
    clear delValues;
    
    %-- test add new values to empty value property
    newValues = s.properties{3};
    newValues.values = [1,2,3,4,5];
    assert(newValues.values{5}.value == 5);
    newValues.values = {};
    newValues.values = {6,7,8};
    assert(newValues.values{3}.value == 8);
    
    %-- test add new values by value structure
    val1 = newValues.values{1};
    val2 = newValues.values{2};
    updateNewDouble = s.create_property('doubleProperty2', nix.DataType.Double);
    updateNewDouble.values = {val1, val2};
    assert(s.properties{end}.values{2}.value == val2.value);
end

%% Test: Value count
function [] = test_value_count( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.create_section('testSection', 'nixSection');
    p = s.create_property_with_value('booleanProperty', {true, false, true});

    assert(p.value_count() == 3);
    p.values = {};
    assert(p.value_count() == 0);
    p.values = {false};

    clear p s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.properties{1}.value_count() == 1);
end

%% Test: Delete values
function [] = test_values_delete( varargin )
    testFile = fullfile(pwd,'tests','testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.create_section('testSection', 'nixSection');

    p = s.create_property_with_value('property1', {true, false, true});
    assert(~isempty(p.values));
    p.values_delete();
    assert(isempty(p.values));

    clear p s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(isempty(f.sections{1}.properties{1}.values));
end

%% Test: Compare properties
function [] = test_property_compare( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s1 = f.create_section('testSection1', 'nixSection');
    s2 = f.create_section('testSection2', 'nixSection');

    p = s1.create_property_with_value('property', {true, false, true});

    % test invalid property comparison
    try
        p.compare('I shall crash and burn');
        err.identifier = 'Test:UnraisedError';
        error(err);
    catch ME
        msg = 'Only entities of the same class can be compared.';
        assert(strcmp(ME.message, msg), 'Compare exception fail');
    end

    % test property equal comparison
    assert(~p.compare(p));

    % test property not eqal
    pNEq = s2.create_property_with_value('property', {true, false});
    assert(p.compare(pNEq) ~= 0);
end
