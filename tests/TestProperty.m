function funcs = TestProperty
%TESTPROPERTY % Tests for the nix.Property object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
end

%% Test: Access Attributes
function [] = test_attrs( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s = f.sections{2}.sections{2}.sections{1};
    p = s.open_property(s.allProperties{1}.id);

    assert(~isempty(p.id));

    assert(strcmp(p.name, 'ExperimentalCondition'));
    assert(isempty(p.definition));
    assert(isempty(p.unit));
    assert(isempty(s.mapping));
end
