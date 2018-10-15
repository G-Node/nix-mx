% TestDataArray provides tests for all supported nix.DataArray methods.
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestDataArray
    funcs = {};
    funcs{end+1} = @testAttributes;
    funcs{end+1} = @testOpenData;
    funcs{end+1} = @testSetMetadata;
    funcs{end+1} = @testOpenMetadata;
    funcs{end+1} = @testListSources;
    funcs{end+1} = @testWriteDataDouble;
    funcs{end+1} = @testWriteDataLogical;
    funcs{end+1} = @testWriteDataFloat;
    funcs{end+1} = @testWriteDataInteger;
    funcs{end+1} = @testAddSource;
    funcs{end+1} = @testAddSources;
    funcs{end+1} = @testOpenSource;
    funcs{end+1} = @testOpenSourceIdx;
    funcs{end+1} = @testRemoveSource;
    funcs{end+1} = @testHasSource;
    funcs{end+1} = @testSourceCount;
    funcs{end+1} = @testDimensions;
    funcs{end+1} = @testOpenDimensionIdx;
    funcs{end+1} = @testDimensionCount;
    funcs{end+1} = @testDatatype;
    funcs{end+1} = @testSetDataExtent;
    funcs{end+1} = @testCompare;
    funcs{end+1} = @testFilterSource;
end

%% Test: Access Attributes
function [] = testAttributes( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);

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

    assert(isempty(da.expansionOrigin));
    da.expansionOrigin = 2.5;
    assert(da.expansionOrigin == 2.5)
    
    da.expansionOrigin = '';
    assert(isempty(da.expansionOrigin));
    
    assert(isempty(da.polynomCoefficients));
    c = [1.1 1.2];
    da.polynomCoefficients = c;
    assert(da.polynomCoefficients(1) == c(1))
    
    da.polynomCoefficients = '';
    assert(isempty(da.polynomCoefficients));
end

%% Test: Read all data from DataArray
function [] = testOpenData( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    daType = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nix.Block');

    da = b.createDataArray('logicalArray', daType, nix.DataType.Bool, [3 3]);
    assert(islogical(da.readAllData));
    da = b.createDataArray('doubleDataArray', daType, nix.DataType.Double, [3 3]);
    assert(isa(da.readAllData, 'double'));
    da = b.createDataArray('floatDataArray', daType, nix.DataType.Float, [3 3]);
    assert(isfloat(da.readAllData));
    da = b.createDataArray('Int8DataArray', daType, nix.DataType.Int8, [3 3]);
    assert(isa(da.readAllData, 'int8'));
    da = b.createDataArray('Int16DataArray', daType, nix.DataType.Int16, [3 3]);
    assert(isa(da.readAllData, 'int16'));
    da = b.createDataArray('Int32DataArray', daType, nix.DataType.Int32, [3 3]);
    assert(isa(da.readAllData, 'int32'));
    da = b.createDataArray('Int64DataArray', daType, nix.DataType.Int64, [3 3]);
    assert(isa(da.readAllData, 'int64'));
    da = b.createDataArray('UInt8DataArray', daType, nix.DataType.UInt8, [3 3]);
    assert(isa(da.readAllData, 'uint8'));
    da = b.createDataArray('UInt16DataArray', daType, nix.DataType.UInt16, [3 3]);
    assert(isa(da.readAllData, 'uint16'));
    da = b.createDataArray('UInt32DataArray', daType, nix.DataType.UInt32, [3 3]);
    assert(isa(da.readAllData, 'uint32'));
    da = b.createDataArray('UInt64DataArray', daType, nix.DataType.UInt64, [3 3]);
    assert(isa(da.readAllData, 'uint64'));
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
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(da.openMetadata));
    assert(isempty(f.blocks{1}.dataArrays{1}.openMetadata));

    da.setMetadata(f.sections{1});
    assert(strcmp(da.openMetadata.name, secName1));
    assert(strcmp(f.blocks{1}.dataArrays{1}.openMetadata.name, secName1));

    da.setMetadata(f.sections{2});
    assert(strcmp(da.openMetadata.name, secName2));
    assert(strcmp(f.blocks{1}.dataArrays{1}.openMetadata.name, secName2));

    da.setMetadata('');
    assert(isempty(da.openMetadata));
    assert(isempty(f.blocks{1}.dataArrays{1}.openMetadata));
    
    da.setMetadata(f.sections{2});

    clear tmp da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.dataArrays{1}.openMetadata.name, secName2));    
end

%% Test: Open metadata
function [] = testOpenMetadata( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    tmp = f.createSection('testSection', 'nixSection');
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    da.setMetadata(f.sections{1});

    assert(strcmp(da.openMetadata.name, 'testSection'));
end

%% Test: List Sources
function [] = testListSources( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'test.h5'), nix.FileMode.ReadOnly);
    b = f.blocks{1};
    d1 = b.dataArrays{1};

    assert(~isempty(d1.sources));
    assert(strcmp(d1.sources{1}.name, 'Unit 5'));
end

%% Test: Write Data double
function [] = testWriteDataDouble( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1 2 3 4 5];
    logData = logical([1 0 1 0 1]);
    charData = ['a' 'b' 'c' 'd' 'e'];
    cellData = {1 2 3 4 5};
    
    da = b.createDataArray('numericArray', typeDA, nix.DataType.Double, 5);
    da.writeAllData(numData);
    assert(isequal(da.readAllData(), numData));

    try
        da.writeAllData(logData);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:improperDataType'));
    end
    try
        da.writeAllData(charData);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:improperDataType'));
    end
    try
        da.writeAllData(cellData);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:improperDataType'));
    end

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.readAllData, numData));
end

%% Test: Write Data logical
function [] = testWriteDataLogical( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    logData = logical([1 0 1 0 1]);
    numData = [1 2 3 4 5];
    charData = ['a' 'b' 'c' 'd' 'e'];
    
    da = b.createDataArray('logicalArray', typeDA, nix.DataType.Bool, 5);
    da.writeAllData(logData);
    assert(isequal(da.readAllData, logData));
    try
        da.writeAllData(numData);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:improperDataType'));
    end
    try
        da.writeAllData(charData);
    catch ME
        assert(strcmp(ME.identifier, 'NIXMX:improperDataType'));
    end

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.readAllData, logData));
end

%% Test: Write Data float
function [] = testWriteDataFloat( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1.3 2.4143 3.9878 4.1239 5];
    
    da = b.createDataArray('floatArray', typeDA, nix.DataType.Float, 5);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, single(numData)));

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.readAllData, single(numData)));
end

%% Test: Write Data integer
function [] = testWriteDataInteger( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testDataArray', 'nixblock');

    numData = [1 2 3; 4 5 6; 7 8 9];
    
    da = b.createDataArray('Int8DataArray', typeDA, nix.DataType.Int8, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('Int16DataArray', typeDA, nix.DataType.Int16, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('Int32DataArray', typeDA, nix.DataType.Int32, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('Int64DataArray', typeDA, nix.DataType.Int64, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('UInt8DataArray', typeDA, nix.DataType.UInt8, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('UInt16DataArray', typeDA, nix.DataType.UInt16, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('UInt32DataArray', typeDA, nix.DataType.UInt32, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));
    da = b.createDataArray('UInt64DataArray', typeDA, nix.DataType.UInt64, [3 3]);
    da.writeAllData(numData);
    assert(isequal(da.readAllData, numData));

    clear da b f;
    f = nix.File(fileName, nix.FileMode.ReadOnly);
    assert(isequal(f.blocks{1}.dataArrays{1}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{2}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{3}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{4}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{5}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{6}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{7}.readAllData, numData));
    assert(isequal(f.blocks{1}.dataArrays{8}.readAllData, numData));
end

%% Test: Add Source by entity and id
function [] = testAddSource ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    d = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(d.sources));
    d.addSource(s.sources{1}.id);
    d.addSource(s.sources{2});
    assert(size(d.sources, 1) == 2);
end

%% Test: Add Sources by entity cell array
function [] = testAddSources ( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    tmp = b.createSource('testSource1', 'nixSource');
    tmp = b.createSource('testSource2', 'nixSource');
    tmp = b.createSource('testSource3', 'nixSource');

    assert(isempty(d.sources));

    try
        d.addSources('hurra');
    catch ME
        assert(strcmp(ME.message, 'Expected cell array'));
    end;
    assert(isempty(d.sources));

    try
        d.addSources({12, 13});
    catch ME
        assert(~isempty(strfind(ME.message, 'not a nix.Source')));
    end;
    assert(isempty(d.sources));

    d.addSources(b.sources());
    assert(size(d.sources, 1) == 3);

    clear d tmp b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(size(f.blocks{1}.dataArrays{1}.sources, 1) == 3);
end

%% Test: Open Source by id or name
function [] = testOpenSource( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('test', 'nixBlock');
    s = b.createSource('test', 'nixSource');
    sourceName = 'nestedSource';
    nSource = s.createSource(sourceName, 'nixSource');

    d = b.createDataArray('sourceTest', 'nixDataArray', nix.DataType.Double, [1 2]);
    d.addSource(nSource);

    % -- test get source by ID
    assert(~isempty(d.openSource(nSource.id)));

    % -- test get source by name
    assert(~isempty(d.openSource(sourceName)));

    %-- test open non existing source
    assert(isempty(d.openSource('I do not exist')));
end

function [] = testOpenSourceIdx( varargin )
%% Test Open Source by index
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [2 9]);
    s1 = b.createSource('testSource1', 'nixSource');
    s2 = b.createSource('testSource2', 'nixSource');
    s3 = b.createSource('testSource3', 'nixSource');
    d.addSource(s1);
    d.addSource(s2);
    d.addSource(s3);

    assert(strcmp(f.blocks{1}.dataArrays{1}.openSourceIdx(1).name, s1.name));
    assert(strcmp(f.blocks{1}.dataArrays{1}.openSourceIdx(2).name, s2.name));
    assert(strcmp(f.blocks{1}.dataArrays{1}.openSourceIdx(3).name, s3.name));
end

%% Test: Remove Source by entity and id
function [] = testRemoveSource ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('sourceTest', 'nixBlock');
    s = b.createSource('sourceTest', 'nixSource');
    tmp = s.createSource('nestedSource1', 'nixSource');
    tmp = s.createSource('nestedSource2', 'nixSource');
    d = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);

    d.addSource(s.sources{1}.id);
    d.addSource(s.sources{2});

    assert(d.removeSource(s.sources{2}));
    assert(d.removeSource(s.sources{1}.id));
    assert(isempty(d.sources));

    assert(d.removeSource('I do not exist'));
    assert(size(s.sources, 1) == 2);
end

%% Test: Has Source by id or entity
function [] = testHasSource( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('testblock', 'nixBlock');
    s = b.createSource('sourceTest1', 'nixSource');
    sID = s.id;
    d = b.createDataArray('sourceTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    d.addSource(b.sources{1});

    assert(~d.hasSource('I do not exist'));
    assert(d.hasSource(s));

    clear d s b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);

    assert(f.blocks{1}.dataArrays{1}.hasSource(sID));
end

%% Test: Source count
function [] = testSourceCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    
    assert(d.sourceCount() == 0);
    d.addSource(b.createSource('testSource1', 'nixSource'));
    assert(d.sourceCount() == 1);
    d.addSource(b.createSource('testSource2', 'nixSource'));
    assert(d.sourceCount() == 2);
    clear d b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.dataArrays{1}.sourceCount() == 2);
end

%% Test: Dimensions
function [] = testDimensions( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);

    assert(isempty(da.dimensions));
    assert(isempty(f.blocks{1}.dataArrays{1}.dimensions));

    da.appendSetDimension();

    assert(length(da.dimensions) == 1);

    assert(strcmp(da.dimensions{1}.dimensionType, 'set'));
    assert(strcmp(f.blocks{1}.dataArrays{1}.dimensions{1}.dimensionType, 'set'));
    
    da.appendSampledDimension(200);
    assert(length(da.dimensions) == 2);
    assert(strcmp(da.dimensions{2}.dimensionType, 'sample'));
    assert(da.dimensions{2}.samplingInterval == 200);
    assert(f.blocks{1}.dataArrays{1}.dimensions{2}.samplingInterval == 200);
    
    ticks = [1, 2, 3, 4];
    da.appendRangeDimension(ticks);
    assert(length(da.dimensions) == 3);
    assert(strcmp(da.dimensions{3}.dimensionType, 'range'));
    assert(isequal(da.dimensions{3}.ticks, ticks));
    assert(isequal(f.blocks{1}.dataArrays{1}.dimensions{3}.ticks, ticks));
    assert(~da.dimensions{3}.isAlias);

    da.deleteDimensions();
    assert(isempty(da.dimensions));
   
    try
        da.appendAliasRangeDimension;
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end
    
    da.appendSetDimension();
    try
        da.appendAliasRangeDimension();
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end
    
    daAlias = b.createDataArray('aliasDimTest', 'nix.DataArray', ...
        nix.DataType.Double, 25);
    daAlias.appendAliasRangeDimension();
    assert(f.blocks{1}.dataArrays{2}.dimensions{1}.isAlias);
    
    clear daAlias da b f;
    f = nix.File(fileName, nix.FileMode.ReadWrite);
    assert(f.blocks{1}.dataArrays{2}.dimensions{1}.isAlias);
    
    %-- Test for the alias dimension shape work around
    daAliasWa = f.blocks{1}.createDataArrayFromData('aliasDimWTest1', ...
        'nix.DataArray', [1 2 3]);
    daAliasWa.appendAliasRangeDimension();
    assert(daAliasWa.dimensions{1}.isAlias);
    
    daAliasWa = f.blocks{1}.createDataArrayFromData('aliasDimWATest2', ...
        'nix.DataArray', [1; 2; 3]);
    assert(isequal(daAliasWa.dataExtent, [3 1]));
    
    daAliasWa = f.blocks{1}.createDataArrayFromData('aliasDimWATest3', ...
        'nix.DataArray', [1 2 3; 2 4 5; 3 6 7]);
    assert(isequal(daAliasWa.dataExtent, [3 3]));
end

%% Test: Open Dimension by index
function [] = testOpenDimensionIdx( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    
    da.appendSetDimension();
    da.appendSampledDimension(200);
    da.appendRangeDimension([1, 2, 3, 4]);

    assert(strcmp(da.openDimensionIdx(1).dimensionType, 'set'));
    assert(strcmp(da.openDimensionIdx(2).dimensionType, 'sample'));
    assert(strcmp(da.openDimensionIdx(3).dimensionType, 'range'));
end

%% Test: Dimension count
function [] = testDimensionCount( varargin )
    testFile = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(testFile, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    da = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [1 2]);
    
    assert(da.dimensionCount == 0);

    da.appendSetDimension();
    assert(da.dimensionCount == 1);

    da.appendSampledDimension(200);
    assert(da.dimensionCount == 2);

    da.deleteDimensions();
    assert(da.dimensionCount == 0);

    da.appendRangeDimension([1, 2, 3, 4]);

    clear da b f;
    f = nix.File(testFile, nix.FileMode.ReadOnly);
    assert(f.blocks{1}.dataArrays{1}.dimensionCount() == 1);
end

%% Test: Datatype
function [] = testDatatype( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    typeDA = 'nix.DataArray';
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixblock');

    da = b.createDataArrayFromData('testDataArray1', typeDA, [1 2 3]);
    assert(strcmp(da.datatype, 'double'));
    
    da = b.createDataArray('testDataArray2', typeDA, nix.DataType.Bool, 5);
    da.writeAllData(logical([1 0 1 1 1]));
    assert(strcmp(da.datatype, 'logical'));
end

%% Test: Set extent
function [] = testSetDataExtent( varargin )
    fileName = fullfile(pwd, 'tests', 'testRW.h5');
    f = nix.File(fileName, nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixblock');

    da = b.createDataArrayFromData('testDataArray1', 'nix.DataArray', [1 2 3; 4 5 6]);
    extent = [4 6];
    da.setDataExtent(extent);
    assert(da.dataExtent(1) == extent(1) && size(da.readAllData, 2) == extent(2));
end

%% Test: Compare DataArray entities
function [] = testCompare( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b1 = f.createBlock('testBlock1', 'nixBlock');
    b2 = f.createBlock('testBlock2', 'nixBlock');
    d1 = b1.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Bool, [2 9]);
    d2 = b1.createDataArray('testDataArray2', 'nixDataArray', nix.DataType.Bool, [2 9]);
    d3 = b2.createDataArray('testDataArray1', 'nixDataArray', nix.DataType.Bool, [2 9]);

    assert(d1.compare(d2) < 0);
    assert(d1.compare(d1) == 0);
    assert(d2.compare(d1) > 0);
    assert(d1.compare(d3) ~= 0);
end

%% Test: Filter Sources
function [] = testFilterSource( varargin )
    filterName = 'filterMe';
    filterType = 'filterType';
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('testBlock', 'nixBlock');
    d = b.createDataArray('testDataArray', 'nixDataArray', nix.DataType.Double, [3 2 3]);
    s = b.createSource(filterName, 'nixSource');
    d.addSource(s);
    filterID = s.id;
	s = b.createSource('testSource1', filterType);
    d.addSource(s);
    filterIDs = {filterID, s.id};
    s = b.createSource('testSource2', filterType);
    d.addSource(s);

    % test empty id filter
    assert(isempty(f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.id, 'IdoNotExist')));

    % test nix.Filter.acceptall
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.acceptall, '');
    assert(size(filtered, 1) == 3);

    % test nix.Filter.id
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.id, filterID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, filterID));

    % test nix.Filter.ids
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.ids, filterIDs);
    assert(size(filtered, 1) == 2);
    assert(strcmp(filtered{1}.id, filterIDs{1}) || strcmp(filtered{1}.id, filterIDs{2}));
    
    % test nix.Filter.name
    filtered  = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.name, filterName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, filterName));
    
    % test nix.Filter.type
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.type, filterType);
    assert(size(filtered, 1) == 2);

    % test nix.Filter.metadata
    mainName = 'testSubSection';
    mainSource = b.createSource(mainName, 'nixSource');
    d.addSource(mainSource);
    subName = 'testSubSection1';
    s = f.createSection(subName, 'nixSection');
    mainSource.setMetadata(s);
    subID = s.id;

    assert(isempty(f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.metadata, 'Do not exist')));
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.metadata, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));

    % test nix.Filter.source
    mainName = 'testSubSource';
    main = b.createSource(mainName, 'nixSource');
    d.addSource(main);
    mainID = main.id;
    subName = 'testSubSource1';
    s = main.createSource(subName, 'nixSource');
    subID = s.id;

    assert(isempty(f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.source, 'Do not exist')));
    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.source, subName);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.id, mainID));

    filtered = f.blocks{1}.dataArrays{1}.filterSources(nix.Filter.source, subID);
    assert(size(filtered, 1) == 1);
    assert(strcmp(filtered{1}.name, mainName));
end
