% nix.SetDimension class provides access to the SetDimension properties.
%
% Used to provide labels for dimensionless data e.g. when stacking  different signals. 
% In the example the first dimension would describe the measured unit, the second 
% dimension the time, the third dimension would provide labels for three different
% signals measured within the same experiment and packed into the same 3D DataArray.
%
% nix.SetDimension dynamic properties
%   dimensionType (char):  read-only, returns type of the dimension as string.
%   labels ([char]):       read-write, Character cell array to get and set
%                            labels of the dimension.
%
%  Examples:    dt = currDataArray.dimensions{1}.dimensionType;
%
%               labels = currDataArray.dimensions{2}.labels;
%               currDataArray.dimensions{2}.labels = {'sinus', 'cosinus'};
%
% See also nix.DataArray.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SetDimension < nix.Entity

    properties (Hidden)
        alias = 'SetDimension'  % nix-mx namespace to access SetDimension specific nix backend functions.
    end

    methods
        function obj = SetDimension(h)
            obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'dimensionType', 'r');
            nix.Dynamic.addProperty(obj, 'labels', 'rw');
        end
    end

end
