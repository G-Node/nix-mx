% Tests for the nix.MultiTag object

%% Test: List/fetch references
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    assert(size(getMultiTag.list_references(), 1) == 1);
    disp('Test MultiTag: list references ... OK');

    assert(size(getMultiTag.references(), 1) == 1);
    disp('Test MultiTag: fetch references ... OK');
    
    clear; %-- close handles    
    
catch me
    disp('Test MultiTag: list/fetch references ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    assert(size(getMultiTag.list_sources(),1) == 1);
    disp('Test MultiTag: list sources from tag ... OK');

    assert(size(getMultiTag.sources(),1) == 1);
    disp('Test MultiTag: fetch sources ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test MultiTag: list/fetch sources ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch features
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getMultiTag.list_features(),1) == 0);
    disp('Test MultiTag: list features ... TODO (proper testfile)');

    assert(size(getMultiTag.features(),1) == 0);
    disp('Test MultiTag: fetch features ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test MultiTag: list/fetch features ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    getSourceByID = getMultiTag.open_source(getMultiTag.sources{1,1}.id);
    assert(strcmp(getSourceByID.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    disp('Test MultiTag: open source by ID ... OK');

    getSourceByName = getMultiTag.open_source(getMultiTag.sources{1,1}.name);
    assert(strcmp(getSourceByName.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    disp('Test MultiTag: open source by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test MultiTag: open source by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open feature by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    %-- TODO: implement testfile with feature referenced from a tag
    %getFeatByID = getMultiTag.open_feature(getMultiTag.features{1,1}.id);
    %assert(strcmp(getFeatByID.id, ''));
    disp('Test MultiTag: open feature by ID ... TODO (proper testfile)');

    %getFeatByName = getTag.open_feature(getTag.features{1,1}.name);
    %assert(strcmp(getFeatByName.id, ''));
    disp('Test MultiTag: open feature by name ... TODO (proper testfile)');
    
    clear; %-- close handles
    
catch me
    disp('Test MultiTag: open feature by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open reference by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    
    getRefByID = getMultiTag.open_reference(getMultiTag.references{1,1}.id);
    assert(strcmp(getRefByID.id, 'd21318e2-151e-4afd-afd3-1d86c8c20a85'));
    disp('Test MultiTag: open reference by ID ... OK');

    getRefByName = getMultiTag.open_reference(getMultiTag.references{1,1}.name);
    assert(strcmp(getRefByName.id, 'd21318e2-151e-4afd-afd3-1d86c8c20a85'));
    disp('Test MultiTag: open reference by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test MultiTag: open reference by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);

    %-- TODO: implement proper test for metadata once metadata is implemented
    assert(strcmp(getMultiTag.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test MultiTag: open metadata ... TODO');

catch me
    disp('Test MultiTag: open metadata ... ERROR');
    rethrow(me);
end;

