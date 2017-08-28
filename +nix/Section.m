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
            nix.Dynamic.addProperty(obj, 'repository', 'rw');

            % assign relations
            nix.Dynamic.addGetChildEntities(obj, 'sections', @nix.Section);
            nix.Dynamic.addGetChildEntities(obj, 'properties', @nix.Property);
        end

        function r = parent(obj)
            r = nix.Utils.fetchObj(obj, 'parent', @nix.Section);
        end

        % ----------------
        % Link methods
        % ----------------

        function [] = setLink(obj, val)
            if (isempty(val))
                fname = strcat(obj.alias, '::setNoneLink');
                nix_mx(fname, obj.nixhandle);
            else
                nix.Utils.addEntity(obj, 'setLink', val, 'nix.Section');
            end
        end

        function r = openLink(obj)
            r = nix.Utils.fetchObj(obj, 'openLink', @nix.Section);
        end

        function r = inheritedProperties(obj)
            r = nix.Utils.fetchObjList(obj, 'inheritedProperties', @nix.Property);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = createSection(obj, name, type)
            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = deleteSection(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteSection', del, 'nix.Section');
        end

        function r = openSection(obj, idName)
            r = nix.Utils.openEntity(obj, 'openSection', idName, @nix.Section);
        end

        function r = openSectionIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSectionIdx', idx, @nix.Section);
        end

        function r = hasSection(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasSection', idName);
        end

        function r = sectionCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sectionCount');
        end

        function r = filterSections(obj, filter, val)
            r = nix.Utils.filter(obj, 'sectionsFiltered', filter, val, @nix.Section);
        end

        % findRelated returns the nearest occurrence downstream of a
        % nix.Section matching the filter.
        % If no section can be found downstream, it will look for the
        % nearest occurrence upstream of a nix.Section matching the filter.
        function r = findRelated(obj, filter, val)
            r = nix.Utils.filter(obj, 'findRelated', filter, val, @nix.Section);
        end

        % maxDepth is handled like an index
        function r = findSections(obj, maxDepth)
            r = obj.FilterFindSections(maxDepth, nix.Filter.acceptall, '');
        end

        % maxDepth is handled like an index
        function r = FilterFindSections(obj, maxDepth, filter, val)
            r = nix.Utils.find(obj, 'findSections', maxDepth, filter, val, @nix.Section);
        end

        % ----------------
        % Property methods
        % ----------------

        function r = createProperty(obj, name, datatype)
            if (~isa(datatype, 'nix.DataType'))
                err.identifier = 'NIXMX:InvalidArgument';
                err.message = 'Please provide a valid nix.DataType';
                error(err);
            else
                fname = strcat(obj.alias, '::createProperty');
                h = nix_mx(fname, obj.nixhandle, name, lower(datatype.char));
                r = nix.Utils.createEntity(h, @nix.Property);
            end
        end

        function r = createPropertyWithValue(obj, name, val)
            if (~iscell(val))
                val = num2cell(val);
            end
            fname = strcat(obj.alias, '::createPropertyWithValue');
            h = nix_mx(fname, obj.nixhandle, name, val);
            r = nix.Utils.createEntity(h, @nix.Property);
        end

        function r = deleteProperty(obj, del)
            if (isstruct(del) && isfield(del, 'id'))
                id = del.id;
            else
                id = nix.Utils.parseEntityId(del, 'nix.Property');
            end

            fname = strcat(obj.alias, '::deleteProperty');
            r = nix_mx(fname, obj.nixhandle, id);
        end

        function r = openProperty(obj, idName)
            r = nix.Utils.openEntity(obj, 'openProperty', idName, @nix.Property);
        end

        function r = openPropertyIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openPropertyIdx', idx, @nix.Property);
        end

        function r = propertyCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'propertyCount');
        end

        function r = filterProperties(obj, filter, val)
            r = nix.Utils.filter(obj, 'propertiesFiltered', filter, val, @nix.Property);
        end

        % ----------------
        % Referring entity methods
        % ----------------

        function r = referringDataArrays(obj, varargin)
            r = obj.referringUtil(@nix.DataArray, 'DataArrays', varargin{:});
        end

        function r = referringTags(obj, varargin)
            r = obj.referringUtil(@nix.Tag, 'Tags', varargin{:});
        end

        function r = referringMultiTags(obj, varargin)
            r = obj.referringUtil(@nix.MultiTag, 'MultiTags', varargin{:});
        end

        function r = referringSources(obj, varargin)
            r = obj.referringUtil(@nix.Source, 'Sources', varargin{:});
        end

        function r = referringBlocks(obj)
            r = nix.Utils.fetchObjList(obj, 'referringBlocks', @nix.Block);
        end
    end

    % ----------------
    % Referring utility method
    % ----------------

    methods (Access=protected)
        % referringUtil receives a nix entityConstructor, part of a function
        % name and varargin to provide abstract access to nix.Section
        % referringXXX and referringXXX(Block) methods.
        function r = referringUtil(obj, entityConstructor, fsuffix, varargin)
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
                                            varargin{1}.nixhandle, entityConstructor);
            end
        end
    end

end
