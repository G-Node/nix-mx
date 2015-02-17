% Tests for the nix.File object

%% Test: Open HDF5 file in ReadOnly mode
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    clear; %-- close file handle
    disp('Open file in read only mode ... OK');
    
catch me
    disp('Open file in read only mode ... ERROR');
    rethrow(me);
end;

%% Test: Open HDF5 file in ReadWrite mode
try
    clear; %-- ensure clean workspace
    %-- TODO: throws error 'does not work' at the moment
    %test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadWrite);
    clear; %-- close file handle
    disp('Open file in read write mode ... TODO');
    
catch me
    disp('Open file in read write mode ... ERROR');
    rethrow(me);
end;

%% Test: Open HDF5 file in Overwrite mode
%-- ToDo: maybe there's a cleverer way for the overwrite test than having
%-- two test files.
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','testOverwrite.h5'), nix.FileMode.Overwrite);
    clear; %-- close file handle
    disp('Open file in overwrite mode ... OK');
    
catch me
	disp('Open file in overwrite mode ... ERROR');
    rethrow(me);
end;

%% Test: Section listing
% Test that File handle can fetch sections from HDF5
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listSections()) == 3);
    assert(length(test_file.sections()) == 3);
    clear; %-- close handles
    disp('Test listing sections from HDF5 file ... OK');

catch me
    disp('Test listing sections from HDF5 file ... ERROR');
    rethrow(me);
end;

%% Test Block listing
% Test that File handle can fetch blocks from HDF5
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listBlocks()) == 4);
    clear; %-- close handles
    disp('Test listing blocks from HDF5 file ... OK');

catch me
    disp('Test listing blocks from HDF5 file ... ERROR');
    rethrow(me);
end;

%% Test Open Block by ID
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlockByID = test_file.openBlock(currBlockList(1,1).id);

    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));
    disp('Test open block by ID from HDF5 file ... OK');
    clear; %-- close handles
catch me
    disp('Test open block by ID from HDF5 file ... ERROR');
    rethrow(me);
end;

%% Test Open Block by name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    currBlockList = test_file.listBlocks();
    getBlockByName = test_file.openBlock(currBlockList(1,1).name);

    assert(strcmp(getBlockByName.name, 'joe097'));
    disp('Test open block by name from HDF5 file ... OK');
    clear; %-- close handles
catch me
    disp('Test open block by name from HDF5 file ... ERROR');
    rethrow(me);
end;

%% TODO Test Open metadata

disp('Test open metadata from file ... TODO');


