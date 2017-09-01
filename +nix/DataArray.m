% nix.DataArray class that can store arbitrary n-dimensional data
% along with further information.
%
% The DataArray is the core entity of the NIX data model, its purpose is to store 
% arbitrary n-dimensional data. In addition to the common fields id, name, type, 
% and definition the DataArray stores sufficient information to understand the 
% physical nature of the stored data.
%
% A guiding principle of the data model is to provide enough information to create a 
% plot of the stored data. In order to do so, the DataArray defines a property dataType 
% which provides the physical type of the stored data (for example 16 bit integer or 
% double precision IEEE floatingpoint number). The property unit specifies the SI unit 
% of the values stored in the DataArray whereas the label defines what is given in this 
% units. Together, both specify what corresponds to the the y-axis of a plot.
%
% In some cases it is much more efficient or convenient to store data not as floating 
% point numbers but rather as (16 bit) integer values as, for example, read from a data 
% acquisition board. In order to convert such data to the correct values, we follow the 
% approach taken by the comedi data-acquisition library (http://www.comedi.org) and 
% provide polynomCoefficients and an expansionOrigin.
%
% A DataArray can only be created from a Block entity. Do not use the
% DataArray constructor.
%
% DataArray supports only the storage of numeric and logical data.
%
% nix.DataArray dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                          entity and expose it to search methods in a broader context.
%   definition (char):  read-write, optional description of the entity.
%   label (char):       read-write, optional label of the raw data for plotting.
%   unit (char):        read-write, optional unit of the raw data.
%                          Supports only SI units.
%   expansionOrigin (double):      read-write, the expansion origin of the 
%                                     calibration polynom. 0.0 by default.
%   polynomCoefficients (double):  read-write, The polynom coefficients for the 
%                                     calibration. By default this is set to a 
%                                  {0.0, 1.0} for a linear calibration with zero offset.
%   dataExtent ([double]):         read-write, the size of the raw data.
%                                     The size of a DataArray can be changed with this 
%                                  property, but only within the original dimensionality, 
%                                  e.g. a 2D array must always remain a 2D array, but 
%                                  can be modified in either of the two dimensions.
%
%   info (struct):  Entity property summary. The values in this structure are detached
%                   from the entity, changes will not be persisted to the file.
%
% nix.DataArray dynamic child entity properties:
%   dimensions   access to all dimensions associated with a DataArray.
%   sources      access to all first level nix.Source child entities.
%
% See also nix.Source, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef DataArray < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn

    properties (Hidden)
        alias = 'DataArray'  % namespace for DataArray nix backend function access.
    end

    properties (Dependent)
        dimensions % should not be dynamic due to complex set operation.
    end

    methods
        function obj = DataArray(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'label', 'rw');
            nix.Dynamic.addProperty(obj, 'unit', 'rw');
            nix.Dynamic.addProperty(obj, 'expansionOrigin', 'rw');
            nix.Dynamic.addProperty(obj, 'polynomCoefficients', 'rw');
            nix.Dynamic.addProperty(obj, 'dataExtent', 'rw');
        end

        % -----------------
        % Dimensions
        % -----------------

        function dimensions = get.dimensions(obj)
            % Get all Dimensions associated with this DataArray.
            %
            % Returns:  ([nix.Dimension]) A list of all associated Dimensions.
            %
            % Example:  dims = currDataArray.dimensions;
            %
            % See also nix.RangeDimension, nix.SampledDimension, nix.SetDimension.

            dimensions = {};
            fname = strcat(obj.alias, '::dimensions');
            currList = nix_mx(fname, obj.nixhandle);
            for i = 1:length(currList)
                switch currList(i).dtype
                    case 'set'
                        dimensions{i} = nix.Utils.createEntity(currList(i).dimension, ...
                            @nix.SetDimension);
                    case 'sample'
                        dimensions{i} = nix.Utils.createEntity(currList(i).dimension, ...
                            @nix.SampledDimension);
                    case 'range'
                        dimensions{i} = nix.Utils.createEntity(currList(i).dimension, ...
                            @nix.RangeDimension);
                    otherwise
                       disp('some dimension type is unknown! skip');
                end
            end
        end

        function r = appendSetDimension(obj)
            % Append a new SetDimension as last entry to the list of existing 
            % dimension descriptors of the invoking DataArray.
            %
            % Used to provide labels for dimensionless data e.g. when stacking 
            % different signals. In the example the first dimension would
            % describe the measured unit, the second dimension the time,
            % the third dimension would provide labels for three different
            % signals measured within the same experiment and packed into
            % the same 3D DataArray.
            %
            % Returns:  (nix.SetDimension) The newly created SetDimension.
            %
            % Example:  dim = currDataArray.appendSetDimension();
            %
            % See also nix.SetDimension.

            fname = strcat(obj.alias, '::appendSetDimension');
            h = nix_mx(fname, obj.nixhandle);
            r = nix.Utils.createEntity(h, @nix.SetDimension);
        end

        function r = appendSampledDimension(obj, interval)
            % Append a new SampledDimension as last entry to the list of 
            % existing dimension descriptors of the invoking DataArray.
            %
            % Used to describe the regularly sampled dimension of data.
            %
            % interval (double):  The sampling interval of the Dimension to create.
            %
            % Returns:  (nix.SampledDimension) The newly created SampledDimension.
            %
            % Example:  stepSize = 5;
            %           dim = currDataArray.appendSampledDimension(stepSize);
            %
            % See also nix.SampledDimension.

            fname = strcat(obj.alias, '::appendSampledDimension');
            h = nix_mx(fname, obj.nixhandle, interval);
            r = nix.Utils.createEntity(h, @nix.SampledDimension);
        end

        function r = appendRangeDimension(obj, ticks)
            % Append a new SampledDimension as last entry to the list of 
            % existing dimension descriptors of the invoking DataArray.
            %
            % Used to describe the irregularly sampled dimension of data.
            %
            % ticks ([double]):  The ticks of the RangeDimension.
            %
            % Returns:  (nix.RangeDimension) The newly created RangeDimension.
            %
            % Example:  dim = currDataArray.appendRangeDimension([1 10 21 15]);
            %
            % See also nix.SampledDimension.

            fname = strcat(obj.alias, '::appendRangeDimension');
            h = nix_mx(fname, obj.nixhandle, ticks);
            r = nix.Utils.createEntity(h, @nix.RangeDimension);
        end

        function r = appendAliasRangeDimension(obj)
            % Append a new RangeDimension that uses the data stored in the invoking 
            % DataArray as ticks.
            % This works only(!) if the DataArray is 1D and the stored data is numeric.
            %
            % Returns:  (nix.RangeDimension) The newly created RangeDimension.
            %
            % Example:  dim = currDataArray.appendAliasRangeDimension();
            %
            % See also nix.RangeDimension.

            fname = strcat(obj.alias, '::appendAliasRangeDimension');
            h = nix_mx(fname, obj.nixhandle);
            r = nix.Utils.createEntity(h, @nix.RangeDimension);
        end

        function r = openDimensionIdx(obj, idx)
            % Returns the Dimension entity for the specified dimension of the data.
            %
            % idx (double):  The index of the respective Dimension.
            %
            % Returns:  (nix.Dimension) The corresonding Dimension.
            %
            % Example:  dim = currDataArray.openDimensionIdx(2);
            %
            % See also nix.RangeDimension, nix.SampledDimension, nix.SetDimension.

            fname = strcat(obj.alias, '::openDimensionIdx');
            dim = nix_mx(fname, obj.nixhandle, idx);
            switch (dim.dimensionType)
                case 'set'
                    r = nix.Utils.createEntity(dim.handle, @nix.SetDimension);
                case 'sampled'
                    r = nix.Utils.createEntity(dim.handle, @nix.SampledDimension);
                case 'range'
                    r = nix.Utils.createEntity(dim.handle, @nix.RangeDimension);
            end
        end

        function r = deleteDimensions(obj)
            % Remove all Dimensions from the invoking DataArray.
            %
            % Returns:  (logical) True if the Dimensions were removed,
            %                       False otherwise.
            %
            % Example:  check = currDataArray.deleteDimensions();

            fname = strcat(obj.alias, '::deleteDimensions');
            r = nix_mx(fname, obj.nixhandle);
        end

        function r = dimensionCount(obj)
            % Get the number of nix.Dimensions associated with the invoking DataArray.
            %
            % Returns:  (uint) The number of Dimensions.
            %
            % Example:  dc = currDataArray.dimensionCount();

            r = nix.Utils.fetchEntityCount(obj, 'dimensionCount');
        end

        % -----------------
        % Data access methods
        % -----------------

        function r = readAllData(obj)
            % Returns an array with the complete raw data stored in the 
            % DataArray.
            %
            % The returned data is read-only, changes will not be written to file.
            %
            % Returns:  (var) The complete raw data.
            %
            % Example:  data = currDataArray.readAllData();

            fname = strcat(obj.alias, '::readAll');
            data = nix_mx(fname, obj.nixhandle);
            r = nix.Utils.transposeArray(data);
        end

        %-- TODO add (optional) offset
        %-- If a DataArray has been created as boolean or numeric,
        %-- provide that only values of the proper DataType can be written.
        function [] = writeAllData(obj, data)
            % Writes raw data to the invoking DataArray.
            %
            % DataType and extent of the written data has to 
            % match the invoking DataArray.
            %
            % Example:  dataSet = ones(15, 15, 15);
            %           currDataArray.writeAllData(dataSet);

            if (isinteger(obj.readAllData) && isfloat(data))
                disp('Warning: Writing Float data to an Integer DataArray');
            end

            err.identifier = 'NIXMX:improperDataType';
            if (islogical(obj.readAllData) && ~islogical(data))
                m = sprintf('Trying to write %s to a logical DataArray', class(data));
                err.message = m;
                error(err);
            elseif (isnumeric(obj.readAllData) && ~isnumeric(data))
                m = sprintf('Trying to write %s to a %s DataArray', ...
                    class(data), class(obj.readAllData));
                err.message = m;
                error(err);
            elseif (ischar(data))
                %-- Should actually not be reachable at the moment, 
                %-- since writing Strings to DataArrays is not supported,
                %-- but safety first.
                err.identifier = 'NIXMX:unsupportedDataType';
                err.message = 'Writing char/string DataArrays is currently not supported.';
                error(err);
            end

            fname = strcat(obj.alias, '::writeAll');
            nix_mx(fname, obj.nixhandle, nix.Utils.transposeArray(data));
        end

        function r = datatype(obj)
            % Returns the datatype of the data stored by the invoking DataArray.
            %
            % Example:  dt = currDataArray.datatype;

            fname = strcat(obj.alias, '::dataType');
            r = nix_mx(fname, obj.nixhandle);
        end

        function [] = setDataExtent(obj, extent)
            % Change the shape of the invoking DataArray.
            %
            % Set data extent enables to increase the original size 
            % of a DataArray within the same dimensions.
            % e.g. increase the size of a 2D array [5 10] to another
            % 2D array [5 11]. Changing the dimensions is not possible
            % e.g. changing from a 2D array to a 3D array.
            % Furthermore if the extent shrinks the size of an array
            % or remodels the size of an array to a completely different
            % shape, existing data that does not fit into the new shape
            % will be lost!
            %
            % extent ([double]):  shape of the DataArray.
            %
            % Example:  currDataArray.setDataExtent([12 15]);

            fname = strcat(obj.alias, '::setDataExtent');
            nix_mx(fname, obj.nixhandle, extent);
        end
    end

end
