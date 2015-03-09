classdef Section < nix.NamedEntity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties (Access = protected)
        % namespace reference for nix-mx functions
        alias = 'Section'
    end
    
    properties(Hidden)
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
            obj.add_dyn_attr('repository', 'rw');
            obj.add_dyn_attr('mapping', 'rw');
            
            % assign relations
            obj.add_dyn_relation('sections', @nix.Section);
            
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
            handle = nix_mx('Section::openSection', obj.nix_handle, id_or_name);
            retObj = {};
            if handle ~= 0
                retObj = nix.Section(handle);
            end;
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

