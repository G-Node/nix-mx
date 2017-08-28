% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestDimensions
% TestDimensions tests for Dimensions

    funcs = {};
    funcs{end+1} = @testSetDimension;
    funcs{end+1} = @testSampleDimension;
    funcs{end+1} = @testRangeDimension;
end

function [] = testSetDimension( varargin )
%% Test: set dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    d1 = da.appendSetDimension();

    assert(strcmp(d1.dimensionType, 'set'));
    assert(isempty(d1.labels));
    
    d1.labels = {'foo', 'bar'};
    assert(strcmp(d1.labels{1}, 'foo'));
    assert(strcmp(d1.labels{2}, 'bar'));
    
    d1.labels = {};
    assert(isempty(d1.labels));
    
    try
        d1.labels = 'mV';
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
    try
        d1.labels = ['mV', 'uA'];
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
    try
        d1.labels = 1;
    catch ME
        assert(strcmp(ME.identifier, 'MATLAB:class:SetProhibited'));
    end;
end

function [] = testSampleDimension( varargin )
%% Test: sampled dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    d1 = da.appendSampledDimension(200);

    assert(strcmp(d1.dimensionType, 'sample'));
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(d1.samplingInterval == 200);
    assert(isempty(d1.offset));

    axis = d1.axis(10, 1);
    assert(axis(1) == 0);
    assert(length(axis) == 10);
    assert(axis(end) == (length(axis) - 1) * d1.samplingInterval);

    d1.label = 'foo';
    d1.unit = 'mV';
    d1.samplingInterval = 325;
    d1.offset = 500;

    assert(strcmp(d1.label, 'foo'));
    assert(strcmp(d1.unit, 'mV'));
    assert(d1.samplingInterval == 325);
    assert(d1.offset == 500);
    
    axis = d1.axis(10, 1);
    assert(axis(1) == d1.offset);
    assert(length(axis) == 10);
    assert(axis(end) == (length(axis) - 1) * d1.samplingInterval + d1.offset);
    
    assert(d1.positionAt(1) == d1.offset);
    assert(d1.positionAt(10) == d1.offset + 9 * d1.samplingInterval);

    d1.label = '';
    d1.unit = '';
    d1.offset = 0;
    
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(d1.samplingInterval == 325);
    assert(d1.offset == 0);

    axis = d1.axis(10, 1);
    assert(axis(1) == 0);
    assert(axis(end) == (length(axis) - 1) * d1.samplingInterval + d1.offset);
    
    assert(d1.positionAt(1) == d1.offset);
    assert(d1.positionAt(10) == d1.offset + 9 * d1.samplingInterval);
end

function [] = testRangeDimension( varargin )
%% Test: range dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('daTestBlock', 'test nixBlock');
    da = b.createDataArray('daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    ticks = [1 2 3 4];
    d1 = da.appendRangeDimension(ticks);

    assert(strcmp(d1.dimensionType, 'range'));
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(isequal(d1.ticks, ticks));

    axis = d1.axis(3, 1);
    assert(axis(1) == ticks(1));
    assert(length(axis) == 3);
    assert(axis(end) == ticks(length(axis)));

    assert(d1.tickAt(1) == ticks(1));
    assert(d1.tickAt(3) == ticks(3));

    newTicks = [5 6 7 8];
    d1.label = 'foo';
    d1.unit = 'mV';
    d1.ticks = newTicks;
    
    assert(strcmp(d1.label, 'foo'));
    assert(strcmp(d1.unit, 'mV'));
    assert(isequal(d1.ticks, newTicks));
    
    d1.label = '';
    d1.unit = '';
    
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
end
