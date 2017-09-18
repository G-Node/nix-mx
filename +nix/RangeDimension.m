% nix.RangeDimension class provides access to the RangeDimension properties.
%
% The RangeDimension covers cases when indexes of a dimension are mapped to other values
% in a non-regular fashion. A use-case for this would be for example irregularly sampled
% time-series or certain kinds of histograms. To achieve the mapping of the indexes an
% array of mapping values must be provided. Those values are stored in the dimensions
% ticks property. In analogy to the SampledDimension a unit and a label can be defined.
%
% An AliasRangeDimension is a special case of a RangeDimension that uses the data 
% stored in the invoking DataArray as ticks. This works only(!) if the DataArray 
% is 1D and the stored data is numeric.
%
% nix.RangeDimension dynamic properties
%   dimensionType (char):  read-only, returns type of the dimension as string.
%   label (char):          read-write, gets and sets the label of the dimension.
%   unit (char):           read-write, gets and sets the unit of the dimension.
%                            Only SI units are supported.
%   ticks ([double]):      read-write, gets and sets the ticks of the dimension.
%                            The ticks map the index of the data at the respective 
%                            dimension to other values. This can be used to store data 
%                            that is sampled at irregular intervals.
%                            Note: Ticks must be ordered in ascending order.
%   isAlias (logical):     read-only, returns True if the current Dimension is an 
%                            AliasRangeDimension, False otherwise.
%
%  Examples:    dt = currDataArray.dimensions{1}.dimensionType;
%
%               getLabel = currDimension.label;
%               currDimension.dimensions{2}.label = 'Time';
%
%               getUnit = currDimension.unit;
%               currDimension.unit = 'ms';
%
%               getTicks = currDimension.ticks;
%               currDimension.ticks = [2 12 36 292];
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

classdef RangeDimension < nix.Entity

    properties (Hidden)
        alias = 'RangeDimension'  % nix-mx namespace to access RangeDimension specific nix backend functions.
    end

    methods
        function obj = RangeDimension(h)
            obj@nix.Entity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'dimensionType', 'r');
            nix.Dynamic.addProperty(obj, 'isAlias', 'r');
            nix.Dynamic.addProperty(obj, 'label', 'rw');
            nix.Dynamic.addProperty(obj, 'unit', 'rw');
            nix.Dynamic.addProperty(obj, 'ticks', 'rw');
        end

        function r = tickAt(obj, index)
            % Returns the entry of the RangeDimension at a given index.
            %
            % index (double):  The index of interest.
            %
            % Returns:  (double) The tick value at the given index or an
            %                    error if the index is out of range of the
            %                    dimensions tick array.
            %
            % Example:  getTickValue = currDimension.tickAt(101);

            index = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::tickAt');
            r = nix_mx(fname, obj.nixhandle, index);
        end

        function r = indexOf(obj, position)
            % Returns the index of the requested position or tick value.
            %
            % If the provided position is not a value in the tick array, the
            % method will return the index of the next tick larger than 
            % the provided value.
            %
            % position (double):  Tick value of the requested index.
            %
            % Returns:  (double) The index of the provided position.
            %
            % Example:  getIndexOfTick = currDimension.indexOf(12);

            fname = strcat(obj.alias, '::indexOf');
            idx = nix_mx(fname, obj.nixhandle, position);
            r = double(idx + 1); % convert index from c++ to Matlab style.
        end

        function r = axis(obj, count, startIndex)
            % Returns an array of values for axis labeling.
            %
            % count (double):       Number of tick values to be returned.
            % startIndex (double):  Starting index for the returned tick values.
            %
            % Returns:  ([double]) Axis labeling values array.
            %
            % Example:  currDimension.ticks = [4 8 15 16 23 42];
            %           getAxis = currDimension.axis(1, 5);   %-- returns [23]
            %           getAxis = currDimension.axis(3, 2);   %-- returns [8 15 16]

            if (nargin < 3)
                startIndex = 1;
            end

            startIndex = nix.Utils.handleIndex(startIndex);

            fname = strcat(obj.alias, '::axis');
            r = nix_mx(fname, obj.nixhandle, count, startIndex);
        end
    end

end
