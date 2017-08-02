% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef DataArray < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    %DataArray nix DataArray object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'DataArray'
    end

    properties (Dependent)
        dimensions % should not be dynamic due to complex set operation
    end

    methods
        function obj = DataArray(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'label', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'unit', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'expansionOrigin', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'polynomCoefficients', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'dataExtent', 'rw');
        end

        % -----------------
        % Dimensions
        % -----------------

        function dimensions = get.dimensions(obj)
            dimensions = {};
            fname = strcat(obj.alias, '::dimensions');
            currList = nix_mx(fname, obj.nix_handle);
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
                       disp('some dimension type is unknown! skip')
                end
            end
        end

        function r = append_set_dimension(obj)
            fname = strcat(obj.alias, '::appendSetDimension');
            h = nix_mx(fname, obj.nix_handle);
            r = nix.Utils.createEntity(h, @nix.SetDimension);
        end

        function r = append_sampled_dimension(obj, interval)
            fname = strcat(obj.alias, '::appendSampledDimension');
            h = nix_mx(fname, obj.nix_handle, interval);
            r = nix.Utils.createEntity(h, @nix.SampledDimension);
        end

        function r = append_range_dimension(obj, ticks)
            fname = strcat(obj.alias, '::appendRangeDimension');
            h = nix_mx(fname, obj.nix_handle, ticks);
            r = nix.Utils.createEntity(h, @nix.RangeDimension);
        end

        function r = append_alias_range_dimension(obj)
            fname = strcat(obj.alias, '::appendAliasRangeDimension');
            h = nix_mx(fname, obj.nix_handle);
            r = nix.Utils.createEntity(h, @nix.RangeDimension);
        end

        function r = open_dimension_idx(obj, idx)
        % Getting the dimension by index starts with 1
        % instead of 0 compared to all other index functions.
            fname = strcat(obj.alias, '::openDimensionIdx');
            dim = nix_mx(fname, obj.nix_handle, idx);
            switch (dim.dimension_type)
                case 'set'
                    r = nix.Utils.createEntity(dim.handle, @nix.SetDimension);
                case 'sampled'
                    r = nix.Utils.createEntity(dim.handle, @nix.SampledDimension);
                case 'range'
                    r = nix.Utils.createEntity(dim.handle, @nix.RangeDimension);
            end
        end

        function r = delete_dimensions(obj)
            fname = strcat(obj.alias, '::deleteDimensions');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = dimension_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'dimensionCount');
        end

        % -----------------
        % Data access methods
        % -----------------

        function r = read_all(obj)
            fname = strcat(obj.alias, '::readAll');
            data = nix_mx(fname, obj.nix_handle);
            r = nix.Utils.transpose_array(data);
        end

        %-- TODO add (optional) offset
        %-- If a DataArray has been created as boolean or numeric,
        %-- provide that only values of the proper DataType can be written.
        function [] = write_all(obj, data)
            if (isinteger(obj.read_all) && isfloat(data))
                disp('Warning: Writing Float data to an Integer DataArray');
            end

            err.identifier = 'DataArray:improperDataType';
            if (islogical(obj.read_all) && ~islogical(data))
                m = sprintf('Trying to write %s to a logical DataArray', class(data));
                err.message = m;
                error(err);
            elseif (isnumeric(obj.read_all) && ~isnumeric(data))
                m = sprintf('Trying to write %s to a %s DataArray', class(data), class(obj.read_all));
                err.message = m;
                error(err);
            elseif (ischar(data))
                %-- Should actually not be reachable at the moment, 
                %-- since writing Strings to DataArrays is not supported,
                %-- but safety first.
                err.identifier = 'DataArray:unsupportedDataType';
                err.message = 'Writing char/string DataArrays is currently not supported.';
                error(err);
            end

            fname = strcat(obj.alias, '::writeAll');
            nix_mx(fname, obj.nix_handle, nix.Utils.transpose_array(data));
        end

        function r = datatype(obj)
            fname = strcat(obj.alias, '::dataType');
            r = nix_mx(fname, obj.nix_handle);
        end

        % Set data extent enables to increase the original size 
        % of a data array within the same dimensions.
        % e.g. increase the size of a 2D array [5 10] to another
        % 2D array [5 11]. Changing the dimensions is not possible
        % e.g. changing from a 2D array to a 3D array.
        % Furthermore if the extent shrinks the size of an array
        % or remodels the size of an array to a completely different
        % shape, existing data that does not fit into the new shape
        % will be lost!
        function [] = set_data_extent(obj, extent)
            fname = strcat(obj.alias, '::setDataExtent');
            nix_mx(fname, obj.nix_handle, extent);
        end
    end

end
