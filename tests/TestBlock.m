% Tests for the nix.Block object

%% Test: List/fetch data arrays
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(size(getBlock.list_data_arrays(),1) == 198);
    disp('Test Block: list data array ... OK');

    assert(size(getBlock.dataArrays,1) == 198);
    disp('Test Block: fetch data array ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Block: list/fetch data array ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch sources
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(size(getBlock.list_sources(),1) == 1);
    disp('Test Block: list sources ... OK');

    assert(size(getBlock.sources(), 1) == 1);
    disp('Test Block: fetch sources ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Block: list/fetch sources ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch tags
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(size(getBlock.list_tags(),1) == 198);
    disp('Test Block: list tags ... OK');

    assert(size(getBlock.tags(), 1) == 198);
    disp('Test Block: fetch tags ... OK');
    
    clear; %-- close handles    
    
catch me
    disp('Test Block: list/fetch tags ... ERROR');
    rethrow(me);
end;

%% Test: List/fetch multitags
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    assert(size(getBlock.list_multi_tags(),1) == 99);
    disp('Test Block: list multi tags ... OK');

    assert(size(getBlock.multiTags(), 1) == 99);
    disp('Test Block: fetch multi tags ... OK');
    clear; %-- close handles    
    
catch me
    disp('Test Block: list/fetch multi tags ... ERROR');
    rethrow(me);
end;

%% Test: Open data array by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    getDataArrayByID = getBlock.data_array(getBlock.dataArrays{1,1}.id);
    assert(strcmp(getDataArrayByID.id, 'e0ca39b7-632f-47c9-968c-c65e6db58719'));
    disp('Test Block: open data array by ID ... OK');

    getDataArrayByName = getBlock.data_array(getBlock.dataArrays{1,1}.name);
    assert(strcmp(getDataArrayByName.id, 'e0ca39b7-632f-47c9-968c-c65e6db58719'));
    disp('Test Block: open data array by name ... OK');

    clear; %-- close handles
    
catch me
    disp('Test Block: open data array by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open tag by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);    

    getTagByID = getBlock.open_tag(getBlock.tags{1,1}.id);
    assert(strcmp(getTagByID.id, 'f49f4a56-0c93-4323-8e37-4b02b8cabb55'));
    disp('Test Block: open tag by ID ... OK');

    getTagByName = getBlock.open_tag(getBlock.tags{1,1}.name);
    assert(strcmp(getTagByName.id, 'f49f4a56-0c93-4323-8e37-4b02b8cabb55'));
    disp('Test Block: open tag by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Block: open tag by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open multi tag by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);    

    getMultiTagByID = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(strcmp(getMultiTagByID.id, '9e3fdaa5-a71c-4be0-91b3-9c35ed2d4723'));
    disp('Test Block: open multi tag by ID ... OK');

    getMultiTagByName = getBlock.open_multi_tag(getBlock.multiTags{1,1}.name);
    assert(strcmp(getMultiTagByName.id, '9e3fdaa5-a71c-4be0-91b3-9c35ed2d4723'));
    disp('Test Block: open multi tag by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Block: open multi tag by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Open source by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);    

    getSourceByID = getBlock.open_source(getBlock.sources{1,1}.id);
    assert(strcmp(getSourceByID.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    disp('Test Block: open source by ID ... OK');

    getSourceByName = getBlock.open_source(getBlock.sources{1,1}.name);
    assert(strcmp(getSourceByName.id, 'edf4c8b6-8569-4952-bcee-4203dd26571e'));
    disp('Test Block: open source by name ... OK');

    clear; %-- close handles
    
catch me
    disp('Test Block: open source by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Block has multi tag by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);    
    
    assert(getBlock.has_multi_tag(getBlock.multiTags{1,1}.id));
    disp('Test Block: has multi tag by ID ... OK');

    assert(getBlock.has_multi_tag(getBlock.multiTags{1,1}.name));
    disp('Test Block: has multi tag by name ... OK');
    
    clear; %-- close handles
    
catch me
    disp('Test Block: has multi tag by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Block has tag by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(getBlock.has_tag(getBlock.tags{1,1}.id));
    disp('Test Block: has tag by ID ... OK');

    assert(getBlock.has_tag(getBlock.tags{1,1}.name));
    disp('Test Block: has tag by name ... OK');

    clear; %-- close handles
    
catch me
    disp('Test Block: has tag by ID/name ... ERROR');
    rethrow(me);
end;

%% Test: Has metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(~getBlock.has_metadata());
    disp('Test Block: has empty metadata ... OK');
    
    %-- ToDo implement test for exising metadata
    %getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    %assert(getBlock.has_metadata())
    disp('Test Block: has existing metadata ... TODO (proper testfile)');
    
    clear; %-- close handles

catch me
    disp('Test Block: has empty/existing metadata ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    assert(isempty(getBlock.open_metadata()))
    disp('Test Block: open empty metadata ... OK');
    
    %-- ToDo implement test for exising metadata
    %getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    %assert(~isempty(getBlock.open_metadata()))
    disp('Test Block: open existing metadata ... TODO (proper testfile)');
    
    clear; %-- close handles

catch me
    disp('Test Block: open empty/existing metadata ... ERROR');
    rethrow(me);
end;

