% nix.SampledDimension class provides access to the SampledDimension properties.
%
% Instances of the SampledDimension class are used to describe a dimension of data in
% a DataArray that has been sampled in regular intervals. For example this can be 
% a time axis.
% SampledDimensions are characterized by the label for the dimension, the unit in 
% which the sampling interval is given. If not specified otherwise the dimension 
% starts with zero offset.
%
% nix.SampledDimension dynamic properties
%   dimensionType (char):  read-only, returns type of the dimension as string.
%   label (char):          read-write, gets and sets the label of the dimension.
%   unit (char):           read-write, gets and sets the unit of the dimension and its 
%                          sampling interval. Only SI units are supported.
%   samplingInterval (double):  read-write, gets and sets the sampling interval
%                               of the dimension.
%   offset (double):        read-write, The offset defines at which position the sampling
%                           was started. The offset is interpreted in the same unit as
%                           the sampling interval.
%
%  Examples:    dt = currDataArray.dimensions{1}.dimensionType;
%
%               getLabel = currDimension.label;
%               currDimension.dimensions{2}.label = 'Frequency';
%
%               getUnit = currDimension.unit;
%               currDimension.unit = 'Hz';
%
%               getSampling = currDimension.samplingInterval;
%               currDimension.samplingInterval = 200;
%
%               getOffset = currDimension.offset;
%               currDimension.offset = 8;
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

classdef SampledDimension < nix.Entity

    properties (Hidden)
        alias = 'SampledDimension'  % nix-mx namespace to access SampledDimension specific nix backend functions.
    end

    methods
        function obj = SampledDimension(h)
            obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'dimensionType', 'r');
            nix.Dynamic.addProperty(obj, 'label', 'rw');
            nix.Dynamic.addProperty(obj, 'unit', 'rw');
            nix.Dynamic.addProperty(obj, 'samplingInterval', 'rw');
            nix.Dynamic.addProperty(obj, 'offset', 'rw');
        end

        function r = indexOf(obj, position)
            % Returns the index of the given position (data point).
            %
            % This method returns the index of the given position. Use this method for
            % example to find out which data point (index) relates to a given time.
            % Note: This method does not check if the position is within the
            % extent of the data!
            %
            % position (double):  A data value e.g. a time.
            %
            % Returns:  (double) The corresponding index.
            %
            % Example:  getIndex = currDimension.indexOf(12);

            fname = strcat(obj.alias, '::indexOf');
            idx = nix_mx(fname, obj.nixhandle, position);
            r = double(idx + 1); % convert index from c++ to Matlab style.
        end

        function r = positionAt(obj, index)
            % Returns the position of this dimension at a given index.
            %
            % This method returns the position at a given index. Use this method for
            % example to find the position that relates to a certain index. Note: This
            % method does not check if the index is the extent of the data!
            %
            % index (double):  Index of interest.
            %
            % Returns:  (double) The respective position e.g. a time.
            %
            % Example:  getPosition = currDimension.positionAt(236);

            index = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::positionAt');
            r = nix_mx(fname, obj.nixhandle, index);
        end

        function r = axis(obj, count, startIndex)
            % Returns an array of values for axis labeling, calculated by
            % the dimensions sampling interval.
            %
            % count (double):       Number of values to be returned.
            % startIndex (double):  Starting index for the returned values.
            %
            % Returns:  ([double]) Axis labeling values array.
            %
            % Example:  currDimension.samplingInterval = 200;
            %           getAxis = currDimension.axis(3, 1);   %-- returns [0 200 400]
            %           getAxis = currDimension.axis(3, 5);   %-- returns [800 1000 1200]

            if (nargin < 3)
                startIndex = 1;
            end

            startIndex = nix.Utils.handleIndex(startIndex);
            fname = strcat(obj.alias, '::axis');
            r = nix_mx(fname, obj.nixhandle, count, startIndex);
        end
    end

end
