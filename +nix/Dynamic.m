classdef Dynamic < dynamicprops
    %Dynamic class that dynamically assigns properties 
    % from these cell arrays that must be defined in the 
    % superclasses
    %    dynamic_base_attrs = {}
    %    dynamic_attrs = {}
    %    dynamic_relations = {}
    
    properties (Abstract, Access = protected)
        alias
        dynamic_base_attrs
        dynamic_attrs
        dynamic_relations
    end
    
    properties (Access = protected)
        info
    end
    
    methods
        function obj = Dynamic()
            % fetch all object attrs
            obj.info = nix_mx(strcat(obj.alias, '::describe'), obj.nix_handle);
            
            % assign dynamic properties
            attrs = {obj.dynamic_attrs{:}, obj.dynamic_base_attrs{:}};
            for i=1:length(attrs)
                obj.add_dyn_attr(attrs{i}.name, attrs{i}.mode);
            end

            % assign dynamic relations
            rels = obj.dynamic_relations;
            for i=1:length(rels)
                obj.add_dyn_relation(rels{i}.name, rels{i}.constructor);
            end
        end
    end

    methods (Access = private)
        function add_dyn_attr(obj, prop, mode)
            if nargin < 3
                mode = 'r'; 
            end

            % create dynamic property
            p = addprop(obj, prop);

            % define property accessor methods
            p.GetMethod = @get_method;
            p.SetMethod = @set_method;

            function set_method(obj, val)
                if strcmp(mode, 'r')
                    ME = MException('MATLAB:class:SetProhibited', sprintf(...
                      'You cannot set the read-only property ''%s'' of %s', ...
                      prop, class(obj)));
                    throwAsCaller(ME);
                end
                
                % TODO set appropriate method name template
                nix_mx(strcat(obj.alias, '::set_', prop), obj.nix_handle);
                obj.info = nix_mx(strcat(obj.alias, '::describe'), obj.nix_handle);
            end
            
            function val = get_method(obj)
                val = obj.info.(prop);
            end
        end
        
        function add_dyn_relation(obj, name, constructor)
            cacheAttr = strcat(name, 'Cache');
            cache = addprop(obj, cacheAttr);
            cache.Hidden = true;
            obj.(cacheAttr) = nix.CacheStruct();
            
            rel = addprop(obj, name);
            rel.GetMethod = @get_method;
            
            function val = get_method(obj)
                [obj.(cacheAttr), val] = nix.Utils.fetchObjList(obj.updatedAt, ...
                    strcat(obj.alias, '::', name), obj.nix_handle, ...
                    obj.(cacheAttr), constructor);
            end            
        end
    end
end