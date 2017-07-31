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

    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'Section'
    end

    methods
        function obj = Section(h)
            obj@nix.NamedEntity(h);

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'repository', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'mapping', 'rw');

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'sections', @nix.Section);
            nix.Dynamic.add_dyn_relation(obj, 'properties', @nix.Property);
        end

        function r = parent(obj)
            fname = strcat(obj.alias, '::parent');
            h = nix_mx(fname, obj.nix_handle);
            r = {};
            if h ~= 0
                r = nix.Section(h);
            end
        end

        % ----------------
        % Link methods
        % ----------------

        function [] = set_link(obj, val)
            if (isempty(val))
                fname = strcat(obj.alias, '::setNoneLink');
                nix_mx(fname, obj.nix_handle);
            else
                if(strcmp(class(val), 'nix.Section'))
                    addID = val.id;
                else
                    addID = val;
                end

                fname = strcat(obj.alias, '::setLink');
                nix_mx(fname, obj.nix_handle, addID);
            end
        end

        function r = openLink(obj)
            fname = strcat(obj.alias, '::openLink');
            h = nix_mx(fname, obj.nix_handle);
            r = {};
            if h ~= 0
                r = nix.Section(h);
            end
        end

        function r = inherited_properties(obj)
            fname = strcat(obj.alias, '::inheritedProperties');
            r = nix.Utils.fetchObjList(fname, obj.nix_handle, @nix.Property);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = create_section(obj, name, type)
            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Section(h);
        end

        function r = delete_section(obj, del)
            fname = strcat(obj.alias, '::deleteSection');
            r = nix.Utils.delete_entity(obj, del, 'nix.Section', fname);
        end

        function r = open_section(obj, id_or_name)
            fname = strcat(obj.alias, '::openSection');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Section);
        end

        function r = open_section_idx(obj, idx)
            fname = strcat(obj.alias, '::openSectionIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Section);
        end

        function r = has_section(obj, id_or_name)
            fname = strcat(obj.alias, '::hasSection');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = section_count(obj)
            fname = strcat(obj.alias, '::sectionCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_sections(obj, filter, val)
            fname = strcat(obj.alias, '::sectionsFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Section);
        end

        % find_related returns the nearest occurrence downstream of a
        % nix.Section matching the filter.
        % If no section can be found downstream, it will look for the
        % nearest occurrence upstream of a nix.Section matching the filter.
        function r = find_related(obj, filter, val)
            fname = strcat(obj.alias, '::findRelated');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Section);
        end

        % maxdepth is an index
        function r = find_sections(obj, max_depth)
            r = obj.find_filtered_sections(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sections(obj, max_depth, filter, val)
            fname = strcat(obj.alias, '::findSections');
            r = nix.Utils.find(obj, max_depth, filter, val, fname, @nix.Section);
        end

        % ----------------
        % Property methods
        % ----------------

        function r = create_property(obj, name, datatype)
            if (~isa(datatype, 'nix.DataType'))
                error('Please provide a valid nix.DataType');
            else
                fname = strcat(obj.alias, '::createProperty');
                h = nix_mx(fname, obj.nix_handle, name, lower(datatype.char));
                r = nix.Property(h);
            end
        end

        function r = create_property_with_value(obj, name, val)
            if (~iscell(val))
                val = num2cell(val);
            end
            fname = strcat(obj.alias, '::createPropertyWithValue');
            h = nix_mx(fname, obj.nix_handle, name, val);
            r = nix.Property(h);
        end

        function r = delete_property(obj, del)
            if (isstruct(del) && isfield(del, 'id'))
                delID = del.id;
            elseif (strcmp(class(del), 'nix.Property'))
                delID = del.id;
            else
                delID = del;
            end

            fname = strcat(obj.alias, '::deleteProperty');
            r = nix_mx(fname, obj.nix_handle, delID);
        end

        function r = open_property(obj, id_or_name)
            fname = strcat(obj.alias, '::openProperty');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Property);
        end

        function r = open_property_idx(obj, idx)
            fname = strcat(obj.alias, '::openPropertyIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Property);
        end

        function r = property_count(obj)
            fname = strcat(obj.alias, '::propertyCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = filter_properties(obj, filter, val)
            fname = strcat(obj.alias, '::propertiesFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Property);
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
            fname = strcat(obj.alias, '::referringBlocks');
            r = nix.Utils.fetchObjList(fname, obj.nix_handle, @nix.Block);
        end
    end

    % ----------------
    % Referring utility method
    % ----------------

    methods(Access=protected)
        % referring_util receives a nix entityConstructor, part of a function
        % name and varargin to provide abstract access to nix.Section
        % referringXXX and referringXXX(Block) methods.
        function r = referring_util(obj, entityConstructor, fsuffix, varargin)
            if (isempty(varargin))
                fname = strcat(obj.alias, '::referring', fsuffix);
                r = nix.Utils.fetchObjList(fname, obj.nix_handle, entityConstructor);
            elseif ((size(varargin, 2) > 1) || ...
                    (~strcmp(class(varargin{1}), 'nix.Block')))
                error('Provide either empty arguments or a single Block entity');
            else
                fname = strcat(obj.alias, '::referringBlock', fsuffix);
                r = nix.Utils.fetchObjListByEntity(fname, ...
                    obj.nix_handle, varargin{1}.nix_handle, entityConstructor);
            end
        end
    end

end
