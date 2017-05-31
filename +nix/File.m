% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef File < nix.Entity
    %File nix File object
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'File'
    end;
    
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
        function check = is_open(obj)
            check = nix_mx('File::isOpen', obj.nix_handle);
        end

        function mode = file_mode(obj)
            mode = nix_mx('File::fileMode', obj.nix_handle);
        end

        % ----------------
        % Block methods
        % ----------------

        function newBlock = create_block(obj, name, type)
            newBlock = nix.Block(nix_mx('File::createBlock', obj.nix_handle, name, type));
        end;

        function c = block_count(obj)
            c = nix_mx('File::blockCount', obj.nix_handle);
        end

        function hasBlock = has_block(obj, id_or_name)
            hasBlock = nix_mx('File::hasBlock', obj.nix_handle, id_or_name);
        end;

        function retObj = open_block(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openBlock', id_or_name, @nix.Block);
        end

        function delCheck = delete_block(obj, del)
            delCheck = nix.Utils.delete_entity(obj, ...
                del, 'nix.Block', 'File::deleteBlock');
        end;

        % ----------------
        % Section methods
        % ----------------

        function newSec = create_section(obj, name, type)
            newSec = nix.Section(nix_mx('File::createSection', obj.nix_handle, name, type));
        end;

        function c = section_count(obj)
            c = nix_mx('File::sectionCount', obj.nix_handle);
        end

        function hasSec = has_section(obj, id_or_name)
            hasSec = nix_mx('File::hasSection', obj.nix_handle, id_or_name);
        end;

        function retObj = open_section(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openSection', id_or_name, @nix.Section);
        end

        function delCheck = delete_section(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, 'nix.Section', 'File::deleteSection');
        end;
    end

end
