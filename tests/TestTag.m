% Tests for the nix.Tag object

%% Test: List/fetch references
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    assert(size(getTag.list_references(), 1) == 1);
    disp('Test Tag: list references ... OK');

    assert(size(getTag.references(), 1) == 1);
    disp('Test Tag: fetch references ... OK');
    
    clear; %-- close handles    
    
catch me
    disp('Test Tag: list/fetch references ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.list_sources(),1) == 0);
    disp('Test Tag: list sources from tag ... TODO (proper testfile)');

    assert(size(getTag.sources(),1) == 0);
    disp('Test Tag: fetch sources ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test Tag: list/fetch sources ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch features
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.list_features(),1) == 0);
    disp('Test Tag: list features ... TODO (proper testfile)');

    assert(size(getTag.features(),1) == 0);
    disp('Test Tag: fetch features ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test Tag: list/fetch features ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with source referenced from a tag
    %getSourceByID = getTag.open_source(getTag.sources{1,1}.id);
    %assert(strcmp(getSourceByID.id, ''));
    disp('Test Tag: open source by ID ... TODO (proper testfile)');

    %getSourceByName = getTag.open_source(getTag.sources{1,1}.name);
    %assert(strcmp(getSourceByName.id, ''));
    disp('Test Tag: open source by name ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test Tag: open source by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open feature by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with feature referenced from a tag
    %getFeatByID = getTag.open_feature(getTag.features{1,1}.id);
    %assert(strcmp(getFeatByID.id, ''));
    disp('Test Tag: open feature by ID ... TODO (proper testfile)');

    %getFeatByName = getTag.open_feature(getTag.features{1,1}.name);
    %assert(strcmp(getFeatByName.id, ''));
    disp('Test Tag: open feature by name ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test Tag: open feature by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open reference by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    getRefByID = getTag.open_reference(getTag.references{1,1}.id);
    assert(strcmp(getRefByID.id, '75138768-edc3-482e-894d-301f1dd66f8d'));
    disp('Test Tag: open reference by ID ... OK');

    getRefByName = getTag.open_reference(getTag.references{1,1}.name);
    assert(strcmp(getRefByName.id, '75138768-edc3-482e-894d-301f1dd66f8d'));
    disp('Test Tag: open reference by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Tag: open reference by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- TODO: implement proper test for metadata once metadata is implemented
    assert(strcmp(getTag.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test Tag: open metadata ... TODO');

catch me
    disp('Test Tag: open metadata ... ERROR');
    rethrow(me);
end;

