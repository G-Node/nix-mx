classdef File < nix.Entity
    %File nix File object
    
    properties(Hidden)
        info
        blocksCache
        sectionsCache
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
            
            obj.info = nix_mx('File::describe', obj.nix_handle);
            obj.blocksCache = {};
            obj.sectionsCache = {};
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
            blk_list = nix_mx('File::blocks', obj.nix_handle);
            
            % Blocks are cached
            if length(obj.blocksCache) ~= length(blk_list)
                obj.blocksCache = cell(length(blk_list), 1);
                        
                for i = 1:length(blk_list)
                    obj.blocksCache{i} = nix.Block(blk_list{i});
                end
            end
                
            blocks = obj.blocksCache;
        end
        
        % ----------------
        % Section methods
        % ----------------
        
        function section_list = listSections(obj)
            section_list = nix_mx('File::listSections', obj.nix_handle);
        end
        
        function section = openSection(obj, id_or_name)
           h = nix_mx('File::openSection', obj.nix_handle, id_or_name); 
           section = nix.Section(h);
        end;
        
        function sections = get.sections(obj)
            secs_list = nix_mx('File::sections', obj.nix_handle);
            
            % Sections are cached
            if length(obj.sectionsCache) ~= length(secs_list)
                obj.sectionsCache = cell(length(secs_list), 1);
                        
                for i = 1:length(secs_list)
                    obj.sectionsCache{i} = nix.Section(secs_list{i});
                end
            end
                
            sections = obj.sectionsCache;
        end
    end
    
end

