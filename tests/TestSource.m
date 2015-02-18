% Tests for the nix.Source object

%% Test: List sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).id);
    currSourceList = getBlock.list_sources();
    getSourceFromBlock = getBlock.open_source(currSourceList(1,1).id);

    %-- TODO: get a testfile with nested sources
    assert(size(getSourceFromBlock.list_sources(),1) == 0);
    clear; %-- close handles
    disp('Test list sources from source ... TODO');
    
catch me
    disp('Test list sources from source ... ERROR');
    rethrow(me);
end;

%% Test: Fetch sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).id);
    currSourceList = getBlock.list_sources();
    getSourceFromBlock = getBlock.open_source(currSourceList(1,1).id);

    %-- TODO: get a testfile with nested sources
    assert(size(getSourceFromBlock.sources(), 1) == 0);
    clear; %-- close handles
    disp('Test fetch sources from source ... TODO');
    
catch me
    disp('Test fetch sources from source ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID
%-- TODO: get a testfile with nested sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).id);
    currSourceListFromBlock = getBlock.list_sources();
    getSourceFromBlock = getBlock.open_source(currSourceListFromBlock(1,1).id);
    currSourceList = getSourceFromBlock.list_sources();
    
    %-- TODO: comment in, when testfile with nested sources is available
    %getSourceByID = getSourceFromBlock.open_source(currSourceList(1,1).id);
    %assert(strcmp(getSourceByID.id, ''));
    clear; %-- close handles
    disp('Test open source by ID from source ... TODO');
    
catch me
    disp('Test open source by ID from source ... ERROR');
    rethrow(me);
end;

%% Test: Open source by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).id);
    currSourceListFromBlock = getBlock.list_sources();
    getSourceFromBlock = getBlock.open_source(currSourceListFromBlock(1,1).id);
    currSourceList = getSourceFromBlock.list_sources();
    
    %-- TODO: comment in, when testfile with nested sources is available
    %getSourceByName = getSourceFromBlock.open_source(currSourceList(1,1).name);
    %assert(strcmp(getSourceByName.name, ''));
    clear; %-- close handles
    disp('Test open source by name from source ... TODO');
    
catch me
    disp('Test open source by name from source ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).name);
    currSourceListFromBlock = getBlock.list_sources();
    getSourceFromBlock = getBlock.open_source(currSourceListFromBlock(1,1).id);

    %-- ToDo implement proper test for metadata once metadata is implemented
    %-- ToDo implement testfile where a source links to metadata
    assert(strcmp(getSourceFromBlock.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test open metadata from source ... TODO');

catch me
    disp('Test open metadata from source ... ERROR');
    rethrow(me);
end;

