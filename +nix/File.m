classdef File < nix.Entity
    %File nix File object
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'File'

        blocksCache;
        sectionsCache;
    end;
    
    properties(Dependent)
        blocks
        sections
    end
    
    methods
        function obj = File(path, mode)
            if ~exist('mode', 'var')
                mode = nix.FileMode.ReadWrite; %default to ReadWrite
            end
            h = nix_mx('File::open', path, mode); 
            obj@nix.Entity(h);

            obj.blocksCache.lastUpdate = 0;
            obj.blocksCache.data = {};
            obj.sectionsCache.lastUpdate = 0;
            obj.sectionsCache.data = {};
            
            obj.info = nix_mx('File::describe', obj.nix_handle);
        end
        
        % ----------------
        % Block methods
        % ----------------
        
        function retObj = openBlock(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openBlock', id_or_name, @nix.Block);
        end
        
        function blocks = get.blocks(obj)
            [obj.blocksCache, blocks] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'File::blocks', obj.nix_handle, obj.blocksCache, @nix.Block);
        end
        
        function newBlock = createBlock(obj, name, type)
            newBlock = nix.Block(nix_mx('File::createBlock', obj.nix_handle, name, type));
            obj.blocksCache.lastUpdate = 0;
        end;

        function delCheck = deleteBlock(obj, del)
            [delCheck, obj.blocksCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Block', 'File::deleteBlock', obj.blocksCache);
        end;

        % ----------------
        % Section methods
        % ----------------
        
        function retObj = openSection(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'File::openSection', id_or_name, @nix.Section);
        end
        
        function sections = get.sections(obj)
            [obj.sectionsCache, sections] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'File::sections', obj.nix_handle, obj.sectionsCache, @nix.Section);
        end;

        function newSec = createSection(obj, name, type)
            newSec = nix.Section(nix_mx('File::createSection', obj.nix_handle, name, type));
            obj.sectionsCache.lastUpdate = 0;
        end;

        function delCheck = deleteSection(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, 'nix.Section', 'File::deleteSection');
            obj.sectionsCache.lastUpdate = 0;
        end;

    end
end

