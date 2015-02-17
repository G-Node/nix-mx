% Tests for the nix.DataArray object

%% Test: Read all data from DataArray
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).name);
    daList = getBlock.list_data_arrays();
    currDataArray = getBlock.data_array(daList(1,1).id);

    assert(size(currDataArray.read_all(),1) == 36);
    clear; %-- close handles
    disp('Test read all data from DataArray ... OK');
    
catch me
    disp('Test read all data from DataArray ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlock = test_file.openBlock(currBlockList(1,1).name);
    daList = getBlock.list_data_arrays();
    currDataArray = getBlock.data_array(daList(1,1).id);

    %-- ToDo implement proper test for metadata once metadata is implemented
    assert(strcmp(currDataArray.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test open metadata from DataArray ... OK');

catch me
    disp('Test open metadata from DataArray ... ERROR');
    rethrow(me);
end;

