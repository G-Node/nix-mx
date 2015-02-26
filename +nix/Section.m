classdef Section < nix.Entity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties(Hidden)
        info
        sectionsCache
        propsCache
    end;
    
    properties(Dependent)
        name
        type
        id
        repository
        mapping
        
        sections
        properties_cell
        properties_map
    end;
    
    methods
        function obj = Section(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Section::describe', obj.nix_handle);
           
           obj.sectionsCache.lastUpdate = 0;
           obj.sectionsCache.data = {};
           obj.propsCache.lastUpdate = 0;
           obj.propsCache.data = {};           
        end;
        
        function name = get.name(section)
           name = section.info.name;
        end;
        
        function id = get.id(section)
           id = section.info.id;
        end;
        
        function type = get.type(section)
           type = section.info.type;
        end;
        
        function repository = get.repository(section)
           repository = section.info.repository;
        end;
        
        function mapping = get.mapping(section)
           mapping = section.info.mapping;
        end;

        function section = parent(obj)
           sh = nix_mx('Section::parent', obj.nix_handle);
           if sh ~= 0
               section = nix.Section(sh);
           else
               section = {};
           end;
        end;
        
        function section = link(obj)
           sh = nix_mx('Section::link', obj.nix_handle);
           if sh ~= 0
               section = nix.Section(sh);
           else
               section = {};
           end;
        end;
        
        % ----------------
        % Section methods
        % ----------------
        
        function lst = list_sections(obj)
            lst = nix_mx('Section::listSections', obj.nix_handle);
        end;
        
        function sections = get.sections(obj)
            [obj.sectionsCache, sections] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Section::sections', obj.nix_handle, obj.sectionsCache, @nix.Section);
        end
        
        function retObj = open_section(obj, id_or_name)
            handle = nix_mx('Section::openSection', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Section(handle);
            end;
        end;
        
        function hs = has_section(obj, id_or_name)
            r = nix_mx('Section::hasSection', obj.nix_handle, id_or_name);
            hs = logical(r.hasSection);
        end;
        
        % ----------------
        % Property methods
        % ----------------
        
        function props = get.properties_cell(obj)
            [obj.propsCache, props] = nix.Utils.fetchPropList(obj.updatedAt, ...
                'Section::listProperties', obj.nix_handle, obj.propsCache);
        end
        
        function p_map = get.properties_map(obj)
            p_map = containers.Map();
            props = obj.properties_cell;
            
            for i=1:length(props)
                p_map(props{i}.name) = cell2mat(props{i}.values);
            end
        end

    end
    
end

