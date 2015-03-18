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

        % ----------------
        % Link methods
        % ----------------

        function [] = set_link(obj, val)
            if (isempty(val))
                nix_mx('Section::set_none_link', obj.nix_handle);
            else
                if(strcmp(class(val), 'nix.Section'))
                    addID = val.id;
                else
                    addID = val;
                end;
                nix_mx('Section::set_link', obj.nix_handle, addID);
            end;
        end;

        function section = openLink(obj)
           handle = nix_mx('Section::openLink', obj.nix_handle);
           section = {};
           if handle ~= 0
               section = nix.Section(handle);
           end;
        end;

        % ----------------
        % Section methods
        % ----------------
        
        function newSec = createSection(obj, name, type)
            newSec = nix.Section(nix_mx('Section::createSection', obj.nix_handle, name, type));
            obj.sectionsCache.lastUpdate = 0;
        end;

        function delCheck = deleteSection(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, 'nix.Section', 'Section::deleteSection');
            obj.sectionsCache.lastUpdate = 0;
        end;

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

        %-- As "datatype" provide one of the nix.DataTypes. Alternatively
        %-- a string stating one of the datatypes supported by nix can be provided.
        function p = create_property(obj, name, datatype)
            p = nix.Property(nix_mx('Section::createProperty', ...
                obj.nix_handle, name, datatype));
            obj.propsCache.lastUpdate = 0;
        end;

        function delCheck = delete_property(obj, del)
            if(isstruct(del) && isfield(del, 'id'))
                delID = del.id;
            elseif (strcmp(class(del), 'nix.Property'))
                delID = del.id;
            else
                delID = del;
            end;
            delCheck = nix_mx('Section::deleteProperty', obj.nix_handle, delID);
            obj.propsCache.lastUpdate = 0;
        end;

        function retObj = open_property(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Section::openProperty', id_or_name, @nix.Property);
        end;

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

