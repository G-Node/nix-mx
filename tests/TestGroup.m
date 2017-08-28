% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestGroup
%% TESTGROUP Tests for the nix.Group object

    funcs = {};
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testAddDataArray;
    funcs{end+1} = @testAddDataArrays;
    funcs{end+1} = @testHasDataArray;
    funcs{end+1} = @testGetDataArray;
    funcs{end+1} = @testRemoveDataArray;
    funcs{end+1} = @testUpdateLinkedDataArray;
    funcs{end+1} = @testDataArrayCount;
    funcs{end+1} = @testAddTag;
    funcs{end+1} = @testAddTags;
    funcs{end+1} = @testHasTag;
    funcs{end+1} = @testGetTag;
    funcs{end+1} = @testRemoveTag;
    funcs{end+1} = @testTagCount;
    funcs{end+1} = @testAddMultiTag;
    funcs{end+1} = @testAddMultiTags;
    funcs{end+1} = @testHasMultiTag;
    funcs{end+1} = @testGetMultiTag;
    funcs{end+1} = @testRemoveMultiTag;
    funcs{end+1} = @testMultiTagCount;
    funcs{end+1} = @testAddSource;
    funcs{end+1} = @testAddSources;
    funcs{end+1} = @testRemoveSource;
    funcs{end+1} = @testHasSource;
    funcs{end+1} = @testFetchSources;
    funcs{end+1} = @testOpenSource;
    funcs{end+1} = @testSourceCount;
    funcs{end+1} = @testSetMetadata;
    funcs{end+1} = @testOpenMetadata;
    funcs{end+1} = @testOpenDataArrayIdx;
    funcs{end+1} = @testOpenTagIdx;
    funcs{end+1} = @testOpenMultiTagIdx;
    funcs{end+1} = @testOpenSourceIdx;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSource;
    funcs{end+1} = @testFilterTag;
    funcs{end+1} = @testFilterMultiTag;
    funcs{end+1} = @testFilterDataArray;
end

%% Test: Access nix.Group attributes
function [] = testAttributes( varargin )
    fileName = 'testRW.h5';
    groupName = 'testGroup';
    groupType = 'nixGroup';
    typeOW = 'test nixGroup';
    defOW = 'group definition';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    b.createGroup(groupName, groupType);

    testGroup = b.groups{1};
    assert(~isempty(testGroup.id));
    assert(~isempty(b.groups{1}.id));
    assert(strcmp(testGroup.name, groupName));
    assert(strcmp(testGroup.type, groupType));

    testGroup.type = typeOW;
    assert(strcmp(testGroup.type, typeOW));
    assert(strcmp(b.groups{1}.type, typeOW));

    assert(isempty(testGroup.definition));
    testGroup.definition = defOW;
    assert(strcmp(testGroup.definition, defOW));
    assert(strcmp(b.groups{1}.definition, defOW));

    clear testGroup g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    b = f.blocks{1};

    assert(strcmp(b.groups{1}.name, groupName));
    assert(strcmp(b.groups{1}.type, typeOW));
    assert(strcmp(b.groups{1}.definition, defOW));
end

%% Test: Add nix.DataArray to nix.Group
function [] = testAddDataArray( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.createDataArray(daName, daType, nix.DataType.Double, [2 3]);
    g = b.createGroup('testGroup', 'nixGroup');

    assert(isempty(g.dataArrays));
    assert(isempty(f.blocks{1}.groups{1}.dataArrays));
    g.addDataArray(da);
    assert(size(g.dataArrays, 1) == 1);
    assert(strcmp(f.blocks{1}.groups{1}.dataArrays{1}.name, daName));

    clear g da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.dataArrays{1}.name, daName));
end

%% Test: Add dataArrays by entity cell array
function [] = testAddDataArrays ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    tmp = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [2 3]);
    tmp = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [2 3]);
    tmp = b.createDataArray('testDataArray3', 'nixDataArray', nix.DataType.Double, [2 3]);

    assert(isempty(g.dataArrays));

    try
        g.addDataArrays('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(g.dataArrays));

    try
        g.addDataArrays({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.DataArray')));
    end;
    assert(isempty(g.dataArrays));

    g.addDataArrays(b.dataArrays());
    assert(size(g.dataArrays, 1) == 3);

    clear g tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.dataArrays, 1) == 3);
end

%% Test: has nix.DataArray by id or name
function [] = testHasDataArray( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.createDataArray(daName, 'nixDataArray', nix.DataType.Double, [2 3]);
    g = b.createGroup('testGroup', 'nixGroup');
    g.addDataArray(da);

    assert(g.hasDataArray(b.dataArrays{1}.id));
    assert(g.hasDataArray(daName));
    assert(~g.hasDataArray('I do not exist'));
end

%% Test: Get nix.DataArray by id or name
function [] = testGetDataArray( varargin )
    fileName = 'testRW.h5';
    daName = 'testDataArray';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.createDataArray(daName, daType, nix.DataType.Double, [2 3]);
    daID = da.id;
    g = b.createGroup('testGroup', 'nixGroup');
    g.addDataArray(da);

    testClass = 'nix.DataArray';
    daTestID = g.getDataArray(daID);
    assert(strcmp(class(daTestID), testClass));
    assert(strcmp(daTestID.name, daName));

    daTestName = g.getDataArray(daName);
    assert(strcmp(class(daTestName), testClass));
    assert(strcmp(daTestName.id, daID));
end

%% Test: Remove nix.DataArray from nix.Group by id and entity
function [] = testRemoveDataArray( varargin )
    fileName = 'testRW.h5';
    daName1 = 'testDataArray1';
    daName2 = 'testDataArray2';
    daName3 = 'testDataArray3';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da1 = b.createDataArray(daName1, daType, nix.DataType.Double, 1);
    da2 = b.createDataArray(daName2, daType, nix.DataType.Double, [2 3]);
    da3 = b.createDataArray(daName3, daType, nix.DataType.Double, [4 5 6]);
    g = b.createGroup('testGroup', 'nixGroup');
    g.addDataArray(da1);
    g.addDataArray(da2);
    g.addDataArray(da3);

    assert(size(b.dataArrays, 1) == 3);
    g.removeDataArray(da3);
    assert(size(b.dataArrays, 1) == 3);
    assert(isempty(g.getDataArray(da3.name)));

    g.removeDataArray(da2.id);
    assert(size(b.dataArrays, 1) == 3);
    assert(isempty(g.getDataArray(da2.name)));
    assert(~isempty(g.getDataArray(da1.name)));

    clear da1 da2 da3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays, 1) == 3);
    assert(isempty(f.blocks{1}.groups{1}.getDataArray(daName3)));
    assert(isempty(f.blocks{1}.groups{1}.getDataArray(daName2)));
    assert(~isempty(f.blocks{1}.groups{1}.getDataArray(daName1)));
end

%% Test: Updates of a linked nix.DataArray between nix.Block and nix.Group
function [] = testUpdateLinkedDataArray( varargin )
    fileName = 'testRW.h5';
    daName1 = 'testDataArray1';
    daName2 = 'testDataArray2';
    daName3 = 'testDataArray3';
    daType = 'nixDataArray';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da1 = b.createDataArray(daName1, daType, nix.DataType.Double, [1]);
    da2 = b.createDataArray(daName2, daType, nix.DataType.Double, [2 3]);
    da3 = b.createDataArray(daName3, daType, nix.DataType.Double, [4 5 6]);
    g = b.createGroup('testGroup', 'nixGroup');
    g.addDataArray(da1);
    g.addDataArray(da2);
    g.addDataArray(da3);

    %-- test remove linked DataArray from Block
    assert(size(b.dataArrays, 1) == 3);
    b.deleteDataArray(da1);
    assert(size(b.dataArrays, 1) == 2)
    assert(isempty(g.getDataArray(daName1)));
    assert(~isempty(g.getDataArray(daName2)));

    %-- test udpate linked DataArray
    upDADefFromGroup = 'def 2';
    g.getDataArray(daName2).definition = upDADefFromGroup;
    assert(strcmp(b.openDataArray(daName2).definition, upDADefFromGroup));

    upDADefFromBlock = 'def 3';
    b.openDataArray(daName3).definition = upDADefFromBlock;
    assert(strcmp(g.getDataArray(daName3).definition, upDADefFromBlock));

    clear da1 da2 da3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.openDataArray(daName2).definition, upDADefFromGroup));
    assert(strcmp(f.blocks{1}.openDataArray(daName3).definition, upDADefFromBlock));
end

%% Test: DataArray count
function [] = testDataArrayCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');

    assert(g.dataArrayCount() == 0);
    g.addDataArray(b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]));
    assert(g.dataArrayCount() == 1);
    g.addDataArray(b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]));

    clear g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.dataArrayCount() == 2);
end

%% Test: Add nix.Tag by entity or id
function [] = testAddTag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'testTag1';
    tagName2 = 'testTag2';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    t1 = b.createTag(tagName1, 'nixTag', [1.0 1.2 1.3 15.9]);
    t2 = b.createTag(tagName2, 'nixTag', [1.0 1.2 1.3 15.9]);
    tID = t2.id;
    g = b.createGroup('testGroup', 'nixGroup');
    assert(isempty(g.tags));
    assert(isempty(f.blocks{1}.groups{1}.tags));
    g.addTag(t1);
    assert(strcmp(g.tags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.tags{1}.name, tagName1));
    g.addTag(tID);
    assert(strcmp(g.tags{2}.name, tagName2));
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 2);

    clear t1 t2 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.tags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.tags{2}.name, tagName2));
end

%% Test: Add tags by entity cell array
function [] = testAddTags ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    tmp = b.createTag('testTag1', 'nixTag', [1.0 1.2]);
    tmp = b.createTag('testTag2', 'nixTag', [1.0 1.2]);
    tmp = b.createTag('testTag3', 'nixTag', [1.0 1.2]);

    assert(isempty(g.tags));

    try
        g.addTags('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(g.tags));

    try
        g.addTags({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Tag')));
    end;
    assert(isempty(g.tags));

    g.addTags(b.tags());
    assert(size(g.tags, 1) == 3);

    clear g tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 3);
end

%% Test: has nix.Tag by id or name
function [] = testHasTag( varargin )
    fileName = 'testRW.h5';
    tagName = 'testTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    t = b.createTag(tagName, 'nixTag', [1.0 1.2 1.3 15.9]);
    g.addTag(t);

    assert(g.hasTag(b.tags{1}.id));
    assert(g.hasTag(tagName));
    assert(~g.hasTag('I do not exist'));
end

%% Test: get nix.Tag by id or name
function [] = testGetTag( varargin )
    fileName = 'testRW.h5';
    tagName = 'testTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    t = b.createTag(tagName, 'nixTag', [1.0 1.2 1.3 15.9]);
    tID = t.id;

    assert(isempty(f.blocks{1}.groups{1}.getTag(tID)));
    g.addTag(t);
    assert(strcmp(f.blocks{1}.groups{1}.getTag(tID).name, tagName));

    clear t g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.getTag(tagName).name, tagName));
end

%% Test: Remove nix.Tag by entity or id
function [] = testRemoveTag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'testTag1';
    tagName2 = 'testTag2';
    tagName3 = 'testTag3';
    tagType = 'nixTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    t1 = b.createTag(tagName1, tagType, [1.0 1.2 1.3 15.9]);
    t2 = b.createTag(tagName2, tagType, [1.0 1.2 1.3 15.9]);
    t3 = b.createTag(tagName3, tagType, [1.0 1.2 1.3 15.9]);
    g.addTag(t1);
    g.addTag(t2);
    g.addTag(t3);

    assert(~g.removeTag('I do not exist'));

    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 3);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 3);
    assert(g.removeTag(t1.id));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 2);
    assert(g.removeTag(t2));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 1);
    assert(~g.removeTag(t2));
    assert(size(f.blocks{1}.tags, 1) == 3);
    assert(size(g.tags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.tags, 1) == 1);

    clear t1 t2 t3 g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.hasTag(tagName3));
end

%% Test: Tag count
function [] = testTagCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    
    assert(g.tagCount() == 0);
    g.addTag(b.createTag('testTag1', 'nixTag', [1 2 3]));
    assert(g.tagCount() == 1);
    g.addTag(b.createTag('testTag2', 'nixTag', [1 2 3]));

    clear g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.tagCount() == 2);
end

%% Test: Add nix.MultiTag by entity and id
function [] = testAddMultiTag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    tmp = b.createDataArray(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray(...
        'mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createMultiTag(tagName1, tagType, b.dataArrays{1});
    tmp = b.createMultiTag(tagName2, tagType, b.dataArrays{2});
    g = b.createGroup('testGroup', 'nixGroup');

    assert(isempty(g.multiTags));
    assert(isempty(f.blocks{1}.groups{1}.multiTags));
    g.addMultiTag(b.multiTags{1});
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);

    g.addMultiTag(b.multiTags{2}.id);
    assert(size(g.multiTags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 2);

    clear tmp g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.multiTags{1}.name, tagName1));
    assert(strcmp(f.blocks{1}.groups{1}.multiTags{2}.name, tagName2));
end

%% Test: Add multiTags by entity cell array
function [] = testAddMultiTags ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    tmp = b.createDataArray(...
        'testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createMultiTag('testMultiTag1', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createMultiTag('testMultiTag2', 'nixMultiTag', b.dataArrays{1});
    tmp = b.createMultiTag('testMultiTag3', 'nixMultiTag', b.dataArrays{1});

    assert(isempty(g.multiTags));

    try
        g.addMultiTags('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(g.multiTags));

    try
        g.addMultiTags({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.MultiTag')));
    end;
    assert(isempty(g.multiTags));

    g.addMultiTags(b.multiTags());
    assert(size(g.multiTags, 1) == 3);

    clear g tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 3);
end

%% Test: has nix.MultiTag by id or name
function [] = testHasMultiTag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    tmp = b.createDataArray(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createDataArray(...
        'mTagTestDataArray2', 'nixDataArray', nix.DataType.Double, [3 4]);
    tmp = b.createMultiTag(tagName1, tagType, b.dataArrays{1});
    tmp = b.createMultiTag(tagName2, tagType, b.dataArrays{2});
    g = b.createGroup('testGroup', 'nixGroup');

    g.addMultiTag(b.multiTags{1});
    assert(g.hasMultiTag(b.multiTags{1}.id));
    g.addMultiTag(b.multiTags{2});
    assert(g.hasMultiTag(tagName2));
    assert(~g.hasMultiTag('I do not exist'));
end

%% Test: get nix.MultiTag by id or name
function [] = testGetMultiTag( varargin )
    fileName = 'testRW.h5';
    tagName = 'mTagTest';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.createDataArray(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t = b.createMultiTag(tagName, tagType, b.dataArrays{1});
    g = b.createGroup('testGroup', 'nixGroup');

    g.addMultiTag(b.multiTags{1});
    assert(strcmp(f.blocks{1}.groups{1}.getMultiTag(t.id).name, tagName));

    clear t da g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.groups{1}.getMultiTag(tagName).name, tagName));

    assert(isempty(f.blocks{1}.groups{1}.getMultiTag('I do not exist')));
end

%% Test: Remove nix.MultiTag by entity or id
function [] = testRemoveMultiTag( varargin )
    fileName = 'testRW.h5';
    tagName1 = 'mTagTest1';
    tagName2 = 'mTagTest2';
    tagName3 = 'mTagTest3';
    tagType = 'nixMultiTag';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    da = b.createDataArray(...
        'mTagTestDataArray1', 'nixDataArray', nix.DataType.Double, [1 2]);
    t1 = b.createMultiTag(tagName1, tagType, b.dataArrays{1});
    t2 = b.createMultiTag(tagName2, tagType, b.dataArrays{1});
    t3 = b.createMultiTag(tagName3, tagType, b.dataArrays{1});
    g = b.createGroup('testGroup', 'nixGroup');
    g.addMultiTag(t1);
    g.addMultiTag(t2);
    g.addMultiTag(t3);
    assert(g.hasMultiTag(tagName1));
    assert(g.hasMultiTag(tagName2));
    assert(g.hasMultiTag(tagName3));

    assert(~g.removeMultiTag('I do not exist'));

    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 3);
    assert(g.removeMultiTag(t1.id));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 2);
    assert(~g.hasMultiTag(tagName1));

    assert(g.removeMultiTag(t2));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);
    assert(~g.hasMultiTag(tagName2));

    assert(~g.removeMultiTag(t2));
    assert(size(f.blocks{1}.multiTags, 1) == 3);
    assert(size(g.multiTags, 1) == 1);
    assert(size(f.blocks{1}.groups{1}.multiTags, 1) == 1);

    clear t1 t2 t3 da g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.hasMultiTag(tagName3));
end

%% Test: MultiTag count
function [] = testMultiTagCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(g.multiTagCount() == 0);
    g.addMultiTag(b.createMultiTag('testMultiTag1', 'nixMultiTag', da));
    assert(g.multiTagCount() == 1);
    g.addMultiTag(b.createMultiTag('testMultiTag2', 'nixMultiTag', da));

    clear da g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.multiTagCount() == 2);
end

%% Test: Add sources by entity and id
function [] = testAddSource ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    g = b.createGroup('sourceTest', 'nixGroup');
    
    assert(isempty(g.sources));
    assert(isempty(f.blocks{1}.groups{1}.sources));
    g.addSource(s.sources{1}.id);
    g.addSource(s.sources{2});
    assert(size(g.sources, 1) == 2);
    assert(size(f.blocks{1}.groups{1}.sources, 1) == 2);
    
    clear tmp g s b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.sources, 1) == 2);
end

%% Test: Add sources by entity cell array
function [] = testAddSources ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('sourceTest', 'nixGroup');
    tmp = b.createSource('testSource1', 'nixSource');
    tmp = b.createSource('testSource2', 'nixSource');
    tmp = b.createSource('testSource3', 'nixSource');

    assert(isempty(g.sources));

    try
        g.addSources('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(g.sources));

    try
        g.addSources({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Source')));
    end;
    assert(isempty(g.sources));

    g.addSources(b.sources());
    assert(size(g.sources, 1) == 3);

    clear g tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.groups{1}.sources, 1) == 3);
end

%% Test: Remove sources by entity and id
function [] = testRemoveSource ( varargin )
    testFile = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = testFile.createBlock('test', 'nixBlock');
    s = b.createSource('test', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    g = b.createGroup('sourceTest', 'nixGroup');
    g.addSource(s.sources{1}.id);
    g.addSource(s.sources{2});

    assert(size(g.sources,1) == 2);
    g.removeSource(s.sources{2});
    assert(size(g.sources,1) == 1);

    g.removeSource(s.sources{1}.id);
    assert(isempty(g.sources));

    assert(g.removeSource('I do not exist'));
    assert(size(s.sources, 1) == 2);
end

%% Test: nix.Group has nix.Source by ID, name or entity
function [] = testHasSource( varargin )
    fileName = 'testRW.h5';
    sName = 'sourcetest1';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    s = b.createSource(sName, 'nixSource');
    g.addSource(b.sources{1}.id)

    assert(~g.hasSource('I do not exist'));
    assert(g.hasSource(s.id));
    assert(g.hasSource(s));
    assert(~g.hasSource(sName));

    clear s g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.hasSource(sName));
    assert(~f.blocks{1}.groups{1}.hasSource(sName));
end

%% Test: fetch sources
function [] = testFetchSources( varargin )
    testFile = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = testFile.createBlock('test', 'nixBlock');
    s = b.createSource('test','nixSource');
    tmp = s.createSource('nestedsource1', 'nixSource');
    tmp = s.createSource('nestedsource2', 'nixSource');
    tmp = s.createSource('nestedsource3', 'nixSource');
    g = b.createGroup('sourceTest', 'nixGroup');

    g.addSource(s.sources{1});
    g.addSource(s.sources{2});
    g.addSource(s.sources{3});
    assert(size(g.sources, 1) == 3);
end

%% Test: Open source by ID or name
function [] = testOpenSource( varargin )
    testFile = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = testFile.createBlock('test', 'nixBlock');
    s = b.createSource('test', 'nixSource');
    sourceName = 'nestedSource';
    nSource = s.createSource(sourceName, 'nixSource');

    g = b.createGroup('sourceTest', 'nixGroup');
    g.addSource(s.sources{1});

    % -- test get source by ID
    assert(~isempty(g.openSource(nSource.id)));

    % -- test get source by name
    assert(~isempty(g.openSource(sourceName)));

    %-- test open non existing source
    getNonSource = g.openSource('I do not exist');
    assert(isempty(getNonSource));
end

%% Test: Source count
function [] = testSourceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    
    assert(g.sourceCount() == 0);
    g.addSource(b.createSource('testSource1', 'nixSource'));
    assert(g.sourceCount() == 1);
    g.addSource(b.createSource('testSource2', 'nixSource'));
    
    clear g b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.groups{1}.sourceCount() == 2);
end


%% Test: Set metadata, set metadata none
function [] = testSetMetadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testGroupSection1';
    secName2 = 'testGroupSection2';

    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection(secName1, 'nixSection');
    tmp = f.createSection(secName2, 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    assert(isempty(g.open_metadata));
    assert(isempty(f.blocks{1}.groups{1}.open_metadata))
    
    g.set_metadata(f.sections{1});
    assert(strcmp(g.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName1));

    g.set_metadata(f.sections{2});
    assert(strcmp(g.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName2));
    g.set_metadata('');
    assert(isempty(g.open_metadata));
    assert(isempty(f.blocks{1}.groups{1}.open_metadata));

    g.set_metadata(f.sections{2});
    clear tmp g b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
	assert(strcmp(f.blocks{1}.groups{1}.open_metadata.name, secName2));
end

function [] = testOpenMetadata( varargin )
%% Test: Open metadata
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    g.set_metadata(f.sections{1});

    assert(strcmp(g.open_metadata.name, 'testSection'));
end

function [] = testOpenDataArrayIdx( varargin )
%% Test Open DataArray by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    d1 = b.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Double, [3 2]);
    d2 = b.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Double, [6 2]);
    d3 = b.createDataArray('testDataArray3', 'nixDataArray', nix.DataType.Double, [9 2]);
    g.addDataArray(d1);
    g.addDataArray(d2);
    g.addDataArray(d3);
    
    assert(strcmp(f.blocks{1}.groups{1}.openDataArrayIdx(1).name, d1.name));
    assert(strcmp(f.blocks{1}.groups{1}.openDataArrayIdx(2).name, d2.name));
    assert(strcmp(f.blocks{1}.groups{1}.openDataArrayIdx(3).name, d3.name));
end

function [] = testOpenTagIdx( varargin )
%% Test Open Tag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    t1 = b.createTag('testTag1', 'nixTag', [1 2]);
    t2 = b.createTag('testTag2', 'nixTag', [1 2]);
    t3 = b.createTag('testTag3', 'nixTag', [1 2]);
    g.addTag(t1);
    g.addTag(t2);
    g.addTag(t3);

    assert(strcmp(f.blocks{1}.groups{1}.openTagIdx(1).name, t1.name));
    assert(strcmp(f.blocks{1}.groups{1}.openTagIdx(2).name, t2.name));
    assert(strcmp(f.blocks{1}.groups{1}.openTagIdx(3).name, t3.name));
end

function [] = testOpenMultiTagIdx( varargin )
%% Test Open MultiTag by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 3]);
    t1 = b.createMultiTag('testMultiTag1', 'nixMultiTag', d);
    t2 = b.createMultiTag('testMultiTag2', 'nixMultiTag', d);
    t3 = b.createMultiTag('testMultiTag3', 'nixMultiTag', d);
    g.addMultiTag(t1);
    g.addMultiTag(t2);
    g.addMultiTag(t3);
    
    assert(strcmp(f.blocks{1}.groups{1}.openMultiTagIdx(1).name, t1.name));
    assert(strcmp(f.blocks{1}.groups{1}.openMultiTagIdx(2).name, t2.name));
    assert(strcmp(f.blocks{1}.groups{1}.openMultiTagIdx(3).name, t3.name));
end

function [] = testOpenSourceIdx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    s1 = b.createSource('testSource1', 'nixSource');
    s2 = b.createSource('testSource2', 'nixSource');
    s3 = b.createSource('testSource3', 'nixSource');
    g.addSource(s1);
    g.addSource(s2);
    g.addSource(s3);

    assert(strcmp(f.blocks{1}.groups{1}.openSourceIdx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.groups{1}.openSourceIdx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.groups{1}.openSourceIdx(3).name, s3.name));
end

function [] = testCompare( varargin )
%% Test: Compare group entities
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    g1 = b1.createGroup('testGroup1', 'nixGroup');
    g2 = b1.createGroup('testGroup2', 'nixGroup');
    g3 = b2.createGroup('testGroup1', 'nixGroup');

    assert(g1.compare(g2) < 0);
    assert(g1.compare(g1) == 0);
    assert(g2.compare(g1) > 0);
    assert(g1.compare(g3) ~= 0);
end

%% Test: filter sources
function [] = testFilterSource( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    s = b.createSource(filterName, 'nixSource');
    g.addSource(s);
    filterID = s.id;
	s = b.createSource('testSource1', filterType);
    g.addSource(s);
    filterIDs = {filterID, s.id};
    s = b.createSource('testSource2', filterType);
    g.addSource(s);
    
    % test empty id filter
    assert(isempty(f.blocks{1}.groups{1}.filterSources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.groups{1}.filterSources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.createSource(mainName, 'nixSource');
    g.addSource(mainSource);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterSources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    mainSource = b.createSource(mainName, 'nixSource');
    g.addSource(mainSource);
    mainID = mainSource.id;
    subName = 'testSubSource1';
    s = mainSource.createSource(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterSources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.groups{1}.filterSources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter tags
function [] = testFilterTag( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    t = b.createTag(filterName, 'nixTag', [1 2 3]);
    g.addTag(t);
    filterID = t.id;
	t = b.createTag('testTag1', filterType, [1 2 3]);
    g.addTag(t);
    filterIDs = {filterID, t.id};
    t = b.createTag('testTag2', filterType, [1 2 3]);
    g.addTag(t);

    % test empty id filter
    assert(isempty(f.blocks{1}.groups{1}.filterTags(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.groups{1}.filterTags(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    main = b.createTag(mainName, 'nixTag', [1 2 3]);
    g.addTag(main);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    main.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterTags(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createTag(mainName, 'nixTag', [1 2 3]);
    g.addTag(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    main.addSource(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterTags(nix.Filter.source, 'Do not exist')));

    % filter works only for ID, not for name
    filtered = f.blocks{1}.groups{1}.filterTags(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter multi tags
function [] = testFilterMultiTag( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Bool, [2 2]);
    g = b.createGroup('testGroup', 'nixGroup');
    t = b.createMultiTag(filterName, 'nixMultiTag', d);
    g.addMultiTag(t);
    filterID = t.id;
	t = b.createMultiTag('testMultiTag1', filterType, d);
    g.addMultiTag(t);
    filterIDs = {filterID, t.id};
    t = b.createMultiTag('testMultiTag2', filterType, d);
    g.addMultiTag(t);

    % test empty id filter
    assert(isempty(f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    main = b.createMultiTag(mainName, 'nixMultiTag', d);
    g.addMultiTag(main);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    main.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createMultiTag(mainName, 'nixMultiTag', d);
    g.addMultiTag(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    main.addSource(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.source, 'Do not exist')));

    % filter works only for ID, not for name
    filtered = f.blocks{1}.groups{1}.filterMultiTags(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end

%% Test: filter dataArray
function [] = testFilterDataArray( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    g = b.createGroup('testGroup', 'nixGroup');
    d = b.createDataArray(filterName, 'nixDataArray', nix.DataType.Bool, [2 2]);
    g.addDataArray(d);
    filterID = d.id;
	d = b.createDataArray('testDataArray1', filterType, nix.DataType.Bool, [2 2]);
    g.addDataArray(d);
    filterIDs = {filterID, d.id};
	d = b.createDataArray('testDataArray2', filterType, nix.DataType.Bool, [2 2]);
    g.addDataArray(d);

    % test empty id filter
    assert(isempty(f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.accept_all
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.accept_all, '');
    assert(size(filtered, 1) == 3);
    
    % test nix.Filter.id
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));

    % test nix.Filter.type
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Double, [3 2]);
    g.addDataArray(main);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    main.set_metadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createDataArray(mainName, 'nixDataArray', nix.DataType.Double, [3 2]);
    g.addDataArray(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = b.createSource(subName, 'nixSource');
    main.addSource(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.source, 'Do not exist')));

    % filter works only for ID, not for name
    filtered = f.blocks{1}.groups{1}.filterDataArrays(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end
