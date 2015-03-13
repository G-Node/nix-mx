function funcs = TestMultiTag
%TESTMultiTag tests for MultiTag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_add_reference;
    funcs{end+1} = @test_remove_reference;
    funcs{end+1} = @test_add_feature;
    funcs{end+1} = @test_remove_feature;
    funcs{end+1} = @test_fetch_references;
    funcs{end+1} = @test_fetch_sources;
    funcs{end+1} = @test_fetch_features;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_open_feature;
    funcs{end+1} = @test_open_reference;
    funcs{end+1} = @test_add_positions;
    funcs{end+1} = @test_has_positions;
    funcs{end+1} = @test_open_positions;
    funcs{end+1} = @test_add_extents;
    funcs{end+1} = @test_open_extents;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_retrieve_data;
    funcs{end+1} = @test_retrieve_feature_data;
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(getMTag.sources));
    getMTag.add_source(getSource.sources{1}.id);
    getMTag.add_source(getSource.sources{2});
    assert(size(getMTag.sources, 1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    getMTag.add_source(getSource.sources{1}.id);
    getMTag.add_source(getSource.sources{2});

    getMTag.remove_source(getSource.sources{2});
    assert(size(getMTag.sources,1) == 1);
    getMTag.remove_source(getSource.sources{1}.id);
    assert(isempty(getMTag.sources));
    assert(getMTag.remove_source('I do not exist'));
    assert(size(getSource.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = test_add_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);

    assert(isempty(getMTag.references));
    getMTag.add_reference(b.dataArrays{2}.id);
    getMTag.add_reference(b.dataArrays{3});
    assert(size(getMTag.references, 1) == 2);
end

%% Test: Remove references by entity and id
function [] = test_remove_reference ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);
    getMTag.add_reference(b.dataArrays{2}.id);
    getMTag.add_reference(b.dataArrays{3});

    assert(getMTag.remove_reference(b.dataArrays{3}));
    assert(getMTag.remove_reference(b.dataArrays{2}.id));
    assert(isempty(getMTag.references));

    assert(~getMTag.remove_reference('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: Add features by entity and id
function [] = test_add_feature ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array('featTestDA1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_data_array('featTestDA2', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('featTestDA3', 'nixDataArray', 'double', [5 6]);
    tmp = b.create_data_array('featTestDA4', 'nixDataArray', 'double', [7 8]);
    tmp = b.create_data_array('featTestDA5', 'nixDataArray', 'double', [9 10]);
    tmp = b.create_data_array('featTestDA6', 'nixDataArray', 'double', [11 12]);

    assert(isempty(getMTag.features));
    tmp = getMTag.add_feature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = getMTag.add_feature(b.dataArrays{3}, nix.LinkType.Tagged);
    tmp = getMTag.add_feature(b.dataArrays{4}.id, nix.LinkType.Untagged);
    tmp = getMTag.add_feature(b.dataArrays{5}, nix.LinkType.Untagged);
    tmp = getMTag.add_feature(b.dataArrays{6}.id, nix.LinkType.Indexed);
    tmp = getMTag.add_feature(b.dataArrays{7}, nix.LinkType.Indexed);
    assert(size(getMTag.features, 1) == 6);
end

%% Test: Remove features by entity and id
function [] = test_remove_feature ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
	tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array('featTestDA1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_data_array('featTestDA2', 'nixDataArray', 'double', [3 4]);

    tmp = getMTag.add_feature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = getMTag.add_feature(b.dataArrays{3}, nix.LinkType.Tagged);

    assert(getMTag.remove_feature(getMTag.features{2}.id));
    assert(getMTag.remove_feature(getMTag.features{1}));
    assert(isempty(getMTag.features));

    assert(~getMTag.remove_feature('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: fetch references
function [] = test_fetch_references( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('referenceTest1', 'nixDataArray', 'double', [3 4]);
    tmp = b.create_data_array('referenceTest2', 'nixDataArray', 'double', [5 6]);
    getMTag.add_reference(b.dataArrays{2}.id);
    getMTag.add_reference(b.dataArrays{3});

    assert(size(getMTag.references, 1) == 2);
end

%% Test: fetch sources
function [] = test_fetch_sources( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    getMTag.add_source(getSource.sources{1}.id);
    getMTag.add_source(getSource.sources{2});

    assert(size(getMTag.sources, 1) == 2);
end

%% Test: fetch features
function [] = test_fetch_features( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(getMTag.features));
    tmp = b.create_data_array('featTestDA', 'nixDataArray', 'double', [1 2]);
    tmp = getMTag.add_feature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(size(getMTag.features, 1) == 1);
end

%% Test: Open source by ID or name
function [] = test_open_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('sourceTest', 'nixBlock');
    tmp = b.create_data_array('sourceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getSource = b.create_source('sourceTest', 'nixSource');
    sName = 'nestedSource';
    tmp = getSource.create_source(sName, 'nixSource');
    getMTag = b.create_multi_tag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    getMTag.add_source(getSource.sources{1});

    getSourceByID = getMTag.open_source(getMTag.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = getMTag.open_source(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = getMTag.open_source('I do not exist');
    assert(isempty(getSource));
end

%% Test: Open feature by ID
function [] = test_open_feature( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array('featTestDA', 'nixDataArray', 'double', [1 2]);
    tmp = getMTag.add_feature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(~isempty(getMTag.open_feature(getMTag.features{1}.id)));

    %-- test open non existing feature
    getFeat = getMTag.open_feature('I do not exist');
    assert(isempty(getFeat));
end

%% Test: Open reference by ID or name
function [] = test_open_reference( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('referenceTest', 'nixBlock');
    tmp = b.create_data_array('referenceTestDataArray', 'nixDataArray', 'double', [1 2]);
    getMTag = b.create_multi_tag('referencetest', 'nixMultiTag', b.dataArrays{1});
    refName = 'referenceTest';
    tmp = b.create_data_array(refName, 'nixDataArray', 'double', [3 4]);
    getMTag.add_reference(b.dataArrays{2}.id);

    getRefByID = getMTag.open_reference(getMTag.references{1,1}.id);
    assert(~isempty(getRefByID));

    getRefByName = getMTag.open_reference(refName);
    assert(~isempty(getRefByName));

    %-- test open non existing reference
    getRef = getMTag.open_reference('I do not exist');
    assert(isempty(getRef));
end

%% Test: Add positions by entity and id
function [] = test_add_positions ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.create_data_array('positionsTest1', 'nixDataArray', 'double', [0 1]);
    tmp = b.create_data_array('positionsTest2', 'nixDataArray', 'double', [2 4]);

    getMTag.add_positions(b.dataArrays{2}.id);
    assert(strcmp(getMTag.open_positions.name, 'positionsTest1'));

    getMTag.add_positions(b.dataArrays{3});
    assert(strcmp(getMTag.open_positions.name, 'positionsTest2'));
end

%% Test: Has positions
function [] = test_has_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('positionsTest1', 'nixDataArray', 'double', [0 1]);

    getMTag.add_positions(b.dataArrays{2}.id);
    assert(getMTag.has_positions);
end

%% Test: Open positions
function [] = test_open_positions( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = test_file.createBlock('positionsTest', 'nixBlock');
    tmp = b.create_data_array('positionsTestDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    getMTag = b.create_multi_tag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_data_array('positionsTest1', 'nixDataArray', 'double', [0 1]);

    getMTag.add_positions(b.dataArrays{2}.id);
    assert(~isempty(getMTag.open_positions));
end

%% Test: Add extents by entity and id
function [] = test_add_extents ( varargin )
%    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
%    b = test_file.createBlock('extentsTest', 'nixBlock');
%    tmp = b.create_data_array('extentsTestDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6; 1 2 3 4 5 6]);
%    getMTag = b.create_multi_tag('extentstest', 'nixMultiTag', b.dataArrays{1});

%    tmp = b.create_data_array('positionsTest1', 'nixDataArray', 'double', [1, 1]);
%    tmp = b.create_data_array('positionsTest2', 'nixDataArray', 'double', [1, 3]);

%    tmp = b.create_data_array('extentsTest1', 'nixDataArray', 'double', [1, 1]);
%    tmp = b.create_data_array('extentsTest2', 'nixDataArray', 'double', [1, 1]);

%    getMTag.add_positions(b.dataArrays{2});
%    getMTag.add_extents(b.dataArrays{4}.id);
%    assert(strcmp(getMTag.open_extents.name, 'extentsTest1'));

%    getMTag.add_positions(b.dataArrays{3});
%    getMTag.add_extents(b.dataArrays{5});
%    assert(strcmp(getMTag.open_extents.name, 'extentsTest2'));
    disp('Test MultiTag: add extents ... TODO (add dimensions required)');
end

%% Test: Open extents
function [] = test_open_extents( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    getBlock = test_file.openBlock(test_file.blocks{1,1}.name);

    getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    assert(isempty(getMultiTag.open_extents));
   
    %-- ToDo implement test for existing extents
    %getMultiTag = getBlock.open_multi_tag(getBlock.multiTags{1,1}.id);
    %assert(~isempty(getMultiTag.open_positions));
    disp('Test MultiTag: open existing extents ... TODO (proper testfile)');
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection1', 'nixSection');
    tmp = f.createSection('testSection2', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.create_data_array('testDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    t = b.create_multi_tag('metadataTest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(t.open_metadata));
    t.set_metadata(f.sections{1});
    assert(strcmp(t.open_metadata.name, 'testSection1'));
    t.set_metadata(f.sections{2});
    assert(strcmp(t.open_metadata.name, 'testSection2'));
    t.set_metadata('');
    assert(isempty(t.open_metadata));
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.create_data_array('testDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    t = b.create_multi_tag('metadataTest', 'nixMultiTag', b.dataArrays{1});
    t.set_metadata(f.sections{1});

    assert(strcmp(t.open_metadata.name, 'testSection'));
end

%% Test: Retrieve data
function [] = test_retrieve_data( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    tag = b.multiTags{1};
    
    data = tag.retrieve_data(1, 1);
    assert(~isempty(data));
end

%% Test: Retrieve feature data
function [] = test_retrieve_feature_data( varargin )
    % TODO
    disp('Test MultiTag: retrieve feature ... TODO (proper testfile)');
end
