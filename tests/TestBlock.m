function funcs = TestBlock
%TESTFILE Tests for the nix.Block object
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_create_data_array;
    funcs{end+1} = @test_create_data_array_from_data;
    funcs{end+1} = @test_delete_data_array;
    funcs{end+1} = @test_create_tag;
    funcs{end+1} = @test_delete_tag;
    funcs{end+1} = @test_create_multi_tag;
    funcs{end+1} = @test_delete_multi_tag;
    funcs{end+1} = @test_create_source;
    funcs{end+1} = @test_delete_source;
    funcs{end+1} = @test_list_arrays;
    funcs{end+1} = @test_list_sources;
    funcs{end+1} = @test_list_tags;
    funcs{end+1} = @test_list_multitags;
    funcs{end+1} = @test_open_array;
    funcs{end+1} = @test_open_tag;
    funcs{end+1} = @test_open_multitag;
    funcs{end+1} = @test_open_source;
    funcs{end+1} = @test_has_multitag;
    funcs{end+1} = @test_has_tag;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_create_group;
    funcs{end+1} = @test_has_group;
    funcs{end+1} = @test_get_group;
    funcs{end+1} = @test_delete_group;
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'test nixBlock');

    assert(~isempty(b.id));
    assert(strcmp(b.name, 'tagtest'));
    assert(strcmp(b.type, 'test nixBlock'));
    
    b.type = 'nixBlock';
    assert(strcmp(b.type, 'nixBlock'));
    
    assert(isempty(b.definition));
    b.definition = 'block definition';
    assert(strcmp(b.definition, 'block definition'));

    b.definition = '';
    assert(isempty(b.definition));
end

function [] = test_create_data_array( varargin )
%% Test: Create Data Array
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    d1 = b.create_data_array('foo', 'bar', 'double', [2 3]);

    assert(strcmp(d1.name, 'foo'));
    assert(strcmp(d1.type, 'bar'));
    tmp = d1.read_all();
    assert(all(tmp(:) == 0));
    
    assert(~isempty(b.dataArrays));
end

function [] = test_create_data_array_from_data( varargin )
%% Test: Create Data Array from data
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixblock');
    
    assert(isempty(b.dataArrays));
    
    data = [1, 2, 3; 4, 5, 6];
    d1 = b.create_data_array_from_data('foo', 'bar', data);

    assert(strcmp(d1.name, 'foo'));
    assert(strcmp(d1.type, 'bar'));
    
    tmp = d1.read_all();
    assert(strcmp(class(tmp), class(data)));
    assert(isequal(size(tmp), size(data)));
    assert(isequal(tmp, data));
    
    assert(~isempty(b.dataArrays));
end

%% Test: delete dataArray by entity and id
function [] = test_delete_data_array( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');
    tmp = b.create_data_array('dataArrayTest1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_data_array('dataArrayTest2', 'nixDataArray', nix.DataType.Double, [3 4]);
    
    assert(size(b.dataArrays, 1) == 2);
    assert(b.delete_data_array(b.dataArrays{2}.id));
    assert(size(b.dataArrays, 1) == 1);
    assert(b.delete_data_array(b.dataArrays{1}));
    assert(isempty(b.dataArrays));
    assert(~b.delete_data_array('I do not exist'));
end

function [] = test_create_tag( varargin )
%% Test: Create Tag
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixblock');
    
    assert(isempty(b.tags));

    position = [1.0 1.2 1.3 15.9];
    t1 = b.create_tag('foo', 'bar', position);
    assert(strcmp(t1.name, 'foo'));
    assert(strcmp(t1.type, 'bar'));
    assert(isequal(t1.position, position));
    
    assert(~isempty(b.tags));
end

%% Test: delete tag by entity and id
function [] = test_delete_tag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tmp = b.create_tag('tagtest1', 'nixTag', position);
    tmp = b.create_tag('tagtest2', 'nixTag', position);
    
    assert(size(b.tags, 1) == 2);
    assert(b.delete_tag(b.tags{2}.id));
    assert(size(b.tags, 1) == 1);
    assert(b.delete_tag(b.tags{1}));
    assert(isempty(b.tags));

    assert(~b.delete_tag('I do not exist'));
end

function [] = test_create_multi_tag( varargin )
%% Test: Create multitag by data_array entity and data_array id
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_data_array('mTagTestDataArray2', 'nixDataArray', 'double', [3 4]);
    assert(isempty(b.multiTags));

    %-- create by data_array entity
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    assert(~isempty(b.multiTags));
    assert(strcmp(b.multiTags{1}.name, 'mTagTest1'));

    %-- create by data_array id
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag2', b.dataArrays{2}.id);
    assert(size(b.multiTags, 1) == 2);
    assert(strcmp(b.multiTags{2}.type, 'nixMultiTag2'));
end

%% Test: delete multitag by entity and id
function [] = test_delete_multi_tag( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag1', b.dataArrays{1});
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag2', b.dataArrays{1});

    assert(size(b.multiTags, 1) == 2);
    assert(b.delete_multi_tag(b.multiTags{2}.id));
    assert(size(b.multiTags, 1) == 1);
    assert(b.delete_multi_tag(b.multiTags{1}));
    assert(isempty(b.multiTags));
    assert(size(b.dataArrays, 1) == 1);

    assert(~b.delete_multi_tag('I do not exist'));
end

%% Test: create source
function [] = test_create_source ( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixblock');
    assert(isempty(getBlock.sources));

    createSource = getBlock.create_source('sourcetest','nixsource');
    assert(~isempty(getBlock.sources));
    assert(strcmp(createSource.name, 'sourcetest'));
    assert(strcmp(createSource.type, 'nixsource'));
end

%% Test: delete source by entity and id
function [] = test_delete_source( varargin )
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixblock');
    tmp = getBlock.create_source('sourcetest1','nixsource');
    tmp = getBlock.create_source('sourcetest2','nixsource');
    tmp = getBlock.create_source('sourcetest3','nixsource');

    assert(getBlock.delete_source('sourcetest1'));
    assert(getBlock.delete_source(getBlock.sources{1}.id));
    assert(getBlock.delete_source(getBlock.sources{1}));
    assert(isempty(getBlock.sources));
    
    assert(~getBlock.delete_source('I do not exist'));
end

function [] = test_list_arrays( varargin )
%% Test: fetch data arrays
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');

    assert(isempty(b.dataArrays));
    tmp = b.create_data_array('arrayTest1', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_data_array('arrayTest2', 'nixDataArray', 'double', [3 4]);
    assert(size(b.dataArrays, 1) == 2);

end

function [] = test_list_sources( varargin )
%% Test: fetch sources
    test_file = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    getBlock = test_file.createBlock('sourcetest', 'nixBlock');

    assert(isempty(getBlock.sources));
    tmp = getBlock.create_source('sourcetest1','nixSource');
    tmp = getBlock.create_source('sourcetest2','nixSource');
    assert(size(getBlock.sources, 1) == 2);
end

function [] = test_list_tags( varargin )
%% Test: fetch tags
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];

    assert(isempty(b.tags));
    tmp = b.create_tag('tagtest1', 'nixTag', position);
    tmp = b.create_tag('tagtest2', 'nixTag', position);
    assert(size(b.tags, 1) == 2);
end

function [] = test_list_multitags( varargin )
%% Test: fetch multitags
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', 'double', [1 2]);

    assert(isempty(b.multiTags));
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag', b.dataArrays{1});
    tmp = b.create_multi_tag('mTagTest2', 'nixMultiTag', b.dataArrays{1});
    assert(size(b.multiTags, 1) == 2);
end

function [] = test_open_array( varargin )
%% Test: Open data array by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('arraytest', 'nixBlock');
    daName = 'arrayTest1';
    
    assert(isempty(b.dataArrays));
    tmp = b.create_data_array(daName, 'nixDataArray', 'double', [1 2]);

    getDataArrayByID = b.data_array(b.dataArrays{1,1}.id);
    assert(~isempty(getDataArrayByID));

    getDataArrayByName = b.data_array(daName);
    assert(~isempty(getDataArrayByName));
    
    %-- test open non existing dataarray
    getDataArray = b.data_array('I do not exist');
    assert(isempty(getDataArray));
end

function [] = test_open_tag( varargin )
%% Test: Open tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    position = [1.0 1.2 1.3 15.9];
    tagName = 'tagtest1';
    tmp = b.create_tag(tagName, 'nixTag', position);

    getTagByID = b.open_tag(b.tags{1,1}.id);
    assert(~isempty(getTagByID));

    getTagByName = b.open_tag(tagName);
    assert(~isempty(getTagByName));
    
    %-- test open non existing tag
    getTag = b.open_tag('I do not exist');
    assert(isempty(getTag));
end

function [] = test_open_multitag( varargin )
%% Test: Open multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', 'double', [1 2]);
    mTagName = 'mTagTest1';
    tmp = b.create_multi_tag(mTagName, 'nixMultiTag', b.dataArrays{1});

    getMultiTagByID = b.open_multi_tag(b.multiTags{1,1}.id);
    assert(~isempty(getMultiTagByID));

    getMultiTagByName = b.open_multi_tag(mTagName);
    assert(~isempty(getMultiTagByName));
    
    %-- test open non existing multitag
    getMultiTag = b.open_multi_tag('I do not exist');
    assert(isempty(getMultiTag));
end

function [] = test_open_source( varargin )
%% Test: Open source by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourcetest', 'nixBlock');
    sName = 'sourcetest1';
    tmp = b.create_source(sName, 'nixSource');
    
    getSourceByID = b.open_source(b.sources{1,1}.id);
    assert(~isempty(getSourceByID));

    getSourceByName = b.open_source(sName);
    assert(~isempty(getSourceByName));
    
    %-- test open non existing source
    getSource = b.open_source('I do not exist');
    assert(isempty(getSource));
end

function [] = test_has_multitag( varargin )
%% Test: Block has multi tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('mTagTestBlock', 'nixBlock');
    tmp = b.create_data_array('mTagTestDataArray', 'nixDataArray', 'double', [1 2]);
    tmp = b.create_multi_tag('mTagTest1', 'nixMultiTag', b.dataArrays{1});

    assert(b.has_multi_tag(b.multiTags{1,1}.id));
    assert(b.has_multi_tag(b.multiTags{1,1}.name));
    
    assert(~b.has_multi_tag('I do not exist'));
end

function [] = test_has_tag( varargin )
%% Test: Block has tag by ID or name
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('tagtest', 'nixBlock');
    tmp = b.create_tag('tagtest1', 'nixTag', [1.0 1.2 1.3 15.9]);

    assert(b.has_tag(b.tags{1,1}.id));
    assert(b.has_tag(b.tags{1,1}.name));
    
    assert(~b.has_tag('I do not exist'));
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection1', 'nixSection');
    tmp = f.createSection('testSection2', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    
    assert(isempty(b.open_metadata));
    b.set_metadata(f.sections{1});
    assert(strcmp(b.open_metadata.name, 'testSection1'));
    b.set_metadata(f.sections{2});
    assert(strcmp(b.open_metadata.name, 'testSection2'));
    b.set_metadata('');
    assert(isempty(b.open_metadata));
end

function [] = test_open_metadata( varargin )
%% Test: Open metadata
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    b.set_metadata(f.sections{1});

    assert(strcmp(b.open_metadata.name, 'testSection'));
end

%% Test: Create nix.Group
function [] = test_create_group( varargin )
    fileName = 'testRW.h5';
    groupName = 'testGroup';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');

    assert(isempty(b.groups));

    g = b.create_group(groupName, groupType);
    assert(strcmp(g.name, groupName));
    assert(strcmp(g.type, groupType));
    assert(~isempty(b.groups));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(~isempty(f.blocks{1}.groups));
    assert(strcmp(f.blocks{1}.groups{1}.name, groupName));
end

%% Test: nix.Block has nix.Group by name or id
function [] = test_has_group( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');

    assert(~b.has_group('I do not exist'));
    
    g = b.create_group(groupName, 'nixGroup');
    assert(b.has_group(b.groups{1}.id));
    assert(b.has_group(groupName));

    b.delete_group(b.groups{1});
    assert(~b.has_group(g.id));
end

%% Test: Get nix.Group by name or id
function [] = test_get_group( varargin )
    groupName = 'testGroup';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');
    g = b.create_group(groupName, 'nixGroup');
    gID = g.id;

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.get_group(gID).name, groupName));
    assert(strcmp(f.blocks{1}.get_group(groupName).name, groupName));
end

%% Test: Delete nix.Group by entity and id
function [] = test_delete_group( varargin )
    fileName = 'testRW.h5';
    groupType = 'nixGroup';

    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('grouptest', 'nixBlock');
    g1 = b.create_group('testGroup1', groupType);
    g2 = b.create_group('testGroup2', groupType);

    assert(size(b.groups, 1) == 2);
    assert(b.delete_group(b.groups{2}.id));
    assert(size(b.groups, 1) == 1);
    assert(b.delete_group(b.groups{1}));
    assert(isempty(b.groups));

    assert(~b.delete_group('I do not exist'));

    clear g b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(isempty(f.blocks{1}.groups));
end
