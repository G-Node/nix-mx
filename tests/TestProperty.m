function funcs = TestProperty
%TESTPROPERTY % Tests for the nix.Property object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
end

%% Test: Access Attributes
function [] = test_attrs( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    s = f.createSection('testSectionProperty', 'nixSection');
    p = s.create_property_data_type('testProperty1', nix.DataType.String);

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
