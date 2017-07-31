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
            if ~exist('mode', 'var')
                mode = nix.FileMode.ReadWrite; %default to ReadWrite
            end
            h = nix_mx('File::open', path, mode); 
            obj@nix.Entity(h);

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'blocks', @nix.Block);
            nix.Dynamic.add_dyn_relation(obj, 'sections', @nix.Section);

            obj.info = nix_mx('File::describe', obj.nix_handle);
        end

        % braindead...
        function r = is_open(obj)
            r = nix_mx('File::isOpen', obj.nix_handle);
        end

        function r = file_mode(obj)
            r = nix_mx('File::fileMode', obj.nix_handle);
        end

        function r = validate(obj)
            r = nix_mx('File::validate', obj.nix_handle);
        end

        % ----------------
        % Block methods
        % ----------------

        function r = create_block(obj, name, type)
            r = nix.Block(nix_mx('File::createBlock', obj.nix_handle, name, type));
        end

        function r = block_count(obj)
            r = nix_mx('File::blockCount', obj.nix_handle);
        end

        function r = has_block(obj, id_or_name)
            r = nix_mx('File::hasBlock', obj.nix_handle, id_or_name);
        end

        function r = open_block(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'File::openBlock', id_or_name, @nix.Block);
        end

        function r = open_block_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'File::openBlockIdx', idx, @nix.Block);
        end

        function r = delete_block(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Block', 'File::deleteBlock');
        end

        function r = filter_blocks(obj, filter, val)
            r = nix.Utils.filter(obj, filter, val, 'File::blocksFiltered', @nix.Block);
        end

        % ----------------
        % Section methods
        % ----------------

        function r = create_section(obj, name, type)
            r = nix.Section(nix_mx('File::createSection', obj.nix_handle, name, type));
        end

        function r = section_count(obj)
            r = nix_mx('File::sectionCount', obj.nix_handle);
        end

        function r = has_section(obj, id_or_name)
            r = nix_mx('File::hasSection', obj.nix_handle, id_or_name);
        end

        function r = open_section(obj, id_or_name)
            r = nix.Utils.open_entity(obj, 'File::openSection', id_or_name, @nix.Section);
        end

        function r = open_section_idx(obj, idx)
            r = nix.Utils.open_entity(obj, 'File::openSectionIdx', idx, @nix.Section);
        end

        function r = delete_section(obj, del)
            r = nix.Utils.delete_entity(obj, del, 'nix.Section', 'File::deleteSection');
        end

        function r = filter_sections(obj, filter, val)
            r = nix.Utils.filter(obj, ...
                filter, val, 'File::sectionsFiltered', @nix.Section);
        end

        % maxdepth is an index
        function r = find_sections(obj, max_depth)
            r = obj.find_filtered_sections(max_depth, nix.Filter.accept_all, '');
        end

        % maxdepth is an index
        function r = find_filtered_sections(obj, max_depth, filter, val)
            r = nix.Utils.find(obj, ...
                max_depth, filter, val, 'File::findSections', @nix.Section);
        end
    end

end
