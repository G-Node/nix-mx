function funcs = TestFeature
%TESTTag tests for Tag
%   Detailed explanation goes here

    funcs = {};
    funcs{end+1} = @test_open_data;
end

%% Test: Open data from feature
function [] = test_open_data ( varargin )
    f = nix.File(fullfile(pwd, 'tests', 'testRW.h5'), nix.FileMode.Overwrite);
    b = f.createBlock('featureTest', 'nixBlock');
    tmp = b.create_data_array('featureTestDataArray', 'nixDataArray', 'double', [1 2 3 4 5 6]);
    getTag = b.create_tag('featureTest', 'nixTag', [1, 2]);
    tmp = getTag.add_feature(b.dataArrays{1}, nix.LinkType.Tagged);
    
    getFeature = getTag.features{1};
    assert(~isempty(getFeature.open_data));
end
