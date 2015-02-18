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

test parent

test props

test attrs

test has_section