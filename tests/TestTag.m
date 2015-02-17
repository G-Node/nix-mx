% Tests for the nix.Tag object

%% Test: List references
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);

    assert(size(currTag.list_references(),1) == 1);
    clear; %-- close handles
    disp('Test list references from tag ... OK');
    
catch me
    disp('Test list references from tag ... ERROR');
    rethrow(me);
end;

%% Test: List sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(currTag.list_sources(),1) == 0);
    clear; %-- close handles
    disp('Test list sources from tag ... OK');
    
catch me
    disp('Test list sources from tag ... ERROR');
    rethrow(me);
end;

%% Test: List features
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(currTag.list_features(),1) == 0);
    clear; %-- close handles
    disp('Test list features from tag ... OK');
    
catch me
    disp('Test list features from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currSourceList = currTag.list_sources();
    
    %-- TODO: implement testfile with source referenced from a tag
    %currSourceByID = currTag.open_source(currSourceList(1,1).id);
    %assert(strcmp(currSourceByID.id, ''));
    clear; %-- close handles
    disp('Test open source by ID from tag ... TODO');
    
catch me
    disp('Test open source by ID from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open source by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currSourceList = currTag.list_sources();
    
    %-- TODO: implement testfile with source referenced from a tag
    %currSourceByName = currTag.open_source(currSourceList(1,1).name);
    %assert(strcmp(currSourceByName.name, ''));
    clear; %-- close handles
    disp('Test open source by name from tag ... TODO');
    
catch me
    disp('Test open source by name from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open feature by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currFeatList = currTag.list_features();
    
    %-- TODO: implement testfile with feature referenced from a tag
    %currFeatByID = currTag.open_feature(currFeatList(1,1).id);
    %assert(strcmp(currFeatByID.id, ''));
    clear; %-- close handles
    disp('Test open feature by ID from tag ... TODO');
    
catch me
    disp('Test open feature by ID from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open feature by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currFeatList = currTag.list_features();
    
    %-- TODO: implement testfile with feature referenced from a tag
    %currFeatByName = currTag.open_feature(currFeatList(1,1).name);
    %assert(strcmp(currFeatByName.name, ''));
    clear; %-- close handles
    disp('Test open feature by name from tag ... TODO');
    
catch me
    disp('Test open feature by name from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open reference by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currRefList = currTag.list_references();
    currRefByID = currTag.open_reference(currRefList(1,1).id);

    assert(strcmp(currRefByID.id, '75138768-edc3-482e-894d-301f1dd66f8d'));
    clear; %-- close handles
    disp('Test open reference by ID from tag ... OK');
    
catch me
    disp('Test open reference by ID from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open reference by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);
    currRefList = currTag.list_references();
    currRefByName = currTag.open_reference(currRefList(1,1).name);

    assert(strcmp(currRefByName.name, 'SpikeActivity Unit 5 Trial 004'));
    clear; %-- close handles
    disp('Test open reference by name from tag ... OK');
    
catch me
    disp('Test open reference by name from tag ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    currBlock = test_file.openBlock(currBlockList(1,1).name);
    currTagList = currBlock.list_tags();
    currTag = currBlock.open_tag(currTagList(1,1).id);

    %-- TODO: implement proper test for metadata once metadata is implemented
    assert(strcmp(currTag.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test open metadata from tag ... TODO');

catch me
    disp('Test open metadata from tag ... ERROR');
    rethrow(me);
end;

