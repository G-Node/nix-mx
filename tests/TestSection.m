% Tests for the nix.Section object

%% Test: List/fetch subsections
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(size(s1.list_sections(),1) == 4);
    disp('Test Section: fetch subsections ... OK');

    assert(size(s1.sections, 1) == 4);
    disp('Test Section: list subsections ... OK');
   
    clear; %-- close handles
    
catch me
    disp('Test Section: list/fetch subsections ... ERROR');
    rethrow(me);
end;

%% Test: Open subsection by ID or name
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    sid = s1.sections{1}.id;
    s2 = s1.open_section(sid);
    assert(strcmp(s2.id, sid));
    disp('Test Section: open subsection by ID ... OK');

    name = s1.sections{1}.name;
    s2 = s1.open_section(name);
    assert(strcmp(s2.id, s1.sections{1}.id));
    disp('Test Section: open subsection by name ... OK');

    clear; %-- close handles
    
catch me
    disp('Test Section: open subsection by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: get parent section
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};

    assert(isempty(s1.parent));
    disp('Test Section: root section parent ... OK');

    s2 = s1.sections{1};
    assert(strcmp(s2.parent.id, s1.id));
    disp('Test Section: child section parent ... OK');

    clear; %-- close handles
    
catch me
    disp('Test Section: get parent ... ERROR');
    rethrow(me);
end;

%% Test: Has Section
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    root = f.sections{3};
    child = root.sections{1};

    assert(root.has_section(child.id));
    disp('Test Section: has child ... OK');
    
    assert(~root.has_section('whatever'));
    disp('Test Section: has no nonexistent child ... OK');
    
    clear; %-- close handles

catch me
    disp('Test Section: has Section ... ERROR');
    rethrow(me);
end;

%% Test: Access Attributes / Links
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    s1 = f.sections{3};
    
    assert(strcmp(s1.name, 'Sessions'));
    assert(strcmp(s1.type, 'nix.metadata.section'));
    assert(isempty(s1.repository));
    assert(isempty(s1.mapping));
    disp('Test Section: attributes ... OK');
    
    subj = s1.sections{1}.sections{1}.link;
    assert(strcmp(subj.name, 'Subject'));
    
    emp_ty = s1.sections{1}.link;
    assert(isempty(emp_ty));
    disp('Test Section: linking ... OK');
    
    clear; %-- close handles

catch me
    disp('Test Section: attributes ... ERROR');
    rethrow(me);
end;

%% Test: Properties
try
    clear; %-- ensure clean workspace
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    trial = f.sections{2}.sections{2}.sections{1};
    
    assert(~isempty(trial.props));
    
    p1 = trial.props{1};
    assert(strcmp(p1.name, 'ExperimentalCondition'));
    assert(p1.values{1} == 1);
    
    assert(isempty(f.sections{3}.props));
    
    clear; %-- close handles

catch me
    disp('Test Section: attributes ... ERROR');
    rethrow(me);
end;