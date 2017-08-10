% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef File < nix.Entity
    % File nix File object

    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'File'
    end

    methods
        function obj = File(path, mode)
            if (~exist('mode', 'var'))
                mode = nix.FileMode.ReadWrite; %default to ReadWrite
            end
            h = nix_mx('File::open', path, mode); 
            obj@nix.Entity(h);

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'blocks', @nix.Block);
            nix.Dynamic.add_dyn_relation(obj, 'sections', @nix.Section);
        end

        % braindead...
        function r = isOpen(obj)
            fname = strcat(obj.alias, '::isOpen');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = fileMode(obj)
            fname = strcat(obj.alias, '::fileMode');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = validate(obj)
            fname = strcat(obj.alias, '::validate');
            r = nix_mx(fname, obj.nix_handle);
        end

        % ----------------
        % Block methods
        % ----------------

        function r = createBlock(obj, name, type)
            fname = strcat(obj.alias, '::createBlock');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Block);
        end

        function r = blockCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'blockCount');
        end

        function r = hasBlock(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasBlock', id_or_name);
        end

        function r = openBlock(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openBlock', id_or_name, @nix.Block);
        end

        function r = openBlockIdx(obj, index)
            idx = nix.Utils.handle_index(index);
            r = nix.Utils.open_entity(obj, 'openBlockIdx', idx, @nix.Block);
        end

        function r = deleteBlock(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteBlock', del, 'nix.Block');
        end

        function r = filterBlocks(obj, filter, val)
            r = nix.Utils.filter(obj, 'blocksFiltered', filter, val, @nix.Block);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = createSection(obj, name, type)
            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = sectionCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'sectionCount');
        end

        function r = hasSection(obj, id_or_name)
            r = nix.Utils.fetchHasEntity(obj, 'hasSection', id_or_name);
        end

        function r = openSection(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'openSection', id_or_name, @nix.Section);
        end

        function r = openSectionIdx(obj, index)
            idx = nix.Utils.handle_index(index);
            r = nix.Utils.open_entity(obj, 'openSectionIdx', idx, @nix.Section);
        end

        function r = deleteSection(obj, del)
            r = nix.Utils.delete_entity(obj, 'deleteSection', del, 'nix.Section');
        end

        function r = filterSections(obj, filter, val)
            r = nix.Utils.filter(obj, 'sectionsFiltered', filter, val, @nix.Section);
        end

        % maxdepth is an index
        function r = findSections(obj, max_depth)
            r = obj.filterFindSections(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = filterFindSections(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, 'findSections', max_depth, filter, val, @nix.Section);
        end
    end

end
