% Tests for the nix.File objects

%% Test 1: Block listing
% Test that File handle can fetch blocks from HDF5
try
    test_file = nix.File('test.h5');
    assert(length(test_file.listBlocks()) == 4);
    
    test_file.delete();
    
catch me
    test_file.delete();
    rethrow(me);
    
end