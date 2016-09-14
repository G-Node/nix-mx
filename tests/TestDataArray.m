% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestDataArray
%TESTDATAARRAY tests for DataArray
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_attrs;
    funcs{end+1} = @test_open_data;
    funcs{end+1} = @test_set_metadata;
    funcs{end+1} = @test_open_metadata;
    funcs{end+1} = @test_list_sources;
    funcs{end+1} = @test_write_data_double;
    funcs{end+1} = @test_write_data_logical;
    funcs{end+1} = @test_write_data_float;
    funcs{end+1} = @test_write_data_integer;
    funcs{end+1} = @test_add_source;
    funcs{end+1} = @test_remove_source;
    funcs{end+1} = @test_dimensions;
end

function [] = test_attrs( varargin )
%% Test: Access Attributes
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.create_data_array('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);

    assert(~isempty(da.id));
    assert(strcmp(da.name, 'daTest'));
    assert(strcmp(da.type, 'test nixDataArray'));

    da.type = 'nixDataArray';
    assert(strcmp(da.type, 'nixDataArray'));

    assert(isempty(da.definition));
    da.definition = 'data array definition';
    assert(strcmp(da.definition, 'data array definition'));

    da.definition = '';
    assert(isempty(da.definition));

    assert(isempty(da.unit));
    da.unit = 'ms';
    assert(strcmp(da.unit, 'ms'));

    da.unit = '';
    assert(isempty(da.unit));

    assert(isempty(da.label));
    da.label = 'data array label';
    assert(strcmp(da.label, 'data array label'));

    da.label = '';
    assert(isempty(da.label));
end

%% Test: Read all data from DataArray
function [] = test_open_data( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    daType = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nix.Block');

    da = b.create_data_array('logicalArray', daType, nix.DataType.Bool, [3 3]);
    assert(islogical(da.read_all));
    da = b.create_data_array('doubleDataArray', daType, nix.DataType.Double, [3 3]);
    assert(isa(da.read_all, 'double'));
    da = b.create_data_array('floatDataArray', daType, nix.DataType.Float, [3 3]);
    assert(isfloat(da.read_all));
    da = b.create_data_array('Int8DataArray', daType, nix.DataType.Int8, [3 3]);
    assert(isa(da.read_all, 'int8'));
    da = b.create_data_array('Int16DataArray', daType, nix.DataType.Int16, [3 3]);
    assert(isa(da.read_all, 'int16'));
    da = b.create_data_array('Int32DataArray', daType, nix.DataType.Int32, [3 3]);
    assert(isa(da.read_all, 'int32'));
    da = b.create_data_array('Int64DataArray', daType, nix.DataType.Int64, [3 3]);
    assert(isa(da.read_all, 'int64'));
    da = b.create_data_array('UInt8DataArray', daType, nix.DataType.UInt8, [3 3]);
    assert(isa(da.read_all, 'uint8'));
    da = b.create_data_array('UInt16DataArray', daType, nix.DataType.UInt16, [3 3]);
    assert(isa(da.read_all, 'uint16'));
    da = b.create_data_array('UInt32DataArray', daType, nix.DataType.UInt32, [3 3]);
    assert(isa(da.read_all, 'uint32'));
    da = b.create_data_array('UInt64DataArray', daType, nix.DataType.UInt64, [3 3]);
    assert(isa(da.read_all, 'uint64'));
end

%% Test: Set metadata
function [] = test_set_metadata ( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    secName1 = 'testSection1';
    secName2 = 'testSection2';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    tmp = f.createSection(secName1, 'nixSection');
    tmp = f.createSection(secName2, 'nixSection');

    b = f.createBlock('testBlock', 'nixBlock');
    da = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(da.open_metadata));
    assert(isempty(f.blocks{1}.dataArrays{1}.open_metadata));

    da.set_metadata(f.sections{1});
    assert(strcmp(da.open_metadata.name, secName1));
    assert(strcmp(f.blocks{1}.dataArrays{1}.open_metadata.name, secName1));

    da.set_metadata(f.sections{2});
    assert(strcmp(da.open_metadata.name, secName2));
    assert(strcmp(f.blocks{1}.dataArrays{1}.open_metadata.name, secName2));

    da.set_metadata('');
    assert(isempty(da.open_metadata));
    assert(isempty(f.blocks{1}.dataArrays{1}.open_metadata));
    
    da.set_metadata(f.sections{2});
    clear tmp da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.dataArrays{1}.open_metadata.name, secName2));    
end

%% Test: Open metadata
function [] = test_open_metadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.create_data_array('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    da.set_metadata(f.sections{1});

    assert(strcmp(da.open_metadata.name, 'testSection'));
end

%% Test: List sources
function [] = test_list_sources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    d1 = b.dataArrays{1};

    assert(~isempty(d1.sources));
    assert(strcmp(d1.sources{1}.name, 'Unit 5'));
end

%% Test: Write Data double
function [] = test_write_data_double( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1 2 3 4 5];
    logData = logical([1 0 1 0 1]);
    charData = ['a' 'b' 'c' 'd' 'e'];
    cellData = {1 2 3 4 5};
    
    da = b.create_data_array('numericArray', typeDA, nix.DataType.Double, 5);
    da.write_all(numData);
    assert(isequal(da.read_all(), numData));

    try
        da.write_all(logData);
    catch ME
        assert(strcmp(ME.identifier, 'DataArray:improperDataType'));
    end;
    try
        da.write_all(charData);
    catch ME
        assert(strcmp(ME.identifier, 'DataArray:improperDataType'));
    end;
    try
        da.write_all(cellData);
    catch ME
        assert(strcmp(ME.identifier, 'DataArray:improperDataType'));
    end;

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.read_all, numData));
end

%% Test: Write Data logical
function [] = test_write_data_logical( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    logData = logical([1 0 1 0 1]);
    numData = [1 2 3 4 5];
    charData = ['a' 'b' 'c' 'd' 'e'];
    
    da = b.create_data_array('logicalArray', typeDA, nix.DataType.Bool, 5);
    da.write_all(logData);
    assert(isequal(da.read_all, logData));
    try
        da.write_all(numData);
    catch ME
        assert(strcmp(ME.identifier, 'DataArray:improperDataType'));
    end;
    try
        da.write_all(charData);
    catch ME
        assert(strcmp(ME.identifier, 'DataArray:improperDataType'));
    end;

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.read_all, logData));
end

%% Test: Write Data float
function [] = test_write_data_float( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1.3 2.4143 3.9878 4.1239 5];
    
    da = b.create_data_array('floatArray', typeDA, nix.DataType.Float, 5);
    da.write_all(numData);
    assert(isequal(da.read_all, single(numData)));

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.read_all, single(numData)));
end

%% Test: Write Data integer
function [] = test_write_data_integer( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1 2 3; 4 5 6; 7 8 9];
    
    da = b.create_data_array('Int8DataArray', typeDA, nix.DataType.Int8, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('Int16DataArray', typeDA, nix.DataType.Int16, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('Int32DataArray', typeDA, nix.DataType.Int32, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('Int64DataArray', typeDA, nix.DataType.Int64, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('UInt8DataArray', typeDA, nix.DataType.UInt8, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('UInt16DataArray', typeDA, nix.DataType.UInt16, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('UInt32DataArray', typeDA, nix.DataType.UInt32, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));
    da = b.create_data_array('UInt64DataArray', typeDA, nix.DataType.UInt64, [3 3]);
    da.write_all(numData);
    assert(isequal(da.read_all, numData));

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{2}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{3}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{4}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{5}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{6}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{7}.read_all, numData));
    assert(isequal(f.blocks{1}.dataArrays{8}.read_all, numData));
end

%% Test: Add sources by entity and id
function [] = test_add_source ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getDataArray = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(getDataArray.sources));
    getDataArray.add_source(getSource.sources{1}.id);
    getDataArray.add_source(getSource.sources{2});
    assert(size(getDataArray.sources, 1) == 2);
end

%% Test: Remove sources by entity and id
function [] = test_remove_source ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    getSource = b.create_source('sourceTest', 'nixSource');
    tmp = getSource.create_source('nestedSource1', 'nixSource');
    tmp = getSource.create_source('nestedSource2', 'nixSource');
    getDataArray = b.create_data_array('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    getDataArray.add_source(getSource.sources{1}.id);
    getDataArray.add_source(getSource.sources{2});

    assert(getDataArray.remove_source(getSource.sources{2}));
    assert(getDataArray.remove_source(getSource.sources{1}.id));
    assert(isempty(getDataArray.sources));

    assert(getDataArray.remove_source('I do not exist'));
    assert(size(getSource.sources, 1) == 2);
end

%% Test: Dimensions
function [] = test_dimensions( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.create_data_array('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    
    assert(isempty(da.dimensions));
    assert(isempty(f.blocks{1}.dataArrays{1}.dimensions));
    
    da.append_set_dimension();
    assert(length(da.dimensions) == 1);
    assert(strcmp(da.dimensions{1}.dimensionType, 'set'));
    assert(strcmp(f.blocks{1}.dataArrays{1}.dimensions{1}.dimensionType, 'set'));
    
    da.append_sampled_dimension(200);
    assert(length(da.dimensions) == 2);
    assert(strcmp(da.dimensions{2}.dimensionType, 'sample'));
    assert(da.dimensions{2}.samplingInterval == 200);
    assert(f.blocks{1}.dataArrays{1}.dimensions{2}.samplingInterval == 200);
    
    ticks = [1, 2, 3, 4];
    da.append_range_dimension(ticks);
    assert(length(da.dimensions) == 3);
    assert(strcmp(da.dimensions{3}.dimensionType, 'range'));
    assert(isequal(da.dimensions{3}.ticks, ticks));
    assert(isequal(f.blocks{1}.dataArrays{1}.dimensions{3}.ticks, ticks));
    assert(~da.dimensions{3}.isAlias);

    da.delete_dimensions();
    assert(isempty(da.dimensions));
   
    try
        da.append_alias_range_dimension;
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end;
    
    da.append_set_dimension();
    try
        da.append_alias_range_dimension();
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end;
    
    daAlias = b.create_data_array('aliasDimTest', 'nix.DataArray', ...
        nix.DataType.Double, 25);
    daAlias.append_alias_range_dimension();
    assert(f.blocks{1}.dataArrays{2}.dimensions{1}.isAlias);
    
    clear daAlias da b f;
    f = nix.File(fileName, nix.FileMode.ReadWrite);
    assert(f.blocks{1}.dataArrays{2}.dimensions{1}.isAlias);
    
    %-- Test for the alias dimension shape work around
    daAliasWa = f.blocks{1}.create_data_array_from_data('aliasDimWTest1', ...
        'nix.DataArray', [1 2 3]);
    daAliasWa.append_alias_range_dimension();
    assert(daAliasWa.dimensions{1}.isAlias);
    
    daAliasWa = f.blocks{1}.create_data_array_from_data('aliasDimWATest2', ...
        'nix.DataArray', [1; 2; 3]);
    assert(isequal(daAliasWa.shape, [3 1]));
    
    daAliasWa = f.blocks{1}.create_data_array_from_data('aliasDimWATest3', ...
        'nix.DataArray', [1 2 3; 2 4 5; 3 6 7]);
    assert(isequal(daAliasWa.shape, [3 3]));
end
