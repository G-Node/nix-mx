% nix.Section class provides the elaborate connection of data with metadata
% e.g. background information about the experiment that produced the data 
% stored in a nix.DataArray.
%
% Almost all entities allow to attach arbitray metadata. The basic concept of the 
% metadata model is that Properties are organized in Sections which in turn can be 
% nested to represent hierarchical structures. The Sections basically act like Python 
% dictionaries.
%
% Sections can be nested to create a metadata tree to reflect and document
% even complicated experimental settings. Each of the NIX entities nix.Block,
% nix.Group, nix.DataArray, nix.Source, nix.Tag and nix.MultiTag can
% reference one nix.Section to connect data to metadata and provide
% detailed provenance for experimental settings.
%
% Nested nix.Sections are used to reflect experimental settings as an abstract tree
% like structure, while the concrete information is stored in nix.Properties
% as children of the individual nix.Sections.
%
% nix.Section dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, additional description of the entity.
%   repository (char):  read-write, repository can be used to provide a uri to a 
%                         repository where the semantic definition of the current 
%                         Section can be found.
%
%   info (struct):      Entity property summary. The values in this structure are detached
%                       from the entity, changes will not be persisted to the file.
%
% nix.Section dynamic child entity properties:
%   sections     access to all direct nix.Section child entities.
%   properties   access to all nix.Property child entities.
%
% See also nix.Property, nix.Block, nix.Group, nix.DataArray, nix.Source, 
% nix.Tag, nix.MultiTag.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Section < nix.NamedEntity

    properties (Hidden)
        alias = 'Section'  % namespace for Section nix backend function access.
    end

    methods
        function obj = Section(h)
            obj@nix.NamedEntity(h);

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'repository', 'rw');

            % assign child entities
            nix.Dynamic.addGetChildEntities(obj, 'sections', @nix.Section);
            nix.Dynamic.addGetChildEntities(obj, 'properties', @nix.Property);
        end

        function r = parent(obj)
            % Returns the parent Section of the invoking Section.
            %
            % Returns:  (nix.Section) The parent Section if there is any, 
            %                         an empty cell array otherwise.
            %
            % Example:  getSection = currSection.parent();

            r = nix.Utils.fetchObj(obj, 'parent', @nix.Section);
        end

        % ----------------
        % Link methods
        % ----------------

        function [] = setLink(obj, idEntity)
            % Establish a link between another Section and the invoking Section.
            %
            % The linking Section inherits the Properties defined in the linked Section.
            % Properties of the same name are overridden.
            %
            % The link to a Section can be removed by handing an empty string 
            % to the method. The linked Section itself will not be removed.
            %
            % idEntity (char/nix.Section):  The id of an existing Section,
            %                                 or a valid nix.Section entity.  
            %
            % Example:  currSection.setLink('some-section-id');
            %           currFile.sections{1}.setLink(otherSectionEntity);
            %           currSection.setLink('');  %-- remove Section link.
            %
            % See also nix.Property.

            if (isempty(idEntity))
                fname = strcat(obj.alias, '::setNoneLink');
                nix_mx(fname, obj.nixhandle);
            else
                nix.Utils.addEntity(obj, 'setLink', idEntity, 'nix.Section');
            end
        end

        function r = openLink(obj)
            % Retrieves the linked nix.Section from the invoking Section.
            %
            % Returns:  (nix.Section) The linked Section or an empty cell, 
            %                         if no Section was linked.
            %
            % Example:  getSection = currSection.openLink();

            r = nix.Utils.fetchObj(obj, 'openLink', @nix.Section);
        end

        function r = inheritedProperties(obj)
            % Returns all nix.Properties that the invoking Section has
            % inherited from another linked Section.
            %
            % This list may include Properties that are locally overridden.
            %
            % Returns:  ([nix.Property]) Cell array of all Properties inherited from 
            %                            one other Section that is linked to the
            %                            invoking Section.
            %
            % Example:  getProperties = currSection.inheritedProperties();
            %
            % See also nix.Property.

            r = nix.Utils.fetchObjList(obj, 'inheritedProperties', @nix.Property);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = createSection(obj, name, type)
            % Create a new nix.Section entity as child of the invoking Section.
            %
            % name (char):  The name of the Section, has to be unique within the file.
            % type (char):  The type of the Section, required.
            %               Type can be used to give semantic meaning to an entity
            %               and expose it to search methods in a broader context.
            %
            % Returns:  (nix.Section) The newly created Section.
            %
            % Example:  newSection = currSection.createSection(...
            %                                       'electrode_array', 'electrode');

            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = deleteSection(obj, idNameEntity)
            % Deletes a Section from the invoking Section.
            %
            % When a Section is deleted, all of its child Sections, Properties and 
            % Values will be deleted from the file as well.
            %
            % idNameEntity (char/nix.Section):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Section has been removed, false otherwise.
            %
            % Example:  check = currSection.deleteSection('23bb8a99-1812-4bc6-a52c');
            %           check = currSection.deleteSection('electrode_array');
            %           check = currFile.sections{1}.deleteSection(newSectionEntity);

            r = nix.Utils.deleteEntity(obj, 'deleteSection', idNameEntity, 'nix.Section');
        end

        function r = openSection(obj, idName)
            % Retrieves an existing direct child Section from the invoking Section.
            %
            % idName (char):  Name or ID of the Section.
            %
            % Returns:  (nix.Section) The nix.Section or an empty cell, 
            %                         if the Section was not found.
            %
            % Example:  getSec = currSection.openSection('some-section-id');
            %           getSec = currFile.sections{1}.openSection('electrode_array');

            r = nix.Utils.openEntity(obj, 'openSection', idName, @nix.Section);
        end

        function r = openSectionIdx(obj, index)
            % Retrieves an Section from the invoking Section, accessed by index.
            %
            % index (double):  The index of the Section to read.
            %
            % Returns:  (nix.Section) The Section at the given index.
            %
            % Example:  getSec = currSection.openSectionIdx(1);

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSectionIdx', idx, @nix.Section);
        end

        function r = hasSection(obj, idName)
            % Check if a Section exists as a direct child of the invoking Section.
            %
            % idName (char):  Name or ID of the Section.
            %
            % Returns:  (logical) True if the Section exists, false otherwise.
            %
            % Example:  check = currSection.hasSection('some-section-id');
            %           check = currFile.sections{2653}.hasSection('settings1');

            r = nix.Utils.fetchHasEntity(obj, 'hasSection', idName);
        end

        function r = sectionCount(obj)
            % Get the number of direct child Sections of the invoking Section.
            %
            % Returns:  (uint) The number of direct child (non nested) Sections.
            %
            % Example:  sc = currSection.sectionCount();

            r = nix.Utils.fetchEntityCount(obj, 'sectionCount');
        end

        function r = filterSections(obj, filter, val)
            % Get a filtered cell array of all child Sections of the invoking Section.
            %
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       The filters 'acceptall', 'id', 'ids',
            %                       'name' and 'type'.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Section]) A cell array of Sections filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getSecs = currSection.filterSections(nix.Filter.type, 'ephys');
            %
            % See also nix.Filter.

            r = nix.Utils.filter(obj, 'sectionsFiltered', filter, val, @nix.Section);
        end

        function r = findRelated(obj, filter, val)
            % Returns the nearest occurrence of a nix.Section from the
            % invoking Section matching the provided nix.Filter.
            %
            % The function first searches downstream of the invoking Section for a 
            % Section matching the provided nix.Filter. If no Section can be found 
            % downstream, it will look for the nearest occurrence upstream of the 
            % invoking Section for a match.
            %
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       The filters 'acceptall', 'id', 'ids',
            %                       'name' and 'type'.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  (nix.Section) The first Section matching the provided nix.Filter.
            %
            % Example:  getSection = currSection.findRelated(nix.Filter.type, 'ephys');
            %
            % See also nix.Filter.

            r = nix.Utils.filter(obj, 'findRelated', filter, val, @nix.Section);
        end

        function r = findSections(obj, maxDepth)
            % Get all Sections and their child Sections of the 
            % invoking Section recursively.
            %
            % This method traverses the trees of all Sections of the invoking Section
            % and adds all Sections to the resulting cell array, until the maximum depth
            % of the nested Sections has been reached. The traversal is accomplished via
            % breadth first and adds the Sections accordingly.
            %
            % maxDepth (double):  The maximum depth of traversal to retrieve nested 
            %                     Sections. Should be handled like an index.
            %
            % Example:  allSec = currSection.findSections(2);
            %           % will add all Sections until including the 2nd layer of Sections.

            r = obj.filterFindSections(maxDepth, nix.Filter.acceptall, '');
        end

        function r = filterFindSections(obj, maxDepth, filter, val)
            % Get all Sections of the invoking Section recursively.
            %
            % This method traverses the trees of all Sections of the invoking Section.
            % The traversal is accomplished via breadth first and can be limited in depth.
            % On each node or Section a nix.Filter is applied. If the filter returns true,
            % the respective Section will be added to the result list.
            %
            % maxDepth (double):    The maximum depth of traversal to retrieve nested 
            %                       Sections. Should be handled like an index.
            % filter (nix.Filter):  The nix.Filter to be applied. Supports the filters 
            %                       'acceptall', 'id', 'ids', 'name' and 'type'.
            % val (char):           Value that is applied with the selected filter.
            %
            % Example:  allSec = currSection.filterFindSections(...
            %                                               2, nix.Filter.type, 'ephys');
            %
            % See also nix.Filter.

            r = nix.Utils.find(obj, 'findSections', maxDepth, filter, val, @nix.Section);
        end

        % ----------------
        % Property methods
        % ----------------

        function r = createProperty(obj, name, datatype)
            % Creates a nix.Property without values as child of the invoking Section.
            %
            % name (char):              Name of the added Property.
            % datatype (nix.DataType):  Valid nix.DataType of the added Property.
            %
            % Returns:  (nix.Property) The created Property.
            %
            % Example:  newProperty = currSection.createProperty(...
            %                                         'condition', nix.DataType.String);
            %
            % See also nix.Property, nix.DataType.

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
            % Creates a nix.Property as child of the invoking Section.
            %
            % name (char):     Name of the added Property.
            % val (variable):  Cell array of values of the same type. The
            %                  data type of the values will be inferred automatically.
            %
            % Returns:  (nix.Property) The created Property.
            %
            % Example:  newProperty = currSection.createProperty(...
            %                               'Experimenter', {'First name', 'Last name'});
            %
            % See also nix.Property, nix.DataType.

            if (~iscell(val))
                val = num2cell(val);
            end
            fname = strcat(obj.alias, '::createPropertyWithValue');
            h = nix_mx(fname, obj.nixhandle, name, val);
            r = nix.Utils.createEntity(h, @nix.Property);
        end

        function r = deleteProperty(obj, idNameEntity)
            % Deletes a nix.Property from the invoking Section.
            %
            % When a Property is deleted, all of its Values will be deleted as well.
            %
            % idNameEntity (char/nix.Property):  Name or id of the entity to
            %                                    be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Property has been removed, false otherwise.
            %
            % Example:  check = currSection.deleteProperty('some-property-id-101');
            %           check = currSection.deleteProperty('condition');
            %           check = currFile.sections{1}.deleteProperty(newPropertyEntity);
            %
            % See also nix.Property.

            r = nix.Utils.deleteEntity(obj, 'deleteProperty', idNameEntity, 'nix.Property');
        end

        function r = openProperty(obj, idName)
            % Retrieves a nix.Property from the invoking Section.
            %
            % idName (char):  Name or ID of the Property.
            %
            % Returns:  (nix.Property) The Property or an empty cell, 
            %                          if the Property was not found.
            %
            % Example:  getProperty = currSection.openProperty('some-property-id');
            %           getProperty = currFile.sections{1}.openProperty('condition');
            %
            % See also nix.Property.

            r = nix.Utils.openEntity(obj, 'openProperty', idName, @nix.Property);
        end

        function r = openPropertyIdx(obj, index)
            % Retrieves a nix.Property from the invoking Section, accessed by index.
            %
            % index (double):  The index of the Property to read.
            %
            % Returns:  (nix.Property) The Property at the given index.
            %
            % Example:  getProperty = currSection.openPropertyIdx(1);
            %
            % See also nix.Property.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openPropertyIdx', idx, @nix.Property);
        end

        function r = propertyCount(obj)
            % Get the number of the child nix.Properties of the invoking Section.
            %
            % Returns:  (uint) The number of child Properties.
            %
            % Example:  pc = currSection.propertyCount();
            %
            % See also nix.Property.

            r = nix.Utils.fetchEntityCount(obj, 'propertyCount');
        end

        function r = filterProperties(obj, filter, val)
            % Get a filtered cell array of all child Properties of the invoking Section.
            %
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       filters 'acceptall', 'id', 'ids' and 'name'. 
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Property]) A cell array of Properties filtered according
            %                            to the applied nix.Filter.
            %
            % Example:  getProperties = currSection.filterProperties(...
            %                                           nix.Filter.name, 'condition');
            %
            % See also nix.Property, nix.Filter.

            r = nix.Utils.filter(obj, 'propertiesFiltered', filter, val, @nix.Property);
        end

        % ----------------
        % Referring entity methods
        % ----------------

        function r = referringDataArrays(obj, varargin)
            % Returns all nix.DataArrays which reference the invoking Section.
            %
            % varargin (empty/nix.Block):  If the argument is empty, the search will be 
            %                              performed in the while file. If a nix.Block 
            %                              entity is provided, the search will be 
            %                              performed only in the provided Block.
            %
            % Returns:  ([nix.DataArray]) A cell array of all DataArray entities
            %                             referring to the invoking Section.
            %
            % Example:
            %   % get all DataArrays in the file referenced by currSection.
            %   getDataArrays = currSection.referringDataArrays();
            %
            %   % get all DataArrays in Block blockEntity referenced by currSection.
            %   getDataArrays = currSection.referringDataArrays(blockEntity);
            %
            % See also nix.Block, nix.DataArray.

            r = obj.referringUtil(@nix.DataArray, 'DataArrays', varargin{:});
        end

        function r = referringTags(obj, varargin)
            % Returns all nix.Tags which reference the invoking Section.
            %
            % varargin (empty/nix.Block):  If the argument is empty, the search will be 
            %                              performed in the while file. If a nix.Block 
            %                              entity is provided, the search will be 
            %                              performed only in the provided Block.
            %
            % Returns:  ([nix.Tag]) A cell array of all Tag entities
            %                       referring to the invoking Section.
            %
            % Example:
            %   % get all Tags in the file referenced by currSection.
            %   getTags = currSection.referringTags();
            %
            %   % get all Tags in Block blockEntity referenced by currSection.
            %   getTags = currSection.referringTags(blockEntity);
            %
            % See also nix.Block, nix.Tag.

            r = obj.referringUtil(@nix.Tag, 'Tags', varargin{:});
        end

        function r = referringMultiTags(obj, varargin)
            % Returns all nix.MultiTags which reference the invoking Section.
            %
            % varargin (empty/nix.Block):  If the argument is empty, the search will be 
            %                              performed in the while file. If a nix.Block 
            %                              entity is provided, the search will be 
            %                              performed only in the provided Block.
            %
            % Returns:  ([nix.MultiTag]) A cell array of all MultiTag entities
            %                            referring to the invoking Section.
            %
            % Example:
            %   % get all MultiTags in the file referenced by currSection.
            %   getMultiTags = currSection.referringMultiTags();
            %
            %   % get all MultiTags in Block blockEntity referenced by currSection.
            %   getMultiTags = currSection.referringMultiTags(blockEntity);
            %
            % See also nix.Block, nix.MultiTag.

            r = obj.referringUtil(@nix.MultiTag, 'MultiTags', varargin{:});
        end

        function r = referringSources(obj, varargin)
            % Returns all nix.Sources which reference the invoking Section.
            %
            % varargin (empty/nix.Block):  If the argument is empty, the search will be 
            %                              performed in the while file. If a nix.Block 
            %                              entity is provided, the search will be 
            %                              performed only in the provided Block.
            %
            % Returns:  ([nix.Source]) A cell array of all Source entities
            %                          referring to the invoking Section.
            %
            % Example:
            %   % get all Sources in the file referenced by currSection.
            %   getSources = currSection.referringSources();
            %
            %   % get all Sources in Block blockEntity referenced by currSection.
            %   getSources = currSection.referringSources(blockEntity);
            %
            % See also nix.Block, nix.Source.

            r = obj.referringUtil(@nix.Source, 'Sources', varargin{:});
        end

        function r = referringBlocks(obj)
            % Returns all nix.Blocks which reference the invoking Section.
            %
            % Returns:  ([nix.Block]) A cell array of all Block entities
            %                         referring to the invoking Section.
            %
            % Example:  getBlocks = currSection.referringBlocks();
            %
            % See also nix.Block.

            r = nix.Utils.fetchObjList(obj, 'referringBlocks', @nix.Block);
        end
    end

    % ----------------
    % Referring utility method
    % ----------------

    methods (Access=protected)
        function r = referringUtil(obj, entityConstructor, fsuffix, varargin)
            % Provides abstract access to nix.Section referringXXX and
            % referringXXX(nix.Block) methods.
            %
            % entityConstructor (nix.Entity constructor)
            % fsuffic (char)
            % varargin (empty/nix.Block)
            %
            % Returns:  ([nix.Entity])
            %
            % Utility function, do not use out of context.

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
