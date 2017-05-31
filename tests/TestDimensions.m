% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestDimensions
%TestDimensions tests for Dimensions
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_set_dimension;
    funcs{end+1} = @test_sample_dimension;
    funcs{end+1} = @test_range_dimension;
end

function [] = test_set_dimension( varargin )
%% Test: set dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('daTestBlock', 'test nixBlock');
    da = b.create_data_array(...
        'daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    d1 = da.append_set_dimension();

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

function [] = test_sample_dimension( varargin )
%% Test: sampled dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('daTestBlock', 'test nixBlock');
    da = b.create_data_array(...
        'daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    d1 = da.append_sampled_dimension(200);

    assert(strcmp(d1.dimensionType, 'sample'));
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(d1.samplingInterval == 200);
    assert(isempty(d1.offset));

    axis = d1.axis(10, 0);
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
    
    axis = d1.axis(10, 0);
    assert(axis(1) == d1.offset);
    assert(length(axis) == 10);
    assert(axis(end) == (length(axis) - 1) * d1.samplingInterval + d1.offset);
    
    assert(d1.position_at(0) == d1.offset);
    assert(d1.position_at(10) == d1.offset + 9 * d1.samplingInterval);

    d1.label = '';
    d1.unit = '';
    d1.offset = 0;
    
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(d1.samplingInterval == 325);
    assert(d1.offset == 0);

    axis = d1.axis(10, 0);
    assert(axis(1) == 0);
    assert(axis(end) == (length(axis) - 1) * d1.samplingInterval + d1.offset);
    
    assert(d1.position_at(0) == d1.offset);
    assert(d1.position_at(10) == d1.offset + 9 * d1.samplingInterval);
end

function [] = test_range_dimension( varargin )
%% Test: range dimension
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.create_block('daTestBlock', 'test nixBlock');
    da = b.create_data_array(...
        'daTest', 'test nixDataArray', nix.DataType.Double, [1 2]);
    ticks = [1 2 3 4];
    d1 = da.append_range_dimension(ticks);

    assert(strcmp(d1.dimensionType, 'range'));
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
    assert(isequal(d1.ticks, ticks));

    axis = d1.axis(3, 0);
    assert(axis(1) == ticks(1));
    assert(length(axis) == 3);
    assert(axis(end) == ticks(length(axis)));

    assert(d1.tick_at(0) == ticks(1));
    assert(d1.tick_at(3) == ticks(3));

    new_ticks = [5 6 7 8];
    d1.label = 'foo';
    d1.unit = 'mV';
    d1.ticks = new_ticks;
    
    assert(strcmp(d1.label, 'foo'));
    assert(strcmp(d1.unit, 'mV'));
    assert(isequal(d1.ticks, new_ticks));
    
    d1.label = '';
    d1.unit = '';
    
    assert(isempty(d1.label));
    assert(isempty(d1.unit));
end
