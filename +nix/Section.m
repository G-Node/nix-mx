% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Section < nix.NamedEntity
    % SECTION Metadata Section class
    %   NIX metadata section

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Section'
    end

    methods
        function obj = Section(h)
            obj@nix.NamedEntity(h);

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'repository', 'rw');

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'sections', @nix.Section);
            nix.Dynamic.add_dyn_relation(obj, 'properties', @nix.Property);
        end

        function r = parent(obj)
            r = nix.Utils.fetchObj(obj, 'parent', @nix.Section);
        end

        % ----------------
        % Link methods
        % ----------------

        function [] = set_link(obj, val)
            if (isempty(val))
                fname = strcat(obj.alias, '::setNoneLink');
                nix_mx(fname, obj.nix_handle);
            else
                nix.Utils.add_entity(obj, 'setLink', val, 'nix.Section');
            end
        end

        function r = openLink(obj)
            r = nix.Utils.fetchObj(obj, 'openLink', @nix.Section);
        end

        function r = inherited_properties(obj)
            r = nix.Utils.fetchObjList(obj, 'inheritedProperties', @nix.Property);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = create_section(obj, name, type)
            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = delete_section(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteSection', del, 'nix.Section');
        end

        function r = open_section(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openSection', id_or_name, @nix.Section);
        end

        function r = open_section_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openSectionIdx', idx, @nix.Section);
        end

        function r = has_section(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasSection', id_or_name);
        end

        function r = section_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sectionCount');
        end

        function r = filter_sections(obj, filter, val)
            r = nix.Utils.filter(obj, 'sectionsFiltered', filter, val, @nix.Section);
        end

        % find_related returns the nearest occurrence downstream of a
        % nix.Section matching the filter.
        % If no section can be found downstream, it will look for the
        % nearest occurrence upstream of a nix.Section matching the filter.
        function r = find_related(obj, filter, val)
            r = nix.Utils.filter(obj, 'findRelated', filter, val, @nix.Section);
        end

        % maxdepth is an index
        function r = find_sections(obj, max_depth)
            r = obj.find_filtered_sections(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sections(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, 'findSections', max_depth, filter, val, @nix.Section);
        end

        % ----------------
        % Property methods
        % ----------------

        function r = create_property(obj, name, datatype)
            if (~isa(datatype, 'nix.DataType'))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Please provide a valid nix.DataType';
                error(err);
            else
                fname = strcat(obj.alias, '::createProperty');
                h = nix_mx(fname, obj.nix_handle, name, lower(datatype.char));
                r = nix.Utils.createEntity(h, @nix.Property);
            end
        end

        function r = create_property_with_value(obj, name, val)
            if (~iscell(val))
                val = num2cell(val);
            end
            fname = strcat(obj.alias, '::createPropertyWithValue');
            h = nix_mx(fname, obj.nix_handle, name, val);
            r = nix.Utils.createEntity(h, @nix.Property);
        end

        function r = delete_property(obj, del)
            if (isstruct(del) && isfield(del, 'id'))
                id = del.id;
            else
                id = nix.Utils.parseEntityId(del, 'nix.Property');
            end

            fname = strcat(obj.alias, '::deleteProperty');
            r = nix_mx(fname, obj.nix_handle, id);
        end

        function r = open_property(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openProperty', id_or_name, @nix.Property);
        end

        function r = open_property_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'openPropertyIdx', idx, @nix.Property);
        end

        function r = property_count(obj)
            r = nix.Utils.fetchEntityCount(obj, 'propertyCount');
        end

        function r = filter_properties(obj, filter, val)
            r = nix.Utils.filter(obj, 'propertiesFiltered', filter, val, @nix.Property);
        end

        % ----------------
        % Referring entity methods
        % ----------------

        function r = referring_data_arrays(obj, varargin)
            r = obj.referring_util(@nix.DataArray, 'DataArrays', varargin{:});
        end

        function r = referring_tags(obj, varargin)
            r = obj.referring_util(@nix.Tag, 'Tags', varargin{:});
        end

        function r = referring_multi_tags(obj, varargin)
            r = obj.referring_util(@nix.MultiTag, 'MultiTags', varargin{:});
        end

        function r = referring_sources(obj, varargin)
            r = obj.referring_util(@nix.Source, 'Sources', varargin{:});
        end

        function r = referring_blocks(obj)
            r = nix.Utils.fetchObjList(obj, 'referringBlocks', @nix.Block);
        end
    end

    % ----------------
    % Referring utility method
    % ----------------

    methods (Access=protected)
        % referring_util receives a nix entityConstructor, part of a function
        % name and varargin to provide abstract access to nix.Section
        % referringXXX and referringXXX(Block) methods.
        function r = referring_util(obj, entityConstructor, fsuffix, varargin)
            if (isempty(varargin))
                fname = strcat('referring', fsuffix);
                r = nix.Utils.fetchObjList(obj, fname, entityConstructor);
            elseif ((size(varargin, 2) > 1) || (~isa(varargin{1}, 'nix.Block')))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Provide either empty arguments or a single Block entity';
                error(err);
            else
                fname = strcat('referringBlock', fsuffix);
                r = nix.Utils.fetchObjListByEntity(obj, fname, ...
                                            varargin{1}.nix_handle, entityConstructor);
            end
        end
    end

end
