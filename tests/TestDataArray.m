% Tests for the nix.DataArray object

%% Test: Read all data from DataArray
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);

    assert(size(getDataArray.read_all(),1) == 36);
    disp('Test DataArray: read all data ... OK');

    clear; %-- close handles

catch me
    disp('Test DataArray: read all data ... ERROR');
    rethrow(me);
end;

%% Test: Open metadata
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getDataArray = getBlock.data_array(getBlock.dataArrays{1,1}.id);

    %-- ToDo implement proper test for metadata once metadata is implemented
    assert(strcmp(getDataArray.open_metadata(),'TODO: implement MetadataSection'));
    
    clear; %-- close handles
    disp('Test DataArray: open metadata ... TODO');

catch me
    disp('Test DataArray: open metadata ... ERROR');
    rethrow(me);
end;

