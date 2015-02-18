% Tests for the nix.File object

%% Test: Open HDF5 file in ReadOnly mode
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    clear; %-- close file handle
    disp('Test File: Open in read only mode ... OK');
    
catch me
    disp('Test File: Open in read only mode ... ERROR');
    rethrow(me);
end;

%% Test: Open HDF5 file in ReadWrite mode
try
    clear; %-- ensure clean workspace
    %-- TODO: throws error 'does not work' at the moment
    %test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadWrite);
    clear; %-- close file handle
    disp('Test File: Open in read write mode ... TODO');
    
catch me
    disp('Test File: Open in read write mode ... ERROR');
    rethrow(me);
end;

%% Test: Open HDF5 file in Overwrite mode
%-- ToDo: maybe there's a cleverer way for the overwrite test than having
%-- two test files.
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','testOverwrite.h5'), nix.FileMode.Overwrite);
    clear; %-- close file handle
    disp('Test File: Open in overwrite mode ... OK');
    
catch me
	disp('Test File: Open in overwrite mode ... ERROR');
    rethrow(me);
end;

%% Test: Section listing
% Test that File handle can fetch sections from HDF5
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listSections()) == 3);
    disp('Test File: list sections ... OK');
    
    assert(length(test_file.sections()) == 3);
    disp('Test File: fetch sections ... OK');

    clear; %-- close handles

catch me
    disp('Test File: list/fetch sections ... ERROR');
    rethrow(me);
end;

%% Test open section
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);
    getSection = test_file.openSection(test_file.sections{1,1}.id);

    assert(strcmp(getSection.name, 'General'));
    clear; %-- close handles
    disp('Test File: open section ... OK');

catch me
    disp('Test File: open section ... ERROR');
    rethrow(me);
end;

%% Test list and fetch blocks
% Test that File handle can fetch blocks from HDF5
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    assert(length(test_file.listBlocks()) == 4);
    disp('Test File: list blocks ... OK');
    
    assert(size(test_file.blocks(),1) == 4);
    disp('Test File: fetch blocks ... OK');

    clear; %-- close handles

catch me
    disp('Test File: list/fetch blocks ... ERROR');
    rethrow(me);
end;

%% Test Open Block by ID or name
try
    clear; %-- ensure clean workspace
    test_file = nix.File(fullfile(pwd,'tests','test.h5'), nix.FileMode.ReadOnly);

    getBlockByID = test_file.openBlock(test_file.blocks{1,1}.id);
    assert(strcmp(getBlockByID.id, '7b59c0b9-b200-4b53-951d-6851dbd1cdc8'));
    disp('Test File: open block by ID ... OK');

    getBlockByName = test_file.openBlock(test_file.blocks{1,1}.name);
    assert(strcmp(getBlockByName.name, 'joe097'));
    disp('Test File: open block by name ... OK');

    clear; %-- close handles

catch me
    disp('Test File: open block by ID/name ... ERROR');
    rethrow(me);
end;

