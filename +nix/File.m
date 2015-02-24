classdef File < nix.Entity
    %File nix File object
    
    properties(Hidden)
        info
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
        
        function block_list = listBlocks(obj)
            block_list = nix_mx('File::listBlocks', obj.nix_handle);
        end
        
        function b = openBlock(obj, id_or_name)
            bh = nix_mx('File::openBlock', obj.nix_handle, id_or_name);
            b = nix.Block(bh);
        end
        
        function blocks = get.blocks(obj)
            [obj.blocksCache, blocks] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'File::blocks', obj.nix_handle, obj.blocksCache, @nix.Block);
        end
        
        function newBlock = createBlock(obj, name, type)
            newBlock = nix.Block(nix_mx('File::createBlock', obj.nix_handle, name, type));
        end;

        function delCheck = deleteBlock(obj, deleteBlockObj)
            delCheck = logical(nix_mx('File::deleteBlock', obj.nix_handle, deleteBlockObj.nix_handle));
        end;

        % ----------------
        % Section methods
        % ----------------
        
        function section_list = listSections(obj)
            section_list = nix_mx('File::listSections', obj.nix_handle);
        end
        
        function section = openSection(obj, id_or_name)
           h = nix_mx('File::openSection', obj.nix_handle, id_or_name); 
           section = nix.Section(h);
        end
        
        function sections = get.sections(obj)
            [obj.sectionsCache, sections] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'File::sections', obj.nix_handle, obj.sectionsCache, @nix.Section);
        end;

        function newSec = createSection(obj, name, type)
            newSec = nix.Section(nix_mx('File::createSection', obj.nix_handle, name, type));
        end;

        function delCheck = deleteSection(obj, deleteSectionObj)
            delCheck = logical(nix_mx('File::deleteSection', obj.nix_handle, deleteSectionObj.nix_handle));
        end;

    end
end

