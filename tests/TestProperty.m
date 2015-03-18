function funcs = TestProperty
%TESTPROPERTY % Tests for the nix.Property object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_update_values;
    funcs{end+1} = @test_values;
end

%% Test: Access Attributes
function [] = test_attrs( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('testSectionProperty', 'nixSection');
    p = s.create_property('testProperty1', nix.DataType.String);

    assert(~isempty(p.id));
    assert(strcmpi(p.datatype, 'string'));
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
    s = f.createSection('mainSection', 'nixSection');
    currProp = s.create_property_with_value('booleanProperty', {true, false, true});

    assert(size(currProp.values, 1) == 3);
    assert(currProp.values{1}.value);
    assert(currProp.values{1}.uncertainty == 0);
    assert(isempty(currProp.values{1}.checksum));
    assert(isempty(currProp.values{1}.encoder));
    assert(isempty(currProp.values{1}.filename));
    assert(isempty(currProp.values{1}.reference));
end

%% Test: Update values
function [] = test_update_values( varargin )
    f = nix.File(fullfile(pwd,'tests','testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('mainSection', 'nixSection');

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

    %-- test update double
    updateDouble = s.create_property_with_value('doubleProperty', {2, 3, 4, 5});
    assert(updateDouble.values{1}.value == 2);
    updateDouble.values{1}.value = 2.2;
    assert(updateDouble.values{1}.value == 2.2);
end
