% Tests for the nix.File objects

%% Test 1: Block listing
% Test that File handle can fetch blocks from HDF5
try
    test_file = nix.File('test.h5', nix.FileMode.ReadOnly);
    assert(length(test_file.listBlocks()) == 4);
    
    assert(length(test_file.blocks()) == 4);
    
    test_file.delete();
    
catch me
    test_file.delete();
    rethrow(me);
    
end


%% Test 2: Section listing
% Test that File handle can fetch sections from HDF5
try
    test_file = nix.File('test.h5', nix.FileMode.ReadOnly);
    assert(length(test_file.listSections()) == 3);
    
    assert(length(test_file.sections()) == 3);
    
    test_file.delete();
    
catch me
    test_file.delete();
    rethrow(me);
    
end