function funcs = testSection
%TESTFILE % Tests for the nix.Section object
%   Detailed explanation goes here

    funcs{1} = @test_list_subsections;
    funcs{2} = @test_open_section;
    funcs{3} = @test_parent;
    funcs{4} = @test_has_section;
    funcs{5} = @test_attrs;
    funcs{6} = @test_properties;
end

function [] = test_list_subsections( varargin )
%% Test: List/fetch subsections
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(size(s1.list_sections(),1) == 4);
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
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};
    
    assert(strcmp(s1.name, 'Sessions'));
    assert(strcmp(s1.type, 'nix.metadata.section'));
    assert(isempty(s1.repository));
    assert(isempty(s1.mapping));
    
    subj = s1.sections{1}.sections{1}.link;
    assert(strcmp(subj.name, 'Subject'));
    
    emp_ty = s1.sections{1}.link;
    assert(isempty(emp_ty));
end

function [] = test_properties( varargin )
%% Test: Properties
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};
    
    assert(~isempty(trial.properties_cell));
    
    p1 = trial.properties_cell{1};
    assert(strcmp(p1.name, 'ExperimentalCondition'));
    assert(p1.values{1} == 1);
    
    assert(trial.properties_map('ExperimentalCondition') == p1.values{1});
    
    assert(isempty(f.sections{3}.properties_cell));
end
