% nix.Property class contains the concrete values associated with metadata.
%
% nix.Property dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   definition (char):  read-write, additional description of the entity.
%   unit (char):        read-write, unit of the values associated with a Property.
%                         The provided unit has to be an SI unit.
%   datatype (char):    read-only, provides the datatype of the values associated 
%                         with a Property. Attribute is set when the Property is created.
%
%   info (struct):      Entity property summary. The values in this structure are detached
%                       from the entity, changes will not be persisted to the file.
%
% nix.Property dynamic child entity properties:
%   values     access to all value child entities.
%
% Property values can be set via the dynamic child entity property. When 
% values are set, they replace any previously stored values. The new values
% always have to be of a datatype supported by the Property.
%
% Example:  currProperty.values = {'last name', 'first name'};
%
% The values themselves have two properties: value and uncertainty which
% can be accessed and updated individually.
%
% Individual values can be accessed and set by their value property. A set
% value has to match the datatype of the Property.
%
% Example:  currProperty.values{1}.value                 %-- get first value of Property.
%           currProperty.values{2}.value = 'some value'  %-- set second value of Property.
%
% Each value comes with its own uncertainty property which can be accessed
% and set. NOTE: this will probably change in the near future, moving the
% uncertainty from the individual value to the level of the Property.
%
% Example:  %-- get uncertainty of first property value.
%           currProperty.values{1}.uncertainty
%           %-- set uncertainty of second property value.
%           currProperty.values{1}.uncertainty = 0.1
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Property < nix.NamedEntity

    properties (Hidden)
        alias = 'Property'  % namespace for Property nix backend function access.
    end

    properties (Dependent)
        values
    end

    methods
        function obj = Property(h)
            obj@nix.NamedEntity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'unit', 'rw');
            nix.Dynamic.addProperty(obj, 'datatype', 'r');
        end

        function r = get.values(obj)
            fname = strcat(obj.alias, '::values');
            r = nix_mx(fname, obj.nixhandle);
        end

        function [] = set.values(obj, val)
            values = val;
            if (~iscell(values))
                values = num2cell(val);
            end

            for i = 1:length(values)
                if (isstruct(values{i}))
                    curr = values{i}.value;
                else
                    curr = values{i};
                end

                if (~strcmpi(class(curr), obj.datatype))
                    err.identifier = 'NIXMX:InvalidArgument';
                    err.message = sprintf('Value #%d does not match property data type', i);
                    error(err);
                end
            end

            fname = strcat(obj.alias, '::updateValues');
            nix_mx(fname, obj.nixhandle, values);
        end

        function r = valueCount(obj)
            % Get the number of the child values of the invoking Property.
            %
            % Returns:  (uint) The number of child values.
            %
            % Example:  vc = currProperty.valueCount();

            r = nix.Utils.fetchEntityCount(obj, 'valueCount');
        end

        function [] = deleteValues(obj)
            % Deletes all values from the invoking Property.
            %
            % Example:  check = currProperty.deleteValues();

            fname = strcat(obj.alias, '::deleteValues');
            nix_mx(fname, obj.nixhandle);
        end
    end

end
