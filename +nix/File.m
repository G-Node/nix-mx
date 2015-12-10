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
        
        % ----------------
        % Block methods
        % ----------------

        function newBlock = createBlock(obj, name, type)
            newBlock = nix.Block(nix_mx('File::createBlock', obj.nix_handle, name, type));
            obj.blocksCache.lastUpdate = 0;
        end;

        function hasBlock = hasBlock(obj, id_or_name)
            hasBlock = nix_mx('File::hasBlock', obj.nix_handle, id_or_name);
        end;

        function retObj = openBlock(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openBlock', id_or_name, @nix.Block);
        end

        function delCheck = deleteBlock(obj, del)
            [delCheck, obj.blocksCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Block', 'File::deleteBlock', obj.blocksCache);
        end;

        % ----------------
        % Section methods
        % ----------------

        function newSec = createSection(obj, name, type)
            newSec = nix.Section(nix_mx('File::createSection', obj.nix_handle, name, type));
            obj.sectionsCache.lastUpdate = 0;
        end;

        function hasSec = hasSection(obj, id_or_name)
            hasSec = nix_mx('File::hasSection', obj.nix_handle, id_or_name);
        end;

        function retObj = openSection(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openSection', id_or_name, @nix.Section);
        end

        function delCheck = deleteSection(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, 'nix.Section', 'File::deleteSection');
            obj.sectionsCache.lastUpdate = 0;
        end;

    end
end

