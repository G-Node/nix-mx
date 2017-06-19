% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Section < nix.NamedEntity
    %SECTION Metadata Section class
    %   NIX metadata section
    
    properties(Hidden)
        % namespace reference for nix-mx functions
        alias = 'Section'
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
                nix_mx('Section::setNoneLink', obj.nix_handle);
            else
                if(strcmp(class(val), 'nix.Section'))
                    addID = val.id;
                else
                    addID = val;
                end;
                nix_mx('Section::setLink', obj.nix_handle, addID);
            end;
        end;

        function section = openLink(obj)
           handle = nix_mx('Section::openLink', obj.nix_handle);
           section = {};
           if handle ~= 0
               section = nix.Section(handle);
           end;
        end;

        function retList = inherited_properties(obj)
            retList = nix.Utils.fetchObjList('Section::inheritedProperties', ...
                obj.nix_handle, @nix.Property);
        end

        % ----------------
        % Section methods
        % ----------------
        
        function newSec = create_section(obj, name, type)
            newSec = nix.Section(nix_mx('Section::createSection', ...
                obj.nix_handle, name, type));
        end;

        function delCheck = delete_section(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Section', 'Section::deleteSection');
        end;

        function retObj = open_section(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Section::openSection', id_or_name, @nix.Section);
        end;
        
        function hs = has_section(obj, id_or_name)
            hs = nix_mx('Section::hasSection', obj.nix_handle, id_or_name);
        end;

        function c = section_count(obj)
            c = nix_mx('Section::sectionCount', obj.nix_handle);
        end

        % ----------------
        % Property methods
        % ----------------

        function p = create_property(obj, name, datatype)
            if(~isa(datatype, 'nix.DataType'))
                error('Please provide a valid nix.DataType');
            else
                p = nix.Property(nix_mx('Section::createProperty', ...
                    obj.nix_handle, name, lower(datatype.char)));
            end;
        end;

        function p = create_property_with_value(obj, name, val)
            if(~iscell(val))
                val = num2cell(val);
            end;
            p = nix.Property(nix_mx('Section::createPropertyWithValue', ...
                obj.nix_handle, name, val));
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
        end;

        function retObj = open_property(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Section::openProperty', id_or_name, @nix.Property);
        end;

        function props = get.allProperties(obj)
            props = nix_mx('Section::properties', obj.nix_handle);
        end;
        
        function p_map = get.allPropertiesMap(obj)
            p_map = containers.Map();
            props = obj.allProperties;

            for i=1:length(props)
                p_map(props{i}.name) = cell2mat(props{i}.values);
            end
        end;

        function c = property_count(obj)
            c = nix_mx('Section::propertyCount', obj.nix_handle);
        end

        % ----------------
        % Referring entity methods
        % ----------------

        function das = referring_data_arrays(obj)
            das = nix.Utils.fetchObjList('Section::referringDataArrays', ...
                obj.nix_handle, @nix.DataArray);
        end

        function ret = referring_tags(obj, varargin)
            ret = obj.referring_util(@nix.Tag, 'Tags', varargin{:});
        end

        function ret = referring_multi_tags(obj, varargin)
            ret = obj.referring_util(@nix.MultiTag, 'MultiTags', varargin{:});
        end

        function ret = referring_sources(obj, varargin)
            ret = obj.referring_util(@nix.Source, 'Sources', varargin{:});
        end

        function ret = referring_blocks(obj)
            ret = nix.Utils.fetchObjList('Section::referringBlocks', ...
                obj.nix_handle, @nix.Block);
        end
    end;

    % ----------------
    % Referring utility method
    % ----------------

    methods(Access=protected)
        % referring_util receives a nix entityConstructor, part of a function
        % name and varargin to provide abstract access to nix.Section
        % referringXXX and referringXXX(Block) methods.
        function ret = referring_util(obj, entityConstructor, funcName, varargin)
            if (isempty(varargin))
                ret = nix.Utils.fetchObjList(strcat('Section::referring', funcName), ...
                    obj.nix_handle, entityConstructor);
            elseif ((size(varargin, 2) > 1) || ...
                    (~strcmp(class(varargin{1}), 'nix.Block')))
                error('Provide either empty arguments or a single Block entity');
            else
                ret = nix.Utils.fetchObjListByEntity(strcat('Section::referringBlock', funcName), ...
                    obj.nix_handle, varargin{1}.nix_handle, entityConstructor);
            end
        end
    end
end
