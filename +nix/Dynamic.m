classdef Dynamic < dynamicprops
    %Dynamic class that dynamically assigns properties 

    properties (Abstract, Access = protected)
        alias
    end
    
    properties (Access = protected)
        info
    end
    
    methods
        function obj = Dynamic()
            % fetch all object attrs
            obj.info = nix_mx(strcat(obj.alias, '::describe'), obj.nix_handle);
        end
    end

    methods (Access = protected)
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
            
            % adds a proxy property
            rel = addprop(obj, name);
            rel.GetMethod = @get_method;
            
            % same property but returns Map 
            rel_map = addprop(obj, strcat(name, 'Map'));
            rel_map.GetMethod = @get_as_map;
            
            function val = get_method(obj)
                [obj.(cacheAttr), val] = nix.Utils.fetchObjList(obj.updatedAt, ...
                    strcat(obj.alias, '::', name), obj.nix_handle, ...
                    obj.(cacheAttr), constructor);
            end
            
            function val = get_as_map(obj)
                val = containers.Map();
                props = obj.(name);

                for i=1:length(props)
                    val(props{i}.name) = cell2mat(props{i}.values);
                end
            end
        end
    end
end