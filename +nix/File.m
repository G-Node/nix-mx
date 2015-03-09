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
        
        function retObj = openBlock(obj, id_or_name)
            handle = nix_mx('File::openBlock', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Block(handle);
            end;
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
            if(strcmp(class(del),'nix.Block'))
                delID = del.id;
            else
                delID = del;
            end;
            delCheck = nix_mx('File::deleteBlock', obj.nix_handle, delID);
            obj.blocksCache.lastUpdate = 0;
        end;

        % ----------------
        % Section methods
        % ----------------
        
        function retObj = openSection(obj, id_or_name)
            handle = nix_mx('File::openSection', obj.nix_handle, id_or_name); 
            retObj = {};
            if handle ~= 0
                retObj = nix.Section(handle);
            end;
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
            if(strcmp(class(del),'nix.Section'))
                delID = del.id;
            else
                delID = del;
            end;
            delCheck = nix_mx('File::deleteSection', obj.nix_handle, delID);
            obj.sectionsCache.lastUpdate = 0;
        end;

    end
end

