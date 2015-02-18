classdef Section < nix.Entity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties(Hidden)
        info
        
        sectionsCache
    end;
    
    properties(Dependent)
        name
        type
        id
        repository
        mapping
        
        sections
        props
    end;
    
    methods
        function obj = Section(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Section::describe', obj.nix_handle);
           
           obj.sectionsCache = {};
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
        
        % ----------------
        % Section methods
        % ----------------
        
        function sections = get.sections(obj)
            handles = nix_mx('Section::sections', obj.nix_handle);
            
            % Subsections are cached
            if length(obj.sectionsCache) ~= length(handles)
                obj.sectionsCache = cell(length(handles), 1);
                        
                for i = 1:length(handles)
                    obj.sectionsCache{i} = nix.Section(handles{i});
                end
            end
                
            sections = obj.sectionsCache;
        end
        
        % ----------------
        % Property methods
        % ----------------
        
        function props = get.props(obj)
            props = nix_mx('Section::listProperties', obj.nix_handle);
        end
    end
    
end

