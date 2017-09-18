% TestFeature provides tests for all supported nix.Feature methods.
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

function funcs = TestFeature
    funcs = {};
    funcs{end+1} = @testOpenData;
    funcs{end+1} = @testHandleLinkType;
    funcs{end+1} = @testSetData;
end

%% Test: Open data from Feature
function [] = testOpenData ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createTag('featureTest', 'nixTag', [1, 2]);
    tmp = t.createFeature(b.dataArrays{1}, nix.LinkType.Tagged);
    
    feat = t.features{1};
    assert(~isempty(feat.openData));
end

%% Test: Get and set LinkType
function [] = testHandleLinkType ( varargin )
    fileName = 'testRW.h5';
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    da = b.createDataArray('featureTestDataArray', 'nixDataArray', nix.DataType.Double, [1 2 3 4 5 6]);
    t = b.createTag('featureTest', 'nixTag', [1, 2]);
    feat = t.createFeature(b.dataArrays{1}, nix.LinkType.Tagged);
    
    try
        feat.linkType = '';
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end;
    try
        feat.linkType = {};
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end;
    try
        feat.linkType = 1;
    catch ME
        assert(strcmp(ME.identifier, 'nix:arg:inval'));
    end;
    assert(f.blocks{1}.tags{1}.features{1}.linkType == 0);

    feat.linkType = nix.LinkType.Untagged;
    assert(f.blocks{1}.tags{1}.features{1}.linkType == 1);

    feat.linkType = nix.LinkType.Indexed;
    
    clear feat t da b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(f.blocks{1}.tags{1}.features{1}.linkType == 2);
end

%% Test: Set data by entity, id and name
function [] = testSetData ( varargin )
    fileName = 'testRW.h5';
    daName1 = 'featTestDA1';
    daName2 = 'featTestDA2';
    daName3 = 'featTestDA3';
    daName4 = 'featTestDA4';
    daType = 'nixDataArray';
    daData = [1 2 3 4 5 6];
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    da1 = b.createDataArray(daName1, daType, nix.DataType.Double, daData);
    da2 = b.createDataArray(daName2, daType, nix.DataType.Double, daData);
    da3 = b.createDataArray(daName3, daType, nix.DataType.Double, daData);
    da4 = b.createDataArray(daName4, daType, nix.DataType.Double, daData);
    t = b.createTag('featureTest', 'nixTag', [1, 2]);
    feat = t.createFeature(b.dataArrays{1}, nix.LinkType.Tagged);
    
    assert(strcmp(feat.openData.name, daName1));
    feat.setData(da2);
    assert(strcmp(f.blocks{1}.tags{1}.features{1}.openData.name, daName2));
    feat.setData(da3.id);
    assert(strcmp(f.blocks{1}.tags{1}.features{1}.openData.name, daName3));
    feat.setData(da4.name);
    
    clear feat t da4 da3 da2 da1 b f;
    f = nix.File(fullfile(pwd, 'tests', fileName), nix.FileMode.ReadOnly);
    assert(strcmp(f.blocks{1}.tags{1}.features{1}.openData.name, daName4));
end
