classdef Section < nix.NamedEntity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'Section'
        propsCache
    end;
    
    properties(Dependent)
        allProperties
        allPropertiesMap
    end;
    
    methods
        function obj = Section(h)
            obj@nix.NamedEntity(h);
            
            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'repository', 'rw');
            nix.Dynamic.add_dyn_attr(obj, 'mapping', 'rw');
            
            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'sections', @nix.Section);
            
            obj.propsCache = nix.CacheStruct();
        end;

        function section = parent(obj)
           handle = nix_mx('Section::parent', obj.nix_handle);
           section = {};
           if handle ~= 0
               section = nix.Section(handle);
           end;
        end;
        
        function section = link(obj)
           handle = nix_mx('Section::link', obj.nix_handle);
           section = {};
           if handle ~= 0
               section = nix.Section(handle);
           end;
        end;
        
        % ----------------
        % Section methods
        % ----------------
        
        function retObj = open_section(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Section::openSection', id_or_name, @nix.Section);
        end;
        
        function hs = has_section(obj, id_or_name)
            hs = nix_mx('Section::hasSection', obj.nix_handle, id_or_name);
        end;
        
        % ----------------
        % Property methods
        % ----------------
        
        function props = get.allProperties(obj)
            [obj.propsCache, props] = nix.Utils.fetchPropList(obj.updatedAt, ...
                'Section::properties', obj.nix_handle, obj.propsCache);
        end
        
        function p_map = get.allPropertiesMap(obj)
            p_map = containers.Map();
            props = obj.allProperties;
            
            for i=1:length(props)
                p_map(props{i}.name) = cell2mat(props{i}.values);
            end
        end

    end
    
end

