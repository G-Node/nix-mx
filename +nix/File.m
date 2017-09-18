% nix.File class grants access to all NIX operations.
%
% A File represents a specific data source of a NIX back-end for example an NIX HDF5 file.
% All entities of the nix data model (except the Value entity) must exist in the context 
% of an open File object. Therefore NIX entities cannot be initialized via their 
% constructors but only through the factory methods of their respective parent entity.
%
% When a file variable is cleared, the handle to the file will be automatically closed.
%
% nix.File dynamic properties:
%   info (struct):  Entity property summary. The values in this structure are detached
%                   from the entity, changes will not be persisted to the file.
%
% nix.File dynamic child entity properties:
%   blocks      access to all nix.Block child entities.
%   sections    access to all first level nix.Section child entities.
%
% Example opening a NIX file:
%   getFileAccess = nix.File('/path/to/file', nix.FileMode.ReadWrite);
%
% See also nix.Block, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef File < nix.Entity

    properties (Hidden)
        alias = 'File'  % namespace for File nix backend function access.
    end

    methods
        function obj = File(path, mode)
            % File constructor used to open or create a nix.File.
            %
            % path (char):  Path to a file to open or create.
            % mode (char):  Requires a valid nix.FileMode. Defaults to 
            %               nix.FileMode.ReadWrite if no FileMode is provided.
            %
            % Returns: (nix.File).
            %
            % Example:  getFileAccess = nix.File('/path/to/file', nix.FileMode.ReadWrite);
            %
            % See also nix.FileMode.

            if (~exist('mode', 'var'))
                mode = nix.FileMode.ReadWrite; % default to ReadWrite
            end
            h = nix_mx('File::open', path, mode); 
            obj@nix.Entity(h);

            % assign child entites
            nix.Dynamic.addGetChildEntities(obj, 'blocks', @nix.Block);
            nix.Dynamic.addGetChildEntities(obj, 'sections', @nix.Section);
        end

        % braindead...
        function r = isOpen(obj)
            % Check if the file is currently open.
            %
            % Returns:  (logical) True if the file is open, False otherwise.
            %
            % Example:  check = currFile.isOpen();

            fname = strcat(obj.alias, '::isOpen');
            r = nix_mx(fname, obj.nixhandle);
        end

        function r = fileMode(obj)
            % Get the mode in which the file has been opened.
            %
            % Returns: (nix.FileMode).
            %
            % Example:  getFileMode = currFile.fileMode();
            %
            % See also nix.FileMode.

            fname = strcat(obj.alias, '::fileMode');
            r = nix_mx(fname, obj.nixhandle);
        end

        function r = validate(obj)
            % Runs a backend validator over all contained entities and returns a
            % custom struct with warnings and error messages, if the current content
            % of the file violates the NIX datamodel as well as the ids of the 
            % offending entities.
            %
            % Returns:  (struct) Custom warning/error struct.
            %
            % Example: checkFile = currFile.validate();

            fname = strcat(obj.alias, '::validate');
            r = nix_mx(fname, obj.nixhandle);
        end

        % ----------------
        % Block methods
        % ----------------

        function r = createBlock(obj, name, type)
            % Create a new nix.Block entity, that is immediately persisted to the file.
            %
            % name (char):  The name of the Block, has to be unique within the file.
            % type (char):  The type of the Block, required.
            %               Type can be used to give semantic meaning to an entity
            %               and expose it to search methods in a broader context.
            %
            % Returns:  (nix.Block) The newly created Block.
            %
            % Example:  newBlock = f.createBlock('trial1', 'ephys');
            %
            % See also nix.Block.

            fname = strcat(obj.alias, '::createBlock');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Block);
        end

        function r = blockCount(obj)
            % Get the number of Blocks in the file.
            %
            % Returns:  (uint) The number of Blocks.
            %
            % Example:  bc = f.blockCount();
            %
            % See also nix.Block.

            r = nix.Utils.fetchEntityCount(obj, 'blockCount');
        end

        function r = hasBlock(obj, idName)
            % Check if a Block exists in the file.
            %
            % idName (char):  Name or ID of the Block.
            %
            % Returns:  (logical) True if the Block exists, false otherwise.
            %
            % Example:  check = f.hasBlock('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = f.hasBlock('trial1');
            %
            % See also nix.Block.

            r = nix.Utils.fetchHasEntity(obj, 'hasBlock', idName);
        end

        function r = openBlock(obj, idName)
            % Retrieves an existing Block from the file.
            %
            % idName (char):  Name or ID of the Block.
            %
            % Returns:  (nix.Block) The nix.Block or an empty cell, 
            %                       if the Block was not found.
            %
            % Example:  getBlock = f.openBlock('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getBlock = f.openBlock('trial1');
            %
            % See also nix.Block.

            r = nix.Utils.openEntity(obj, 'openBlock', idName, @nix.Block);
        end

        function r = openBlockIdx(obj, index)
            % Retrieves an existing Block from the file, accessed by index.
            %
            % index (double):  The index of the Block to read.
            %
            % Returns:  (nix.Block) The Block at the given index.
            %
            % Example:  getBlock = f.openBlockIdx(1);
            %
            % See also nix.Block.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openBlockIdx', idx, @nix.Block);
        end

        function r = deleteBlock(obj, idNameEntity)
            % Deletes a Block from the file.
            %
            % When a Block is deleted, all its content (DataArray, Tags, Sources, etc)
            % will be deleted from the file as well.
            %
            % idNameEntity (char/nix.Block):  Name or id of the entity to
            %                                 be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Block has been removed, false otherwise.
            %
            % Example:  check = f.deleteBlock('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = f.deleteBlock('trial1');
            %           check = f.deleteBlock(newBlock);
            %
            % See also nix.Block.

            r = nix.Utils.deleteEntity(obj, 'deleteBlock', idNameEntity, 'nix.Block');
        end

        function r = filterBlocks(obj, filter, val)
            % Get a filtered cell array of all Blocks within this file.
            %
            % filter (nix.Filter):  The nix.Filter to be applied. Supports
            %                       The filters 'acceptall', 'id', 'ids',
            %                       'name' and 'type'.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Block]) A cell array of Blocks filtered according
            %                         to the applied nix.Filter.
            %
            % Example:  getBlocks = f.filterBlocks(nix.Filter.type, 'ephys');
            %
            % See also nix.Block, nix.Filter.

            r = nix.Utils.filter(obj, 'blocksFiltered', filter, val, @nix.Block);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = createSection(obj, name, type)
            % Create a new nix.Section entity, that is immediately persisted to the file.
            %
            % name (char):  The name of the Section, has to be unique within the file.
            % type (char):  The type of the Section, required.
            %               Type can be used to give semantic meaning to an entity
            %               and expose it to search methods in a broader context.
            %
            % Returns:  (nix.Section) The newly created Section.
            %
            % Example:  newSec = f.createSection('settings1', 'ephys');
            %
            % See also nix.Section.

            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nixhandle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = sectionCount(obj)
            % Get the number of direct child Sections in the file.
            %
            % Returns:  (uint) The number of direct child (non nested) Sections.
            %
            % Example:  sc = f.sectionCount();
            %
            % See also nix.Section.

            r = nix.Utils.fetchEntityCount(obj, 'sectionCount');
        end

        function r = hasSection(obj, idName)
            % Check if a Section exists as a direct child of the file.
            %
            % idName (char):  Name or ID of the Section.
            %
            % Returns:  (logical) True if the Section exists, false otherwise.
            %
            % Example:  check = f.hasSection('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = f.hasSection('settings1');
            %
            % See also nix.Section.

            r = nix.Utils.fetchHasEntity(obj, 'hasSection', idName);
        end

        function r = openSection(obj, idName)
            % Retrieves an existing Section from the file.
            %
            % idName (char):  Name or ID of the Section.
            %
            % Returns:  (nix.Section) The nix.Section or an empty cell, 
            %                         if the Section was not found.
            %
            % Example:  getSec = f.openSection('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getSec = f.openSection('settings1');
            %
            % See also nix.Section.

            r = nix.Utils.openEntity(obj, 'openSection', idName, @nix.Section);
        end

        function r = openSectionIdx(obj, index)
            % Retrieves an Section from the file, accessed by index.
            %
            % index (double):  The index of the Section to read.
            %
            % Returns:  (nix.Section) The Section at the given index.
            %
            % Example:  getSec = f.openSectionIdx(1);
            %
            % See also nix.Section.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openSectionIdx', idx, @nix.Section);
        end

        function r = deleteSection(obj, idNameEntity)
            % Deletes a Section from the file.
            %
            % When a Section is deleted, all of its child Sections, Properties and 
            % Values will be deleted from the file as well.
            %
            % idNameEntity (char/nix.Section):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the Section has been removed, false otherwise.
            %
            % Example:  check = f.deleteSection('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = f.deleteSection('settings1');
            %           check = f.deleteSection(newSec);
            %
            % See also nix.Section.

            r = nix.Utils.deleteEntity(obj, 'deleteSection', idNameEntity, 'nix.Section');
        end

        function r = filterSections(obj, filter, val)
            % Get a filtered cell array of all root Sections within this file.
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
            % Example:  getSecs = f.filterSections(nix.Filter.type, 'ephys');
            %
            % See also nix.Section, nix.Filter.

            r = nix.Utils.filter(obj, 'sectionsFiltered', filter, val, @nix.Section);
        end

        function r = findSections(obj, maxDepth)
            % Get all Sections and their child Sections in this file recursively.
            %
            % This method traverses the trees of all Sections in the file and adds all
            % Sections to the resulting cell array, until the maximum depth of the nested
            % Sections has been reached. The traversal is accomplished via breadth first 
            % and adds the Sections accordingly.
            %
            % maxDepth (double):  The maximum depth of traversal to retrieve nested 
            %                     Sections. Should be handled like an index.
            %
            % Example:  allSec = f.findSections(2);
            %           % will add all Sections until including the 2nd layer of Sections.
            %
            % See also nix.Section.

            r = obj.filterFindSections(maxDepth, nix.Filter.acceptall, '');
        end

        function r = filterFindSections(obj, maxDepth, filter, val)
            % Get all Sections in this file recursively.
            %
            % This method traverses the trees of all Sections in the file. The traversal
            % is accomplished via breadth first and can be limited in depth. On each 
            % node or Section a nix.Filter is applied. If the filter returns true, the 
            % respective Section will be added to the result list.
            %
            % maxDepth (double):    The maximum depth of traversal to retrieve nested 
            %                       Sections. Should be handled like an index.
            % filter (nix.Filter):  The nix.Filter to be applied. Supports the filters 
            %                       'acceptall', 'id', 'ids', 'name' and 'type'.
            % val (char):           Value that is applied with the selected filter.
            %
            % Example:  allSec = f.filterFindSections(2, nix.Filter.type, 'ephys');
            %
            % See also nix.Section, nix.Filter.

            r = nix.Utils.find(obj, 'findSections', maxDepth, filter, val, @nix.Section);
        end
    end

end
