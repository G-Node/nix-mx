function funcs = TestProperty
%TESTPROPERTY % Tests for the nix.Property object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
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
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};
    currProp = trial.open_property(trial.allProperties{1}.id);

    assert(size(currProp.values, 1) == 1);
    assert(currProp.values{1}.value == 1);
    assert(currProp.values{1}.uncertainty == 0);
    assert(isempty(currProp.values{1}.checksum));
    assert(isempty(currProp.values{1}.encoder));
    assert(isempty(currProp.values{1}.filename));
    assert(isempty(currProp.values{1}.reference));
    
    disp('Test Property: access values ... TODO (multiple property values)');
end
