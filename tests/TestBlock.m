% Tests for the nix.Block object

%% Test: List data arrays
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    assert(size(getBlock.data_arrays(),1) == 198);
    clear; %-- close handles
    disp('Test list data array from block ... OK');
    
catch me
    disp('Test list data array from block ... ERROR');
    rethrow(me);
end;

%% Test: List sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    assert(size(getBlock.list_sources(),1) == 1);
    clear; %-- close handles
    disp('Test list sources from block ... OK');
    
catch me
    disp('Test list sources from block ... ERROR');
    rethrow(me);
end;

%% Test: List tags
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    assert(size(getBlock.list_tags(),1) == 198);
    clear; %-- close handles
    disp('Test list tags from block ... OK');
    
catch me
    disp('Test list tags from block ... ERROR');
    rethrow(me);
end;

%% Test: List multitags
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    assert(size(getBlock.list_multi_tags(),1) == 99);
    clear; %-- close handles
    disp('Test list multi tags from block ... OK');
    
catch me
    disp('Test list multi tags from block ... ERROR');
    rethrow(me);
end;

%% Test: Open data array by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currDataArrayList = getBlock.data_arrays();
    getDataArrayByID = getBlock.data_array(currDataArrayList(1,1).id);
    
    assert(strcmp(getDataArrayByID.id, 'e0ca39b7-632f-47c9-968c-c65e6db58719'));
    clear; %-- close handles
    disp('Test open data array by ID from block ... OK');
    
catch me
    disp('Test open data array by ID from block ... ERROR');
    rethrow(me);
end;

%% Test: Open data array by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currDataArrayList = getBlock.data_arrays();
    getDataArrayByName = getBlock.data_array(currDataArrayList(1,1).name);
    
    assert(strcmp(getDataArrayByName.id, 'e0ca39b7-632f-47c9-968c-c65e6db58719'));
    clear; %-- close handles
    disp('Test open data array by name from block ... OK');
    
catch me
    disp('Test open data array by name from block ... ERROR');
    rethrow(me);
end;

%% Test: Open tag by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currTagList = getBlock.list_tags();
    getTagByID = getBlock.open_tag(currTagList(1,1).id);
    
    assert(strcmp(getTagByID.id, 'f49f4a56-0c93-4323-8e37-4b02b8cabb55'));
    clear; %-- close handles
    disp('Test open tag by ID from block ... OK');
    
catch me
    disp('Test open tag by ID from block ... ERROR');
    rethrow(me);
end;

%% Test: Open tag by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currTagList = getBlock.list_tags();
    getTagByName = getBlock.open_tag(currTagList(1,1).name);
    
    assert(strcmp(getTagByName.name, 'Arm movement epoch Trial 004'));
    clear; %-- close handles
    disp('Test open tag by name from block ... OK');
    
catch me
    disp('Test open tag by name from block ... ERROR');
    rethrow(me);
end;

%% Test: Open multi tag by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currMultiTagList = getBlock.list_multi_tags();
    getMultiTagByID = getBlock.open_multi_tag(currMultiTagList(1,1).id);
    
    assert(strcmp(getMultiTagByID.id, '9e3fdaa5-a71c-4be0-91b3-9c35ed2d4723'));
    clear; %-- close handles
    disp('Test open multi tag by ID from block ... OK');
    
catch me
    disp('Test open multi tag by ID from block ... ERROR');
    rethrow(me);
end;

%% Test: Open multi tag by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currMultiTagList = getBlock.list_multi_tags();
    getMultiTagByName = getBlock.open_multi_tag(currMultiTagList(1,1).name);
    
    assert(strcmp(getMultiTagByName.name, 'Spiketrain Unit 5 Trial 087'));
    clear; %-- close handles
    disp('Test open multi tag by name from block ... OK');
    
catch me
    disp('Test open multi tag by name from block ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currSourceList = getBlock.list_sources();
    getSourceByID = getBlock.open_source(currSourceList(1,1).id);
    
    assert(strcmp(getSourceByID.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    clear; %-- close handles
    disp('Test open source by ID from block ... OK');
    
catch me
    disp('Test open source by ID from block ... ERROR');
    rethrow(me);
end;

%% Test: Open source by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    currSourceList = getBlock.list_sources();
    getSourceByName = getBlock.open_source(currSourceList(1,1).name);
    
    assert(strcmp(getSourceByName.name, 'Unit 5'));
    clear; %-- close handles
    disp('Test open source by name from block ... OK');
    
catch me
    disp('Test open source by name from block ... ERROR');
    rethrow(me);
end;

%% Test: Block has multi tag by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    multiTagList = getBlock.list_multi_tags();
    assert(getBlock.has_multi_tag(multiTagList(1,1).id));
    clear; %-- close handles
    disp('Test block has multi tag by ID ... OK');
    
catch me
    disp('Test block has multi tag by ID ... ERROR');
    rethrow(me);
end;

%% Test: Block has multi tag by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    multiTagList = getBlock.list_multi_tags();
    assert(getBlock.has_multi_tag(multiTagList(1,1).name));
    clear; %-- close handles
    disp('Test block has multi tag by name ... OK');
    
catch me
    disp('Test block has multi tag by name ... ERROR');
    rethrow(me);
end;

%% Test: Block has tag by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    tagList = getBlock.list_tags();
    assert(getBlock.has_tag(tagList(1,1).id));
    clear; %-- close handles
    disp('Test block has tag by ID ... OK');
    
catch me
    disp('Test block has tag by ID ... ERROR');
    rethrow(me);
end;

%% Test: Block has tag by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);
    tagList = getBlock.list_tags();
    assert(getBlock.has_tag(tagList(1,1).name));
    clear; %-- close handles
    disp('Test block has tag by name ... OK');
    
catch me
    disp('Test block has tag by name ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.block(currBlockList(1,1).name);

    %-- ToDo implement proper test for metadata once metadata is implemented
    assert(strcmp(getBlock.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test open metadata from block ... OK');

catch me
    disp('Test open metadata from block ... ERROR');
    rethrow(me);
end;