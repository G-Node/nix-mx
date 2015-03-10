function funcs = TestTag
%TESTTag tests for Tag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_add_reference;
    funcs{end+1} = @test_remove_reference;
    funcs{end+1} = @test_list_fetch_references;
    funcs{end+1} = @test_list_fetch_sources;
    funcs{end+1} = @test_list_fetch_features;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_feature;
    funcs{end+1} = @test_open_reference;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixblock');
    getSource = getBlock.create_source('sourcetest','nixsource');
    createSource1 = getSource.create_source('nestedsource1','nixsource');
    createSource2 = getSource.create_source('nestedsource2','nixsource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('foo', 'bar', position);
    
    assert(isempty(getTag.sources));
    getTag.add_source(getSource.sources{1}.id);
    getTag.add_source(getSource.sources{2});
    assert(size(getTag.sources,1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixblock');
    getSource = getBlock.create_source('sourcetest','nixsource');
    createSource1 = getSource.create_source('nestedsource1','nixsource');
    createSource2 = getSource.create_source('nestedsource2','nixsource');
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('foo', 'bar', position);
    getTag.add_source(getSource.sources{1}.id);
    getTag.add_source(getSource.sources{2});

    assert(size(getTag.sources,1) == 2);
    getTag.remove_source(getSource.sources{2});
    assert(size(getTag.sources,1) == 1);
    getTag.remove_source(getSource.sources{1}.id);
    assert(isempty(getTag.sources));
    assert(getTag.remove_source('I do not exist'));
    assert(size(getSource.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = test_add_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixblock');
    getRefDA1 = getBlock.create_data_array('referenceTest1', 'nixDataArray', 'double', [1 2]);
    getRefDA2 = getBlock.create_data_array('referenceTest2', 'nixDataArray', 'double', [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    
    assert(isempty(getTag.references));
    getTag.add_reference(getBlock.dataArrays{1}.id);
    getTag.add_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 2);
end

%% Test: Remove references by entity and id
function [] = test_remove_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('referenceTest', 'nixblock');
    getRefDA1 = getBlock.create_data_array('referenceTest1', 'nixDataArray', 'double', [1 2]);
    getRefDA2 = getBlock.create_data_array('referenceTest2', 'nixDataArray', 'double', [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    getTag = getBlock.create_tag('referenceTest', 'nixTag', position);
    getTag.add_reference(getBlock.dataArrays{1}.id);
    getTag.add_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 2);

    getTag.remove_reference(getBlock.dataArrays{2});
    assert(size(getTag.references, 1) == 1);
    getTag.remove_reference(getBlock.dataArrays{1}.id);
    assert(isempty(getTag.references));
    assert(~getTag.remove_reference('I do not exist'));
    assert(size(getBlock.dataArrays, 1) == 2);
end

%% Test: List/fetch references
function [] = test_list_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    assert(size(getTag.references(), 1) == 1);
end

%% Test: List/fetch sources
function [] = test_list_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.sources(),1) == 0);
    disp('Test Tag: fetch sources ... TODO (proper testfile)');
end


%% Test: List/fetch features
function [] = test_list_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);

    %-- ToDo get testfile with tag referencing a source
    assert(size(getTag.features(),1) == 0);
    disp('Test Tag: fetch features ... TODO (proper testfile)');
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with source referenced from a tag
    %getSourceByID = getTag.open_source(getTag.sources{1,1}.id);
    %assert(strcmp(getSourceByID.id, ''));
    disp('Test Tag: open source by ID ... TODO (proper testfile)');

    %getSourceByName = getTag.open_source(getTag.sources{1,1}.name);
    %assert(strcmp(getSourceByName.id, ''));
    disp('Test Tag: open source by name ... TODO (proper testfile)');
    
    %-- test open non existing source
    getSource = getTag.open_source('I dont exist');
    assert(isempty(getSource));
end


%% Test: Open feature by ID or name
function [] = test_open_feature( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    %-- TODO: implement testfile with feature referenced from a tag
    %getFeatByID = getTag.open_feature(getTag.features{1,1}.id);
    %assert(strcmp(getFeatByID.id, ''));
    disp('Test Tag: open feature by ID ... TODO (proper testfile)');

    %getFeatByName = getTag.open_feature(getTag.features{1,1}.name);
    %assert(strcmp(getFeatByName.id, ''));
    disp('Test Tag: open feature by name ... TODO (proper testfile)');
    
    %-- test open non existing feature
    getFeat = getTag.open_feature('I dont exist');
    assert(isempty(getFeat));
end


%% Test: Open reference by ID or name
function [] = test_open_reference( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    
    getRefByID = getTag.open_reference(getTag.references{1,1}.id);
    assert(strcmp(getRefByID.id, '75138768-edc3-482e-894d-301f1dd66f8d'));

    getRefByName = getTag.open_reference(getTag.references{1,1}.name);
    assert(strcmp(getRefByName.id, '75138768-edc3-482e-894d-301f1dd66f8d'));
    
    %-- test open non existing source
    getRef = getTag.open_reference('I dont exist');
    assert(isempty(getRef));
end


%% Test: Open metadata
function [] = test_open_metadata( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);
    
    getTag = getBlock.open_tag(getBlock.tags{1,1}.id);
    assert(isempty(getTag.open_metadata()))
    
    getTag = getBlock.open_tag(getBlock.tags{2,1}.id);
    assert(~isempty(getTag.open_metadata()));
end

%% Test: Retrieve data
function [] = test_retrieve_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    tag = b.tags{1};
    
    data = tag.retrieve_data(1);
    assert(~isempty(data));
end

%% Test: Retrieve feature data
function [] = test_retrieve_feature_data( varargin )
    % TODO
    disp('Test Tag: retrieve feature ... TODO (proper testfile)');
end
