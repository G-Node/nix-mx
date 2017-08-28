% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestTag
% TESTTag tests for Tag

    funcs = {};
    funcs{end+1} = @testAddSource;
    funcs{end+1} = @testAddSources;
    funcs{end+1} = @testRemoveSource;
    funcs{end+1} = @testAddReference;
    funcs{end+1} = @testAddReferences;
    funcs{end+1} = @testRemoveReference;
    funcs{end+1} = @testAddFeature;
    funcs{end+1} = @testRemoveFeature;
    funcs{end+1} = @testFetchReferences;
    funcs{end+1} = @testReferenceCount;
    funcs{end+1} = @testFetchSources;
    funcs{end+1} = @testFetchFeatures;
    funcs{end+1} = @testFeatureCount;
    funcs{end+1} = @testOpenSource;
    funcs{end+1} = @testOpenSourceIdx;
    funcs{end+1} = @testHasSource;
    funcs{end+1} = @testSourceCount;
    funcs{end+1} = @testOpenFeature;
    funcs{end+1} = @testOpenFeatureIdx;
    funcs{end+1} = @testOpenReference;
    funcs{end+1} = @testOpenReference_idx;
    funcs{end+1} = @testSetMetadata;
    funcs{end+1} = @testOpenMetadata;
    funcs{end+1} = @testRetrieveData;
    funcs{end+1} = @testRetrieveDataIdx;
    funcs{end+1} = @testRetrieveFeatureData;
    funcs{end+1} = @testRetrieveFeatureDataIdx;
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testHasFeature;
    funcs{end+1} = @testHasReference;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSource;
    funcs{end+1} = @testFilterReference;
    funcs{end+1} = @testFilterFeature;
end

%% Test: Add sources by entity and id
function [] = testAddSource ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('sourcetest', 'nixTag', position);
    
    assert(isempty(t.sources));
    assert(isempty(f.blocks{1}.tags{1}.sources));
    t.add_source(s.sources{1}.id);
    t.add_source(s.sources{2});
    assert(size(t.sources, 1) == 2);
    assert(size(f.blocks{1}.tags{1}.sources, 1) == 2);
    
    clear tmp t s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags{1}.sources, 1) == 2);
end

%% Test: Add sources by entity cell array
function [] = testAddSources ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2]);
    tmp = b.createSource('testSource1', 'nixSource');
    tmp = b.createSource('testSource2', 'nixSource');
    tmp = b.createSource('testSource3', 'nixSource');

    assert(isempty(t.sources));

    try
        t.add_sources('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(t.sources));

    try
        t.add_sources({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Source')));
    end;
    assert(isempty(t.sources));

    t.add_sources(b.sources());
    assert(size(t.sources, 1) == 3);

    clear t tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags{1}.sources, 1) == 3);
end

%% Test: Remove sources by entity and id
function [] = testRemoveSource ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    s = b.createSource('test', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('sourcetest', 'nixTag', position);
    t.add_source(s.sources{1}.id);
    t.add_source(s.sources{2});

    assert(size(t.sources,1) == 2);
    t.remove_source(s.sources{2});
    assert(size(t.sources,1) == 1);
    t.remove_source(s.sources{1}.id);
    assert(isempty(t.sources));
    assert(t.remove_source('I do not exist'));
    assert(size(s.sources,1) == 2);
end

%% Test: Add references by entity and id
function [] = testAddReference ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('referenceTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('referenceTest', 'nixTag', position);
    
    assert(isempty(t.references));
    assert(isempty(f.blocks{1}.tags{1}.references));

    t.addReference(b.dataArrays{1}.id);
    t.addReference(b.dataArrays{2});
    assert(size(t.references, 1) == 2);
    assert(size(f.blocks{1}.tags{1}.references, 1) == 2);

    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags{1}.references, 1) == 2);
end

%% Test: Add references by entity cell array
function [] = testAddReferences ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2]);
    tmp = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
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
    assert(size(f.blocks{1}.tags{1}.references, 1) == 3);
end

%% Test: Remove references by entity and id
function [] = testRemoveReference ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    getRefDA1 = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    getRefDA2 = b.createDataArray('referenceTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('referenceTest', 'nixTag', position);
    t.addReference(b.dataArrays{1}.id);
    t.addReference(b.dataArrays{2});
    assert(size(t.references, 1) == 2);

    t.removeReference(b.dataArrays{2});
    assert(size(t.references, 1) == 1);
    t.removeReference(b.dataArrays{1}.id);
    assert(isempty(t.references));
    assert(~t.removeReference('I do not exist'));
    assert(size(b.dataArrays, 1) == 2);
end

%% Test: Add features by entity and id
function [] = testAddFeature ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('featureTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray('featureTestDataArray3', 'nixDataArray', nix.DataType.Double, [5 6]);
    tmp = b.createDataArray('featureTestDataArray4', 'nixDataArray', nix.DataType.Double, [7 8]);
    tmp = b.createDataArray('featureTestDataArray5', 'nixDataArray', nix.DataType.Double, [9 10]);
    tmp = b.createDataArray('featureTestDataArray6', 'nixDataArray', nix.DataType.Double, [11 12]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('featureTest', 'nixTag', position);
    
    assert(isempty(t.features));
    assert(isempty(f.blocks{1}.tags{1}.features));
    tmp = t.addFeature(b.dataArrays{1}.id, nix.LinkType.Tagged);
    tmp = t.addFeature(b.dataArrays{2}, nix.LinkType.Tagged);
    tmp = t.addFeature(b.dataArrays{3}.id, nix.LinkType.Untagged);
    tmp = t.addFeature(b.dataArrays{4}, nix.LinkType.Untagged);
    tmp = t.addFeature(b.dataArrays{5}.id, nix.LinkType.Indexed);
    tmp = t.addFeature(b.dataArrays{6}, nix.LinkType.Indexed);
    assert(size(t.features, 1) == 6);
    assert(size(f.blocks{1}.tags{1}.features, 1) == 6);

    clear tmp t b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.tags{1}.features, 1) == 6);
end

%% Test: Remove features by entity and id
function [] = testRemoveFeature ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('featureTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('featureTest', 'nixTag', position);
    tmp = t.addFeature(b.dataArrays{1}.id, nix.LinkType.Tagged);
    tmp = t.addFeature(b.dataArrays{2}, nix.LinkType.Tagged);

    assert(t.removeFeature(t.features{2}.id));
    assert(t.removeFeature(t.features{1}));
    assert(isempty(t.features));

    assert(~t.removeFeature('I do not exist'));
    assert(size(b.dataArrays, 1) == 2);
end

%% Test: fetch references
function [] = testFetchReferences( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTest1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('referenceTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createDataArray('referenceTest3', 'nixDataArray', nix.DataType.Double, [5 6]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('referenceTest', 'nixTag', position);
    
    t.addReference(b.dataArrays{1});
    t.addReference(b.dataArrays{2});
    t.addReference(b.dataArrays{3});
    assert(size(t.references, 1) == 3);
end

%% Test: Reference count
function [] = testReferenceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2]);

    assert(t.referenceCount() == 0);
    t.addReference(b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]));
    assert(t.referenceCount() == 1);
    t.addReference(b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]));
    
    clear t b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.referenceCount() == 2);
end

%% Test: fetch sources
function [] = testFetchSources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    s = b.createSource('test','nixSource');
    tmp = s.createSource('nestedsource1', 'nixSource');
    tmp = s.createSource('nestedsource2', 'nixSource');
    tmp = s.createSource('nestedsource3', 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('tagtest', 'nixTag', position);
    
    t.add_source(s.sources{1});
    t.add_source(s.sources{2});
    t.add_source(s.sources{3});
    assert(size(t.sources, 1) == 3);
end

%% Test: fetch features
function [] = testFetchFeatures( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray('featureTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('featureTest', 'nixTag', position);

    tmp = t.addFeature(b.dataArrays{1}, nix.LinkType.Tagged);
    tmp = t.addFeature(b.dataArrays{2}, nix.LinkType.Tagged);

    assert(size(t.features, 1) == 2);
end

%% Test: Feature count
function [] = testFeatureCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2]);

    assert(t.featureCount() == 0);
    t.addFeature(b.createDataArray('testDataArray1', 'nixDataArray', ...
        nix.DataType.Double, [1 2]), nix.LinkType.Tagged);
    assert(t.featureCount() == 1);
    t.addFeature(b.createDataArray('testDataArray2', 'nixDataArray', ...
        nix.DataType.Double, [3 4]), nix.LinkType.Tagged);
    
    clear t b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.featureCount() == 2);
end

%% Test: Open source by ID or name
function [] = testOpenSource( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    s = b.createSource('test', 'nixSource');
    sourceName = 'nestedsource';
    createSource = s.createSource(sourceName, 'nixSource');
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('tagtest', 'nixTag', position);
    t.add_source(s.sources{1});

    getSourceByID = t.open_source(createSource.id);
    assert(~isempty(getSourceByID));
    
    getSourceByName = t.open_source(sourceName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getNonSource = t.open_source('I do not exist');
    assert(isempty(getNonSource));
end

function [] = testOpenSourceIdx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [2 9]);
    s1 = b.createSource('testSource1', 'nixSource');
    s2 = b.createSource('testSource2', 'nixSource');
    s3 = b.createSource('testSource3', 'nixSource');
    t.add_source(s1);
    t.add_source(s2);
    t.add_source(s3);

    assert(strcmp(f.blocks{1}.tags{1}.open_source_idx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.tags{1}.open_source_idx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.tags{1}.open_source_idx(3).name, s3.name));
end

%% Test: nix.Tag has nix.Source by ID or entity
function [] = testHasSource( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    s = b.createSource('sourceTest1', 'nixSource');
    sID = s.id;
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('tagTest', 'nixTag', position);
    t.add_source(b.sources{1});

    assert(~t.has_source('I do not exist'));
    assert(t.has_source(s));

    clear t s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.has_source(sID));
end

%% Test: Source count
function [] = testSourceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1.0 1.2]);

    assert(t.source_count() == 0);
    t.add_source(b.createSource('testSource1', 'nixSource'));
    assert(t.source_count() == 1);
    t.add_source(b.createSource('testSource2', 'nixSource'));

    clear t b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.source_count() == 2);
end

%% Test: Open feature by ID
function [] = testOpenFeature( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('featureTest', 'nixTag', position);
    tmp = t.addFeature(b.dataArrays{1}, nix.LinkType.Tagged);

    assert(~isempty(t.openFeature(t.features{1}.id)));

    %-- test open non existing feature
    getFeat = t.openFeature('I do not exist');
    assert(isempty(getFeat));
end

function [] = testOpenFeatureIdx( varargin )
%% Test Open feature by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [2 9]);
    d1 = b.createDataArray('testFeature1', 'nixDataArray', nix.DataType.Double, [1 2]);
    d2 = b.createDataArray('testFeature2', 'nixDataArray', nix.DataType.Double, [3 2]);
    d3 = b.createDataArray('testFeature3', 'nixDataArray', nix.DataType.Double, [7 2]);
    t.addFeature(d1, nix.LinkType.Tagged);
    t.addFeature(d2, nix.LinkType.Untagged);
    t.addFeature(d3, nix.LinkType.Indexed);

    assert(f.blocks{1}.tags{1}.openFeatureIdx(1).linkType == nix.LinkType.Tagged);
    assert(f.blocks{1}.tags{1}.openFeatureIdx(2).linkType == nix.LinkType.Untagged);
    assert(f.blocks{1}.tags{1}.openFeatureIdx(3).linkType == nix.LinkType.Indexed);
end

%% Test: Open reference by ID or name
function [] = testOpenReference( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    tmp = b.createDataArray('referenceTest', 'nixDataArray', nix.DataType.Double, [1 2]);
    position = [1.0 1.2 1.3 15.9];
    t = b.createTag('referenceTest', 'nixTag', position);
    t.addReference(b.dataArrays{1});

    getRefByID = t.openReference(t.references{1,1}.id);
    assert(~isempty(getRefByID));
    
    getRefByName = t.openReference(t.references{1,1}.name);
    assert(~isempty(getRefByName));
    
    %-- test open non existing source
    getNonRef = t.openReference('I do not exist');
    assert(isempty(getNonRef));
end

function [] = testOpenReference_idx( varargin )
%% Test Open reference by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [2 9]);
    d1 = b.createDataArray('testReference1', 'nixDataArray', nix.DataType.Double, [1 2]);
    d2 = b.createDataArray('testReference2', 'nixDataArray', nix.DataType.Double, [3 2]);
    d3 = b.createDataArray('testReference3', 'nixDataArray', nix.DataType.Double, [7 2]);
    t.addReference(d1);
    t.addReference(d2);
    t.addReference(d3);

    assert(strcmp(f.blocks{1}.tags{1}.openReferenceIdx(1).name, d1.name));
    assert(strcmp(f.blocks{1}.tags{1}.openReferenceIdx(2).name, d2.name));
    assert(strcmp(f.blocks{1}.tags{1}.openReferenceIdx(3).name, d3.name));
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
    t = b.createTag('testTag', 'nixTag', [1, 2, 3, 4]);

    assert(isempty(t.open_metadata));
    assert(isempty(f.blocks{1}.tags{1}.open_metadata));
    
    t.set_metadata(f.sections{1});
    assert(strcmp(t.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.tags{1}.open_metadata.name, secName1));
    
    t.set_metadata(f.sections{2});
    assert(strcmp(t.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.tags{1}.open_metadata.name, secName2));
    
    t.set_metadata('');
    assert(isempty(t.open_metadata));
    assert(isempty(f.blocks{1}.tags{1}.open_metadata));
    
    t.set_metadata(f.sections{2});
    clear tmp b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.tags{1}.open_metadata.name, secName2));
end

%% Test: Open metadata
function [] = testOpenMetadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1, 2, 3, 4]);

    t.set_metadata(f.sections{1});
    assert(strcmp(t.open_metadata.name, 'testSection'));
end

%% Test: Retrieve referenced data by name and id
function [] = testRetrieveData( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    tagStartPos = [3];
    t = b.createTag('testTag', 'nixTag', tagStartPos);
    t.extent = [3];

    rawName = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    rawID = [11, 12, 13, 14, 15, 16, 17];
    d = b.createDataArrayFromData('testDataArrayName', 'nixDataArray', rawName);
    d.appendSampledDimension(1);
    t.addReference(d);

    d = b.createDataArrayFromData('testDataArrayID', 'nixDataArray', rawID);
    d.appendSampledDimension(1);
    t.addReference(d);

    % test get non existent
    try
        retData = t.retrieveData('I do not exist, dont hate me!');
    catch ME
        assert(~isempty(strfind(ME.message, 'no DataArray with the specified name')), ...
            'Non existent check fail');
    end

    % test get referenced data by name
    retData = t.retrieveData('testDataArrayName');
    assert(size(retData, 2) == t.extent, 'Get by name extent check fail');
    assert(retData(1) == rawName(t.position + 1), 'Get by name position check fail');

    % test get referenced data by id
    retData = t.retrieveData(d.id);
    assert(size(retData, 2) == t.extent, 'Get by id extent check fail');
    assert(retData(1) == rawID(t.position + 1), 'Get by id position check fail');
end

%% Test: Retrieve referenced data by index
function [] = testRetrieveDataIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    raw = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    d = b.createDataArrayFromData('testDataArray', 'nixDataArray', raw);
    d.appendSampledDimension(1);
    % tag positon is used like an index, therfore starts with 0!
    tagStartPos = [3];
    t = b.createTag('testTag', 'nixTag', tagStartPos);
    t.extent = [3];
    t.addReference(d);

    try
        t.retrieveDataIdx(12);
    catch ME
        assert(~isempty(strfind(ME.message, 'out of bounds')), 'Invalid index failed');
    end

    retData = t.retrieveDataIdx(1);
    assert(size(retData, 2) == t.extent, 'Extent check failed');
    assert(retData(1) == raw(t.position + 1), 'Position check failed');
end

%% Test: Retrieve feature data by name and id
function [] = testRetrieveFeatureData( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    raw = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    d = b.createDataArrayFromData('testDataArray', 'nixDataArray', raw);
    d.appendSampledDimension(1);
    tagStartPos = [3];
    t = b.createTag('testTag', 'nixTag', tagStartPos);
    t.extent = [3];
    t.addReference(d);

    rawFeature = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

    % test get non existent
    try
        t.retrieveData('I do not exist, dont hate me!');
    catch ME
        assert(~isempty(strfind(ME.message, 'no DataArray with the specified name')), ...
            'Non existent check fail');
    end

    % test retrieve untagged feature data by name
    df = b.createDataArrayFromData('testUntagged', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Untagged);
    retData = t.retrieveFeatureData('testUntagged');
    assert(size(retData, 2) == size(rawFeature, 2), 'Untagged size check fail');

    % test retrieve tagged feature data by id
    df = b.createDataArrayFromData('testTagged', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Tagged);
    retData = t.retrieveFeatureData(df.id);
    assert(size(retData, 2) == t.extent, 'Tagged Extent check fail');
    assert(retData(1) == rawFeature(t.position + 1), 'Tagged Position check fail');

    % test retrieve indexed feature data by id
    df = b.createDataArrayFromData('testIndexed', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Indexed);
    retData = t.retrieveFeatureData(df.id);
    assert(size(retData, 2) == size(rawFeature, 2), 'Indexed size check fail');
end

%% Test: Retrieve feature data by index
function [] = testRetrieveFeatureDataIdx( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    raw = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    d = b.createDataArrayFromData('testDataArray', 'nixDataArray', raw);
    d.appendSampledDimension(1);
    tagStartPos = [3];
    t = b.createTag('testTag', 'nixTag', tagStartPos);
    t.extent = [3];
    t.addReference(d);

    rawFeature = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

    % test retrieve untagged feature data 
    df = b.createDataArrayFromData('testUntagged', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Untagged);
    retData = t.retrieveFeatureDataIdx(1);
    assert(size(retData, 2) == size(rawFeature, 2), 'Untagged size check fail');

    % test retrieve tagged feature data 
    df = b.createDataArrayFromData('testTagged', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Tagged);
    retData = t.retrieveFeatureDataIdx(2);
    assert(size(retData, 2) == t.extent, 'Tagged Extent check fail');
    assert(retData(1) == rawFeature(t.position + 1), 'Tagged Position check fail');

    % test retrieve indexed feature data
    df = b.createDataArrayFromData('testIndexed', 'nixDataArray', rawFeature);
    df.appendSampledDimension(1);
    t.addFeature(df, nix.LinkType.Indexed);
    retData = t.retrieveFeatureDataIdx(3);
    assert(size(retData, 2) == size(rawFeature, 2), 'Indexed size check fail');

    try
        t.retrieveFeatureDataIdx(12);
    catch ME
        assert(~isempty(strfind(ME.message, 'out of bounds')), 'Invalid index check fail');
    end
end

%% Test: Read and write nix.Tag attributes
function [] = testAttributes( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    pos = [1, 2, 3, 4];
    t1 = b.createTag('testTag', 'nixTag', pos);

    assert(~isempty(t1.id));
    assert(strcmp(t1.name, 'testTag'));
    assert(strcmp(t1.type, 'nixTag'));

    t1.type = 'nixTagTest';
    assert(strcmp(t1.type, 'nixTagTest'));

    assert(isempty(t1.definition));
    t1.definition = 'definition';
    assert(strcmp(t1.definition, 'definition'));

    t1.definition = '';
    assert(isempty(t1.definition));

    assert(isempty(t1.units));
    try
        t1.units = 'mV';
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
    try
        t1.units = ['mV', 'uA'];
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;

    t1.units = {'ms', 'mV'};
    assert(isequal(t1.units, {'ms', 'mV'}));

    t1.units = {};
    assert(isempty(t1.units));

    assert(isequal(t1.position, pos));
    newPos = [1, 2.2, 3];
    t1.position = newPos;
    assert(~isequal(t1.position, pos));
    assert(isequal(t1.position, newPos));

    assert(isempty(t1.extent));
    ext = [1 2];
    newExt = [3 4.5];
    lastExt = [6 7.8 9];
    t1.extent = ext;
    assert(isequal(t1.extent, ext));
    t1.extent = newExt;
    assert(~isequal(t1.extent, ext));
    assert(isequal(t1.extent, newExt));
    t1.extent = [];
    assert(isempty(t1.extent));
    t1.extent = lastExt;

    clear t1 b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.tags{1}.position, newPos));
    assert(isequal(f.blocks{1}.tags{1}.extent, lastExt));
end

%% Test: nix.Tag has feature by ID
function [] = testHasFeature( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    da = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createTag('featureTest', 'nixTag', [1.0 1.2 1.3 15.9]);
    feature = t.addFeature(b.dataArrays{1}, nix.LinkType.Tagged);
    featureID = feature.id;

    assert(~t.hasFeature('I do not exist'));
    assert(t.hasFeature(featureID));

    clear tmp t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.hasFeature(featureID));
end

%% Test: nix.Tag has reference by ID or name
function [] = testHasReference( varargin )
    fileName = 'testRW.h5';
    daName = 'referenceTest';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('referenceTest', 'nixBlock');
    da = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createTag('referenceTest', 'nixTag', [1.0 1.2 1.3 15.9]);
    t.addReference(b.dataArrays{1});

    assert(~t.hasReference('I do not exist'));
    assert(t.hasReference(da.id));
    
    clear t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.hasReference(daName));
end

function [] = testCompare( varargin )
%% Test: Compare Tag entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    t1 = b1.createTag('testTag1', 'nixTag', [1 2 3]);
    t2 = b1.createTag('testTag2', 'nixTag', [1 2 3]);
    t3 = b2.createTag('testTag1', 'nixTag', [1 2 3]);

    assert(t1.compare(t2) < 0);
    assert(t1.compare(t1) == 0);
    assert(t2.compare(t1) > 0);
    assert(t1.compare(t3) ~= 0);
end

%% Test: filter sources
function [] = testFilterSource( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2 3]);
    s = b.createSource(filterName, 'nixSource');
    t.add_source(s);
    filterID = s.id;
	s = b.createSource('testSource1', filterType);
    t.add_source(s);
    filterIDs = {filterID, s.id};
    s = b.createSource('testSource2', filterType);
    t.add_source(s);

    % test empty id filter
    assert(isempty(f.blocks{1}.tags{1}.filter_sources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.tags{1}.filter_sources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.createSource(mainName, 'nixSource');
    t.add_source(mainSource);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.tags{1}.filter_sources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createSource(mainName, 'nixSource');
    t.add_source(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = main.createSource(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.tags{1}.filter_sources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.tags{1}.filter_sources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter references
function [] = testFilterReference( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2 3]);
    d = b.createDataArray(filterName, 'nixDataArray', nix.DataType.Double, [1 2]);
    t.addReference(d);
    filterID = d.id;
	d = b.createDataArray('testDataArray1', filterType, nix.DataType.Double, [1 2]);
    t.addReference(d);
    filterIDs = {filterID, d.id};
    d = b.createDataArray('testDataArray2', filterType, nix.DataType.Double, [1 2]);
    t.addReference(d);

    % test empty id filter
    assert(isempty(f.blocks{1}.tags{1}.filterReferences(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.tags{1}.filterReferences(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.addReference(main);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    main.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.tags{1}.filterReferences(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Bool, [2 2]);
    t.addReference(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    main.add_source(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.tags{1}.filterReferences(nix.Filter.source, 'Do not exist')));

    % filter works only for ID, not for name
    filtered = f.blocks{1}.tags{1}.filterReferences(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter features
function [] = testFilterFeature( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    t = b.createTag('testTag', 'nixTag', [1 2 3]);
    d = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    feat = t.addFeature(d, nix.LinkType.Tagged);
    filterID = feat.id;
	d = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [1 2]);
    feat = t.addFeature(d, nix.LinkType.Tagged);
    filterIDs = {filterID, feat.id};

    % test empty id filter
    assert(isempty(f.blocks{1}.tags{1}.filterFeatures(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.tags{1}.filterFeatures(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 2);

    % test nix.Filter.id
    filtered = f.blocks{1}.tags{1}.filterFeatures(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.tags{1}.filterFeatures(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));

    % test fail on nix.Filter.name
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.tags{1}.filterFeatures(nix.Filter.name, 'someName');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.type
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.tags{1}.filterFeatures(nix.Filter.type, 'someType');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.metadata
    err = 'unknown or unsupported filter';
    try
        f.blocks{1}.tags{1}.filterFeatures(nix.Filter.metadata, 'someMetadata');
    catch ME
        assert(strcmp(ME.message, err));
    end

    % test fail on nix.Filter.source
    try
        f.blocks{1}.tags{1}.filterFeatures(nix.Filter.source, 'someSource');
    catch ME
        assert(strcmp(ME.message, err));
    end
end
