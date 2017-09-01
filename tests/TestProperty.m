% TestProperty provides tests for all supported nix.Property methods.
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestProperty
    funcs = {};
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testUpdateValues;
    funcs{end+1} = @testValues;
    funcs{end+1} = @testValueCount;
    funcs{end+1} = @testDeleteValues;
    funcs{end+1} = @testCompare;
end

%% Test: Access Attributes
function [] = testAttributes( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('testSectionProperty', 'nixSection');
    p = s.createProperty('testProperty1', nix.DataType.String);

    assert(~isempty(p.id));
    assert(strcmpi(p.datatype, 'char'));
    assert(strcmp(p.name, 'testProperty1'));

    assert(isempty(p.definition));
    assert(isempty(p.unit));

    p.definition = 'property definition';
    p.unit = 'ms';
    assert(strcmp(p.definition, 'property definition'));
    assert(strcmp(p.unit, 'ms'));

    p.definition = 'next property definition';
    p.unit = 'mm';

    p.definition = '';
    p.unit = '';
    assert(isempty(p.definition));
    assert(isempty(p.unit));
end

%% Test: Access values
function [] = testValues( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');
    currProp = s.createPropertyWithValue('booleanProperty', {true, false, true});

    assert(size(currProp.values, 1) == 3);
    assert(currProp.values{1}.value);
    assert(currProp.values{1}.uncertainty == 0);
end

%% Test: Update values and uncertainty
function [] = testUpdateValues( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

    %-- test update boolean
    updateBool = s.createPropertyWithValue('booleanProperty', {true, false, true});
    assert(updateBool.values{1}.value);
    updateBool.values{1}.value = false;
    assert(~updateBool.values{1}.value);

    %-- test update string
    updateString = s.createPropertyWithValue('stringProperty', {'this', 'has', 'strings'});
    assert(strcmp(updateString.values{3}.value, 'strings'));
    updateString.values{3}.value = 'more strings';
    assert(strcmp(updateString.values{3}.value, 'more strings'));

    %-- test update double / test set uncertainty
    updateDouble = s.createPropertyWithValue('doubleProperty', {2, 3, 4, 5});
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
    updateNewDouble = s.createProperty('doubleProperty2', nix.DataType.Double);
    updateNewDouble.values = {val1, val2};
    assert(s.properties{end}.values{2}.value == val2.value);
end

%% Test: Value count
function [] = testValueCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.createSection('testSection', 'nixSection');
    p = s.createPropertyWithValue('booleanProperty', {true, false, true});

    assert(p.valueCount() == 3);
    p.values = {};
    assert(p.valueCount() == 0);
    p.values = {false};

    clear p s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.sections{1}.properties{1}.valueCount() == 1);
end

%% Test: Delete values
function [] = testDeleteValues( varargin )
    testFile = fullfile(pwd,'tests','testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s = f.createSection('testSection', 'nixSection');

    p = s.createPropertyWithValue('property1', {true, false, true});
    assert(~isempty(p.values));
    p.deleteValues();
    assert(isempty(p.values));

    clear p s f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(isempty(f.sections{1}.properties{1}.values));
end

%% Test: Compare Properties
function [] = testCompare( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    s1 = f.createSection('testSection1', 'nixSection');
    s2 = f.createSection('testSection2', 'nixSection');

    p = s1.createPropertyWithValue('property', {true, false, true});

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
    pNEq = s2.createPropertyWithValue('property', {true, false});
    assert(p.compare(pNEq) ~= 0);
end
