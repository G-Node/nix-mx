%% -------------------------------------
% Here is a short Primer on how to access NIX file from Matlab 
% using nix-mx.
% --------------------------------------

path = 'C:\projects\nix-mx\tests\test.h5';

% Open NIX file
f = nix.File(path, nix.FileMode.ReadOnly);

% file contents overview
disp(f);

% display all Block names
cellfun(@(x) disp(x.name), f.blocks);

% get a certain Block
b = f.blocks{2};

% --------------------------------------

% get Data Arrays of a certain type
idx = cellfun(@(x) strcmp(x.type, 'nix.spiketimes'), b.data_arrays);
selection = b.data_arrays(idx);







% --------------------------------------

% explore root metadata Sections (type, name)
cellfun(@(x) disp(strcat(x.type, ': ', x.name)), f.sections);

% access subsections
sec = f.sections{2}.sections{1};

% display all Section properties
cellfun(@(x) disp(x), sec.props);

% get a certain Value
value = sec.props{1}.values{1};
