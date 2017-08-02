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
        function r = is_open(obj)
            fname = strcat(obj.alias, '::isOpen');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = file_mode(obj)
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

        function r = create_block(obj, name, type)
            fname = strcat(obj.alias, '::createBlock');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Block);
        end

        function r = block_count(obj)
            fname = strcat(obj.alias, '::blockCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = has_block(obj, id_or_name)
            fname = strcat(obj.alias, '::hasBlock');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = open_block(obj, id_or_name)
            fname = strcat(obj.alias, '::openBlock');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Block);
        end

        function r = open_block_idx(obj, idx)
            fname = strcat(obj.alias, '::openBlockIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Block);
        end

        function r = delete_block(obj, del)
            fname = strcat(obj.alias, '::deleteBlock');
            r = nix.Utils.delete_entity(obj, del, 'nix.Block', fname);
        end

        function r = filter_blocks(obj, filter, val)
            fname = strcat(obj.alias, '::blocksFiltered');
            r = nix.Utils.filter(obj, filter, val, fname, @nix.Block);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = create_section(obj, name, type)
            fname = strcat(obj.alias, '::createSection');
            h = nix_mx(fname, obj.nix_handle, name, type);
            r = nix.Utils.createEntity(h, @nix.Section);
        end

        function r = section_count(obj)
            fname = strcat(obj.alias, '::sectionCount');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = has_section(obj, id_or_name)
            fname = strcat(obj.alias, '::hasSection');
            r = nix_mx(fname, obj.nix_handle, id_or_name);
        end

        function r = open_section(obj, id_or_name)
            fname = strcat(obj.alias, '::openSection');
            r = nix.Utils.open_entity(obj, fname, id_or_name, @nix.Section);
        end

        function r = open_section_idx(obj, idx)
            fname = strcat(obj.alias, '::openSectionIdx');
            r = nix.Utils.open_entity(obj, fname, idx, @nix.Section);
        end

        function r = delete_section(obj, del)
            fname = strcat(obj.alias, '::deleteSection');
            r = nix.Utils.delete_entity(obj, del, 'nix.Section', fname);
        end

        function r = filter_sections(obj, filter, val)
            fname = strcat(obj.alias, '::sectionsFiltered');
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
    end

end
