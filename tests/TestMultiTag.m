% TestMultiTag provides tests for all supported nix.MultiTag methods.
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestMultiTag
    funcs = {};
    funcs{end+1} = @testAddSource;
    funcs{end+1} = @testAddSources;
    funcs{end+1} = @testRemoveSource;
    funcs{end+1} = @testAddReference;
    funcs{end+1} = @testAddReferences;
    funcs{end+1} = @testHasReference;
    funcs{end+1} = @testRemoveReference;
    funcs{end+1} = @testCreateFeature;
    funcs{end+1} = @testHasFeature;
    funcs{end+1} = @testDeleteFeature;
    funcs{end+1} = @testFetchReferences;
    funcs{end+1} = @testFetchSources;
    funcs{end+1} = @testFetchFeatures;
    funcs{end+1} = @testOpenSource;
    funcs{end+1} = @testOpenSourceIdx;
    funcs{end+1} = @testHasSource;
    funcs{end+1} = @testSourceCount;
    funcs{end+1} = @testOpenFeature;
    funcs{end+1} = @testOpenFeatureIdx;
    funcs{end+1} = @testOpenReference;
    funcs{end+1} = @testOpenReferenceIdx;
    funcs{end+1} = @testFeatureCount;
    funcs{end+1} = @testReferenceCount;
    funcs{end+1} = @testSetPositions;
    funcs{end+1} = @testHasPositions;
    funcs{end+1} = @testOpenPositions;
    funcs{end+1} = @testSetOpenExtents;
    funcs{end+1} = @testSetMetadata;
    funcs{end+1} = @testOpenMetadata;
    funcs{end+1} = @testRetrieveData;
    funcs{end+1} = @testRetrieveDataIdx;
    funcs{end+1} = @testRetrieveFeatureData;
    funcs{end+1} = @testRetrieveFeatureDataIdx;
    funcs{end+1} = @testSetUnits;
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSource;
    funcs{end+1} = @testFilterReference;
    funcs{end+1} = @testFilterFeature;
end

%% Test: Add Source by entity and id
function [] = testAddSource ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    tmp = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    t = b.createMultiTag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(t.sources));
    assert(isempty(f.blocks{1}.multiTags{1}.sources));

    t.addSource(s.sources{1}.id);
    assert(size(t.sources, 1) == 1);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 1);

    t.addSource(s.sources{2});
    assert(size(t.sources, 1) == 2);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 2);
    
    clear tmp t s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 2);
end

%% Test: Add Source by entity cell array
function [] = testAddSources ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createSource('testSource1', 'nixSource');
    tmp = b.createSource('testSource2', 'nixSource');
    tmp = b.createSource('testSource3', 'nixSource');

    assert(isempty(t.sources));

    try
        t.addSources('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(t.sources));

    try
        t.addSources({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Source')));
    end;
    assert(isempty(t.sources));

    t.addSources(b.sources());
    assert(size(t.sources, 1) == 3);

    clear t tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.sources, 1) == 3);
end

%% Test: Remove Source by entity and id
function [] = testRemoveSource ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    tmp = b.createDataArray(...
        'sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    t = b.createMultiTag('sourcetest', 'nixMultiTag', b.dataArrays{1});

    t.addSource(s.sources{1}.id);
    t.addSource(s.sources{2});

    t.removeSource(s.sources{2});
    assert(size(t.sources,1) == 1);
    t.removeSource(s.sources{1}.id);
    assert(isempty(t.sources));
    assert(t.removeSource('I do not exist'));
    assert(size(s.sources,1) == 2);
end

%% Test: Add reference by entity and id
function [] = testAddReference ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.createDataArray(...
        'referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray(...
        'referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);

    assert(isempty(t.references));
    assert(isempty(f.blocks{1}.multiTags{1}.references));

    t.addReference(b.dataArrays{2}.id);
    assert(size(t.references, 1) == 1);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 1);
    
    t.addReference(b.dataArrays{3});
    assert(size(t.references, 1) == 2);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 2);
    
    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 2);
end

%% Test: Add reference by entity cell array
function [] = testAddReferences ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createDataArray('referenceTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray('referenceTest3', 'nixDataArray', nix.DataType.Double, [3 4]);

    assert(isempty(t.references));

    try
        t.addReferences('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(t.references));

    try
        t.addReferences({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.DataArray')));
    end;
    assert(isempty(t.references));

    t.addReferences(b.dataArrays);
    assert(size(t.references, 1) == 3);

    clear t tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.references, 1) == 3);
end

%% Test: Remove reference by entity and id
function [] = testRemoveReference ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray(...
        'referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referencetest', 'nixMultiTag', b.dataArrays{1});
    
    tmp = b.createDataArray(...
        'referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray(...
        'referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);
    t.addReference(b.dataArrays{2}.id);
    t.addReference(b.dataArrays{3});

    assert(t.removeReference(b.dataArrays{3}));
    assert(t.removeReference(b.dataArrays{2}.id));
    assert(isempty(t.references));

    assert(~t.removeReference('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: Create Feature by entity and id
function [] = testCreateFeature ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.createDataArray(...
        'featTestDA1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray(...
        'featTestDA2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray(...
        'featTestDA3', 'nixDataArray', nix.DataType.Double, [5 6]);
    tmp = b.createDataArray(...
        'featTestDA4', 'nixDataArray', nix.DataType.Double, [7 8]);
    tmp = b.createDataArray(...
        'featTestDA5', 'nixDataArray', nix.DataType.Double, [9 10]);
    tmp = b.createDataArray(...
        'featTestDA6', 'nixDataArray', nix.DataType.Double, [11 12]);

    assert(isempty(t.features));
    assert(isempty(f.blocks{1}.multiTags{1}.features));
    tmp = t.createFeature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = t.createFeature(b.dataArrays{3}, nix.LinkType.Tagged);
    tmp = t.createFeature(b.dataArrays{4}.id, nix.LinkType.Untagged);
    tmp = t.createFeature(b.dataArrays{5}, nix.LinkType.Untagged);
    tmp = t.createFeature(b.dataArrays{6}.id, nix.LinkType.Indexed);
    tmp = t.createFeature(b.dataArrays{7}, nix.LinkType.Indexed);
    assert(size(t.features, 1) == 6);
    assert(size(f.blocks{1}.multiTags{1}.features, 1) == 6);
    
    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.multiTags{1}.features, 1) == 6);
end

%% Test: Delete Feature by entity and id
function [] = testDeleteFeature ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
	tmp = b.createDataArray(...
        'featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.createDataArray(...
        'featTestDA1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray(...
        'featTestDA2', 'nixDataArray', nix.DataType.Double, [3 4]);

    tmp = t.createFeature(b.dataArrays{2}.id, nix.LinkType.Tagged);
    tmp = t.createFeature(b.dataArrays{3}, nix.LinkType.Tagged);

    assert(t.deleteFeature(t.features{2}.id));
    assert(t.deleteFeature(t.features{1}));
    assert(isempty(t.features));

    assert(~t.deleteFeature('I do not exist'));
    assert(size(b.dataArrays, 1) == 3);
end

%% Test: Fetch references
function [] = testFetchReferences( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referencetest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray('referenceTest2', 'nixDataArray', nix.DataType.Double, [5 6]);
    t.addReference(b.dataArrays{2}.id);
    t.addReference(b.dataArrays{3});

    assert(size(t.references, 1) == 2);
end

%% Test: Fetch Sources
function [] = testFetchSources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    tmp = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    t = b.createMultiTag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    t.addSource(s.sources{1}.id);
    t.addSource(s.sources{2});

    assert(size(t.sources, 1) == 2);
end

%% Test: Fetch Features
function [] = testFetchFeatures( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('featuretest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(t.features));
    tmp = b.createDataArray('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = t.createFeature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(size(t.features, 1) == 1);
end

%% Test: Open Source by id or name
function [] = testOpenSource( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    tmp = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    s = b.createSource('sourceTest', 'nixSource');
    sName = 'nestedSource';
    tmp = s.createSource(sName, 'nixSource');
    t = b.createMultiTag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    t.addSource(s.sources{1});

    getSourceByID = t.openSource(t.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = t.openSource(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    s = t.openSource('I do not exist');
    assert(isempty(s));
end

%% Test Open Source by index
function [] = testOpenSourceIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    s1 = b.createSource('testSource1', 'nixSource');
    s2 = b.createSource('testSource2', 'nixSource');
    s3 = b.createSource('testSource3', 'nixSource');
    t.addSource(s1);
    t.addSource(s2);
    t.addSource(s3);

    assert(strcmp(f.blocks{1}.multiTags{1}.openSourceIdx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.openSourceIdx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.openSourceIdx(3).name, s3.name));
end

%% Test: Has Source by id or entity
function [] = testHasSource( varargin )
    fileName = 'testRW.h5';
    sName = 'sourceTest1';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    s = b.createSource(sName, 'nixSource');
    sID = s.id;
    tmp = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('sourcetest', 'nixMultiTag', b.dataArrays{1});
    t.addSource(b.sources{1});

    assert(~t.hasSource('I do not exist'));
    assert(t.hasSource(s));

    clear t tmp s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.hasSource(sID));
    assert(~f.blocks{1}.multiTags{1}.hasSource(sName));
end

%% Test: Source count
function [] = testSourceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', b.dataArrays{1});

    assert(t.sourceCount() == 0);
    t.addSource(b.createSource('testSource1', 'nixSource'));
    assert(t.sourceCount() == 1);
    t.addSource(b.createSource('testSource2', 'nixSource'));

    clear t d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.sourceCount() == 2);
end

%% Test: Open Feature by id
function [] = testOpenFeature( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('featuretest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.createDataArray('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = t.createFeature(b.dataArrays{2}, nix.LinkType.Tagged);
    assert(~isempty(t.openFeature(t.features{1}.id)));

    %-- test open non existing feature
    getFeat = t.openFeature('I do not exist');
    assert(isempty(getFeat));
end

%% Test Open Feature by index
function [] = testOpenFeatureIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    f1 = b.createDataArray('testFeature1', 'nixDataArray', nix.DataType.Bool, [2 2]);
    f2 = b.createDataArray('testFeature2', 'nixDataArray', nix.DataType.Bool, [2 2]);
    f3 = b.createDataArray('testFeature3', 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.createFeature(f1, nix.LinkType.Tagged);
    t.createFeature(f2, nix.LinkType.Untagged);
    t.createFeature(f3, nix.LinkType.Indexed);

    assert(f.blocks{1}.multiTags{1}.openFeatureIdx(1).linkType == nix.LinkType.Tagged);
    assert(f.blocks{1}.multiTags{1}.openFeatureIdx(2).linkType == nix.LinkType.Untagged);
    assert(f.blocks{1}.multiTags{1}.openFeatureIdx(3).linkType == nix.LinkType.Indexed);
end

%% Test: Open reference by id or name
function [] = testOpenReference( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referencetest', 'nixMultiTag', b.dataArrays{1});
    refName = 'referenceTest';
    tmp = b.createDataArray(refName, 'nixDataArray', nix.DataType.Double, [3 4]);
    t.addReference(b.dataArrays{2}.id);

    getRefByID = t.openReference(t.references{1,1}.id);
    assert(~isempty(getRefByID));

    getRefByName = t.openReference(refName);
    assert(~isempty(getRefByName));

    %-- test open non existing reference
    getRef = t.openReference('I do not exist');
    assert(isempty(getRef));
end

%% Test Open reference by index
function [] = testOpenReferenceIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    r1 = b.createDataArray('testReference1', 'nixDataArray', nix.DataType.Bool, [2 2]);
    r2 = b.createDataArray('testReference2', 'nixDataArray', nix.DataType.Bool, [2 2]);
    r3 = b.createDataArray('testReference3', 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.addReference(r1);
    t.addReference(r2);
    t.addReference(r3);

    assert(strcmp(f.blocks{1}.multiTags{1}.openReferenceIdx(1).name, r1.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.openReferenceIdx(2).name, r2.name));
    assert(strcmp(f.blocks{1}.multiTags{1}.openReferenceIdx(3).name, r3.name));
end

%% Test: Feature count
function [] = testFeatureCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', da);

    assert(t.featureCount() == 0);
    t.createFeature(b.createDataArray('testDataArray1', 'nixDataArray', ...
        nix.DataType.Double, [1 2]), nix.LinkType.Tagged);
    assert(t.featureCount() == 1);
    t.createFeature(b.createDataArray('testDataArray2', 'nixDataArray', ...
        nix.DataType.Double, [3 4]), nix.LinkType.Tagged);

    clear t da b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.featureCount() == 2);
end

%% Test: Reference count
function [] = testReferenceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', da);

    assert(t.referenceCount() == 0);
    t.addReference(b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]));
    assert(t.referenceCount() == 1);
    t.addReference(b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]));
    
    clear t da b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.referenceCount() == 2);
end

%% Test: Set positions by entity and id
function [] = testSetPositions ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    posName1 = 'positionsTest1';
    posName2 = 'positionsTest2';
    
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('positionsTest', 'nixBlock');
    tmp = b.createDataArray('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createMultiTag('positionstest', 'nixMultiTag', b.dataArrays{1});

    tmp = b.createDataArray(posName1, 'nixDataArray', nix.DataType.Double, [0 1]);
    tmp = b.createDataArray(posName2, 'nixDataArray', nix.DataType.Double, [2 4]);

    t.setPositions(b.dataArrays{2}.id);
    assert(strcmp(t.openPositions.name, posName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.openPositions.name, posName1));

    t.setPositions(b.dataArrays{3});
    assert(strcmp(t.openPositions.name, posName2));
    assert(strcmp(f.blocks{1}.multiTags{1}.openPositions.name, posName2));
    
    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.openPositions.name, posName2));
end

%% Test: Has positions
function [] = testHasPositions( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('positionsTest', 'nixBlock');
    tmp = b.createDataArray('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createMultiTag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createDataArray('positionsTest1', 'nixDataArray', nix.DataType.Double, [0 1]);

    t.setPositions(b.dataArrays{2}.id);
    assert(t.hasPositions);
end

%% Test: Open positions
function [] = testOpenPositions( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('positionsTest', 'nixBlock');
    tmp = b.createDataArray('positionsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createMultiTag('positionstest', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createDataArray('positionsTest1', 'nixDataArray', nix.DataType.Double, [0 1]);

    t.setPositions(b.dataArrays{2}.id);
    assert(~isempty(t.openPositions));
end

%% Test: Set extents by entity and id, open and reset extents
function [] = testSetOpenExtents ( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('extentsTest', 'nixBlock');
    da = b.createDataArray('extentsTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6; 1 2 3 4 5 6]);
    t = b.createMultiTag('extentstest', 'nixMultiTag', da);

    tmp = b.createDataArray('positionsTest1', 'nixDataArray', nix.DataType.Double, [1, 1]);
    tmp = b.createDataArray('positionsTest2', 'nixDataArray', nix.DataType.Double, [1, 3]);

    extName1 = 'extentsTest1';
    extName2 = 'extentsTest2';
    tmp = b.createDataArray(extName1, 'nixDataArray', nix.DataType.Double, [1, 1]);
    tmp = b.createDataArray(extName2, 'nixDataArray', nix.DataType.Double, [1, 3]);

    assert(isempty(t.openExtents));
    assert(isempty(f.blocks{1}.multiTags{1}.openExtents));
    
    t.setPositions(b.dataArrays{2});
    t.setExtents(b.dataArrays{4}.id);
    assert(strcmp(t.openExtents.name, extName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.openExtents.name, extName1));

    t.setExtents('');
    assert(isempty(t.openExtents));
    assert(isempty(f.blocks{1}.multiTags{1}.openExtents));
    
    t.setPositions(b.dataArrays{3});
    t.setExtents(b.dataArrays{5});
    
    clear tmp t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.openExtents.name, extName2));
end

%% Test: Set metadata
function [] = testSetMetadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection(secName1, 'nixSection');
    tmp = f.createSection(secName2, 'nixSection');

    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createMultiTag('metadataTest', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(t.openMetadata));
    assert(isempty(f.blocks{1}.multiTags{1}.openMetadata));

    t.setMetadata(f.sections{1});
    assert(strcmp(t.openMetadata.name, secName1));
    assert(strcmp(f.blocks{1}.multiTags{1}.openMetadata.name, secName1));

    t.setMetadata(f.sections{2});
    assert(strcmp(t.openMetadata.name, secName2));
    assert(strcmp(f.blocks{1}.multiTags{1}.openMetadata.name, secName2));
    
    t.setMetadata('');
    assert(isempty(t.openMetadata));
    assert(isempty(f.blocks{1}.multiTags{1}.openMetadata));
    
    t.setMetadata(f.sections{2});

    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.multiTags{1}.openMetadata.name, secName2));
end

%% Test: Open metadata
function [] = testOpenMetadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createMultiTag('metadataTest', 'nixMultiTag', b.dataArrays{1});
    t.setMetadata(f.sections{1});

    assert(strcmp(t.openMetadata.name, 'testSection'));
end

%% Test: Retrieve reference data by id or name
function [] = testRetrieveData( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    pos(1,:) = [0, 0]; ext(1,:) = [0, 0]; % result 111
    pos(2,:) = [1, 1]; ext(2,:) = [0, 3]; % result 122 123 124
    pos(3,:) = [0, 2]; ext(3,:) = [1, 4]; % result 113 114 115 116
                                          %        123 124 125 126

	d_pos = b.createDataArrayFromData('positionsDA', 'nixDataArray', pos);
    d_pos.appendSetDimension(); 
    d_pos.appendSetDimension();

    d_ext = b.createDataArrayFromData('extentsDA', 'nixDataArray', ext);
    d_ext.appendSetDimension();
    d_ext.appendSetDimension();

    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d_pos);
    t.setExtents(d_ext);

    % create 2D reference data_arrays
    raw1 = [111, 112, 113, 114, 115, 116, 117, 118; ...
                121, 122, 123, 124, 125, 126, 127, 128];
    d1 = b.createDataArrayFromData('reference1', 'nixDataArray', raw1);
    d1.appendSampledDimension(1);
    d1.appendSampledDimension(1);

    raw2 = [211, 212, 213, 214, 215, 216, 217, 218; ...
                221, 222, 223, 224, 225, 226, 227, 228];
    d2 = b.createDataArrayFromData('reference2', 'nixDataArray', raw2);
    d2.appendSampledDimension(1);
    d2.appendSampledDimension(1);

    % add data_arrays as references to multi tag
    t.addReference(d1);
    t.addReference(d2);

    % test invalid position idx
    try
        t.retrieveData(100, 'reference1');
    catch ME
        assert(~isempty(strfind(ME.message, 'ounds of positions or extents')), ...
            'Invalid position index failed');
    end
    assert(exist('ME') == 1, 'Invalid position index fail, error not raised');
    clear ME;

    % test invalid reference name
    try
        t.retrieveData(1, 'I do not exist');
    catch ME
        assert(~isempty(strfind(ME.message, 'no DataArray with the specified name or id')), ...
            'Invalid reference name failed');
    end
    assert(exist('ME') == 1, 'Invalid reference name fail, error not raised');
    clear ME;
 
    assert(isequal(t.retrieveData(1, d1.name), raw1(1:1)), 'Retrieve pos 1, ref 1 fail');
    assert(isequal(t.retrieveData(2, d1.id), raw1(2, 2:5)), 'Retrieve pos 2, ref 1 fail');
    assert(isequal(t.retrieveData(3, d2.id), raw2(1:2, 3:7)), 'Retrieve pos 3, ref 2 fail');
end

%% Test: Retrieve reference data by index
function [] = testRetrieveDataIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    pos(1,:) = [0, 0]; ext(1,:) = [0, 0]; % result 111
    pos(2,:) = [1, 1]; ext(2,:) = [0, 3]; % result 122 123 124
    pos(3,:) = [0, 2]; ext(3,:) = [1, 4]; % result 113 114 115 116
                                          %        123 124 125 126

	d_pos = b.createDataArrayFromData('positionsDA', 'nixDataArray', pos);
    d_pos.appendSetDimension();
    d_pos.appendSetDimension();

    d_ext = b.createDataArrayFromData('extentsDA', 'nixDataArray', ext);
    d_ext.appendSetDimension();
    d_ext.appendSetDimension();

    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d_pos);
    t.setExtents(d_ext);

    % create 2D reference data_arrays
    raw1 = [111, 112, 113, 114, 115, 116, 117, 118; ...
                121, 122, 123, 124, 125, 126, 127, 128];
    d1 = b.createDataArrayFromData('reference1', 'nixDataArray', raw1);
    d1.appendSampledDimension(1);
    d1.appendSampledDimension(1);

    raw2 = [211, 212, 213, 214, 215, 216, 217, 218; ...
                221, 222, 223, 224, 225, 226, 227, 228];
    d2 = b.createDataArrayFromData('reference2', 'nixDataArray', raw2);
    d2.appendSampledDimension(1);
    d2.appendSampledDimension(1);

    % add data_arrays as references to multi tag
    t.addReference(d1);
    t.addReference(d2);

    % test invalid position idx
    try
        t.retrieveDataIdx(100, 1);
    catch ME
        assert(~isempty(strfind(ME.message, 'ounds of positions or extents')), ...
            'Invalid position index failed');
    end

    % test invalid reference idx
    try
        t.retrieveDataIdx(1, 100);
    catch ME
        assert(~isempty(strfind(ME.message, 'out of bounds')), ...
            'Invalid reference index failed');
    end
    
    assert(isequal(t.retrieveDataIdx(1, 1), raw1(1:1)), 'Retrieve pos 1, ref 1 fail');
    assert(isequal(t.retrieveDataIdx(2, 1), raw1(2, 2:5)), 'Retrieve pos 2, ref 1 fail');
    assert(isequal(t.retrieveDataIdx(3, 2), raw2(1:2, 3:7)), 'Retrieve pos 3, ref 2 fail');
end

%% Test: Retrieve Feature data by id or name
function [] = testRetrieveFeatureData( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    % create feature data arrays
    raw_feat1 = [11 12 13 14 15 16 17 18];
    da_feat1 = b.createDataArrayFromData('feature1', 'nixDataArray', raw_feat1);
    da_feat1.appendSampledDimension(1);

    raw_feat2 = [21 22 23 24 25 26 27 28];
    da_feat2 = b.createDataArrayFromData('feature2', 'nixDataArray', raw_feat2);
    da_feat2.appendSampledDimension(1);

    % create referenced data array
    raw_feat3 = [31 32 33 34 35 36 37 38];
    da_feat3 = b.createDataArrayFromData('reference', 'nixDataArray', raw_feat3);
    da_feat3.appendSampledDimension(1);

    % create position, extents DA and multi tag
    pos = [0 3 4];
    ext = [1 1 3];

    da_pos = b.createDataArrayFromData('positions', 'nixDataArray', pos);
    da_ext = b.createDataArrayFromData('extents', 'nixDataArray', ext);

    da_pos.appendSetDimension();
    da_ext.appendSetDimension();

    t = b.createMultiTag('testMultiTag', 'nixMultiTag', da_pos);
    t.setExtents(da_ext);

    % add feature data_arrays
    t.createFeature(da_feat1, nix.LinkType.Untagged);
    t.createFeature(da_feat2, nix.LinkType.Tagged);
    t.createFeature(da_feat3, nix.LinkType.Indexed);

    % test invalid position idx
    try
        t.retrieveFeatureData(100, '');
    catch ME
        assert(isempty(strfind(ME.message, 'ounds of positions or extents')), ...
            'Invalid position index failed');
    end
    assert(exist('ME') == 1, 'Invalid position index fail, error not raised');
    clear ME;

    % test invalid name or id
    try
        t.retrieveFeatureData(1, 'I do not exist');
    catch ME
        assert(~isempty(strfind(ME.message, 'no Feature with the specified name or id')), ...
            'Invalid reference name failed');
    end
    assert(exist('ME') == 1, 'Invalid reference name fail, error not raised');
    clear ME;

    % test untagged ignores position and returns full data
    retData = t.retrieveFeatureData(1, da_feat1.name);
    assert(isequal(raw_feat1, retData), 'Untagged fail');

    % test tagged properly applies position and extents
    retData = t.retrieveFeatureData(1, da_feat2.id);
    assert(isequal(retData, [21, 22]), 'Tagged pos 1 fail');

    retData = t.retrieveFeatureData(2, da_feat2.name);
    assert(isequal(retData, [24, 25]), 'Tagged pos 2 fail');

    retData = t.retrieveFeatureData(3, da_feat2.id);
    assert(isequal(retData, [25, 26, 27, 28]), 'Tagged pos 3 fail');

    % test indexed returns first and last index value
    retData = t.retrieveFeatureData(1, da_feat3.id);
    assert(isequal(retData, raw_feat3(1)), 'Indexed first pos fail');
    
    retData = t.retrieveFeatureData(2, da_feat3.name);
    assert(isequal(retData, raw_feat3(2)), 'Indexed last pos fail');
    
    % test indexed fail when accessing position > length of referenced array
    try
        t.retrieveFeatureData(size(raw_feat3, 2) + 2, da_feat3.id);
    catch ME
        assert(~isempty(strfind(ME.message, 'ounds of positions')), ...
            'Indexed out of length fail');
    end
    assert(exist('ME') == 1, 'Indexed out of length fail, error not raised');
    clear ME;
end

%% Test: Retrieve Feature data by idx
function [] = testRetrieveFeatureDataIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');

    % create feature data arrays
    raw_feat1 = [11 12 13 14 15 16 17 18];
    da_feat1 = b.createDataArrayFromData('feature1', 'nixDataArray', raw_feat1);
    da_feat1.appendSampledDimension(1);

    raw_feat2 = [21 22 23 24 25 26 27 28];
    da_feat2 = b.createDataArrayFromData('feature2', 'nixDataArray', raw_feat2);
    da_feat2.appendSampledDimension(1);

    % create referenced data array
    raw_feat3 = [31 32 33 34 35 36 37 38];
    da_feat3 = b.createDataArrayFromData('reference', 'nixDataArray', raw_feat3);
    da_feat3.appendSampledDimension(1);

    % create position, extents DA and multi tag
    pos = [0 3 4];
    ext = [1 1 3];

    da_pos = b.createDataArrayFromData('positions', 'nixDataArray', pos);
    da_ext = b.createDataArrayFromData('extents', 'nixDataArray', ext);

    da_pos.appendSetDimension();
    da_ext.appendSetDimension();

    t = b.createMultiTag('testMultiTag', 'nixMultiTag', da_pos);
    t.setExtents(da_ext);

    % add feature data_arrays
    t.createFeature(da_feat1, nix.LinkType.Untagged);
    t.createFeature(da_feat2, nix.LinkType.Tagged);
    t.createFeature(da_feat3, nix.LinkType.Indexed);

    % test invalid position idx
    try
        t.retrieveFeatureDataIdx(100, 2);
    catch ME
        assert(~isempty(strfind(ME.message, 'ounds of positions')), ...
            'Invalid position index failed');
    end
    assert(exist('ME') == 1, 'Invalid position index fail, error not raised');
    clear ME;

    % test invalid feature idx
    try
        t.retrieveFeatureDataIdx(1, 100);
    catch ME
        assert(~isempty(strfind(ME.message, 'out of bounds')), ...
            'Invalid reference index failed');
    end
    assert(exist('ME') == 1, 'Invalid reference index fail, error not raised');
    clear ME;

    % test untagged ignores position and returns full data
    retData = t.retrieveFeatureDataIdx(1, 1);
    assert(isequal(raw_feat1, retData), 'Untagged fail');

    % test tagged properly applies position and extents
    retData = t.retrieveFeatureDataIdx(1, 2);
    assert(isequal(retData, [21, 22]), 'Tagged pos 1 fail');

    retData = t.retrieveFeatureDataIdx(2, 2);
    assert(isequal(retData, [24, 25]), 'Tagged pos 2 fail');

    retData = t.retrieveFeatureDataIdx(3, 2);
    assert(isequal(retData, [25, 26, 27, 28]), 'Tagged pos 3 fail');

    % test indexed returns first and last index value
    retData = t.retrieveFeatureDataIdx(1, 3);
    assert(isequal(retData, raw_feat3(1)), 'Indexed first pos fail');
    
    retData = t.retrieveFeatureDataIdx(3, 3);
    assert(isequal(retData, raw_feat3(3)), 'Indexed last pos fail');
    
    % test indexed fail when accessing position > length of referenced array
    try
        t.retrieveFeatureDataIdx(size(raw_feat3, 2) + 2, 3);
    catch ME
        assert(~isempty(strfind(ME.message, 'ounds of positions')), ...
            'Indexed out of length fail');
    end
    assert(exist('ME') == 1, 'Indexed out of length fail, error not raised');
    clear ME;
end

%% Test: Has Feature by id
function [] = testHasFeature( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    da = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('featureTest', 'nixMultiTag', da);
    daf = b.createDataArray('featTestDA', 'nixDataArray', nix.DataType.Double, [1 2]);
    feature = t.createFeature(daf, nix.LinkType.Tagged);
    featureID = feature.id;

    assert(~t.hasFeature('I do not exist'));
    assert(t.hasFeature(featureID));

    clear feature daf t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.hasFeature(featureID));
end

%% Test: Has reference by id or name
function [] = testHasReference( varargin )
    fileName = 'testRW.h5';
    daName = 'refTestDataArray';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTestBlock', 'nixBlock');
    da = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('referenceTest', 'nixMultiTag', da);
    refName = 'referenceTest';
    daRef = b.createDataArray(refName, 'nixDataArray', nix.DataType.Double, [3 4]);
    t.addReference(daRef.id);

    assert(~t.hasReference('I do not exist'));
    assert(t.hasReference(daRef.id));

    clear t daRef da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.multiTags{1}.hasReference(refName));
end

%% Test: Set units
function [] = testSetUnits( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('unitsTest', 'nixMultiTag', da);

    assert(isempty(t.units));
    try
        t.units = 'mV';
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
    try
        t.units = ['mV', 'uA'];
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;

    units = {'mV'};
    t.units = {'mV'};
    assert(isequal(t.units,units));
    t.units = {};
    assert(isempty(t.units));
    newUnits = {'mV', 'uA'};
    t.units = newUnits;
    
    clear t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.multiTags{1}.units, newUnits));
end

%% Test: Read and write attributes
function [] = testAttributes( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    tmp = b.createDataArray('attributeTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', b.dataArrays{1});

    testType = 'setType';
    testDefinition = 'definition';

    assert(~isempty(t.id));
    assert(strcmp(t.name, 'testMultiTag'));
    assert(strcmp(t.type, 'nixMultiTag'));

    % test set type
    t.type = testType;
    assert(strcmp(t.type, testType));

    % test set definition
    assert(isempty(t.definition));
    t.definition = testDefinition;
    assert(strcmp(t.definition, testDefinition));

    % test set definition none
    t.definition = '';
    assert(isempty(t.definition));

    clear t tmp b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.multiTags{1}.type, testType));
end

%% Test: Compare MultiTag entities
function [] = testCompare( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d = b1.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 2]);
    t1 = b1.createMultiTag('testMultiTag1', 'nixMultiTag', d);
    t2 = b1.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    d = b2.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 2]);
    t3 = b2.createMultiTag('testMultiTag1', 'nixMultiTag', d);

    assert(t1.compare(t2) < 0);
    assert(t1.compare(t1) == 0);
    assert(t2.compare(t1) > 0);
    assert(t1.compare(t3) ~= 0);
end

%% Test: Filter Sources
function [] = testFilterSource( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 3]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    s = b.createSource(filterName, 'nixSource');
    t.addSource(s);
    filterID = s.id;
	s = b.createSource('testSource1', filterType);
    t.addSource(s);
    filterIDs = {filterID, s.id};
    s = b.createSource('testSource2', filterType);
    t.addSource(s);

    % test empty id filter
    assert(isempty(f.blocks{1}.multiTags{1}.filterSources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.createSource(mainName, 'nixSource');
    t.addSource(mainSource);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.setMetadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.multiTags{1}.filterSources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createSource(mainName, 'nixSource');
    t.addSource(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = main.createSource(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.multiTags{1}.filterSources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.multiTags{1}.filterSources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: Filter references
function [] = testFilterReference( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 7]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    d = b.createDataArray(filterName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t.addReference(d);
    filterID = d.id;
	d = b.createDataArray('testDataArray1', filterType, nix.DataType.Double, [1 2]);
    t.addReference(d);
    filterIDs = {filterID, d.id};
    d = b.createDataArray('testDataArray2', filterType, nix.DataType.Double, [1 2]);
    t.addReference(d);

    % test empty id filter
    assert(isempty(f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.addReference(main);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    main.setMetadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.addReference(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    main.addSource(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.source, 'Do not exist')));

    % filter works only for ID, not for name
    filtered = f.blocks{1}.multiTags{1}.filterReferences(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: Filter Features
function [] = testFilterFeature( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 7]);
    t = b.createMultiTag('testMultiTag', 'nixMultiTag', d);
    d = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    feat = t.createFeature(d, nix.LinkType.Tagged);
    filterID = feat.id;
	d = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    feat = t.createFeature(d, nix.LinkType.Tagged);
    filterIDs = {filterID, feat.id};

    % test empty id filter
    assert(isempty(f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 2);

    % test nix.Filter.id
    filtered = f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));

    % test fail on nix.Filter.name
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.name, 'someName');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.type
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.type, 'someType');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        f.blocks{1}.multiTags{1}.filterFeatures(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end
end
