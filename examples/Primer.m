%% -------------------------------------
% Here is a short Primer on how to access NIX file from Matlab 
% using nix-mx.
% --------------------------------------

clear all;

%% File operations
path = 'C:\projects\nix-mx\tests\test.h5';

% Open NIX file
f = nix.File(path, nix.FileMode.ReadOnly);

% file contents overview
for i = 1:length(f.blocks)
    b = f.blocks{i};
    
    % fetch trial indexes of a certain type = 'nix.trial'
    trial_idx = cellfun(@(x) strcmp(x.type, 'nix.trial'), b.tags);
    disp([10 b.name ': ' num2str(length(nonzeros(trial_idx))) ' trials']);
    
    % display source names
    for j = 1:length(b.sources)
        fprintf(['\t' b.sources{j}.name]);
    end
end

% iterate over Blocks and display their names
cellfun(@(x) disp(x.name), f.blocks);

% get a certain Block
b = f.blocks{2};

%% Data operations

% get Data Arrays of a certain type
idx = cellfun(@(x) strcmp(x.type, 'nix.spiketimes'), b.dataArrays);
selection1 = b.dataArrays(idx);

% get DataArrays by several criteria
cond1 = @(x) ~isempty(strfind(x.name, 'SpikeActivity'));
cond2 = @(x) any(cellfun(@(y) strcmp(y.name, 'Unit 7'), x.sources));
cond3 = @(x) x.open_metadata.properties_map('Target') == 2;
cond4 = @(x) x.open_metadata.properties_map('BehavioralCondition') == 3;
idx = cellfun(@(x) cond1(x) & cond2(x) & cond3(x) & cond4(x), b.dataArrays);
selection2 = b.dataArrays(idx);

% get actual data
d1 = selection2{1};
dataset = d1.read_all();

% understand dimensions
dim1 = d1.dimensions{1};
dim1.type
dim1.unit

% plot data
[row, col] = find(dataset);
scatter(row, col, 'filled');

%% Metadata operations

% explore root metadata Sections (type, name)
cellfun(@(x) disp(strcat(x.type, ': ', x.name)), f.sections);

% access subsections
sec = f.sections{2}.sections{1};

% display all Section properties
cellfun(@(x) disp(x), sec.properties_cell);

% get a certain Value by index
value = sec.properties_cell{1}.values{1};

% or by name
value = sec.properties_map('Name');

%% clear space
clear all;
