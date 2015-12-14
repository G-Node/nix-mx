classdef Dynamic
    %Dynamic class (with static methods hehe)
    % implements methods to dynamically assigns properties 

    methods (Static)
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

                if (isempty(val))
                    nix_mx(strcat(obj.alias, '::set_none_', prop), obj.nix_handle, 0);
                elseif(strcmp(prop, 'units') && (~iscell(val)))
                %-- BUGFIX: Matlab crashes, if units in Tags and MultiTags 
                %-- are set using anything else than a cell.
                    ME = MException('MATLAB:class:SetProhibited', sprintf(...
                      'Units can be only set by using cells.'));
                    throwAsCaller(ME);
                else
                    nix_mx(strcat(obj.alias, '::set_', prop), obj.nix_handle, val);
                end
                obj.info = nix_mx(strcat(obj.alias, '::describe'), obj.nix_handle);
            end

            function val = get_method(obj)
                val = obj.info.(prop);
            end
        end
        
        function add_dyn_relation(obj, name, constructor)
            dataAttr = strcat(name, 'Data');
            data = addprop(obj, dataAttr);
            data.Hidden = true;
            obj.(dataAttr) = {};

            % adds a proxy property
            rel = addprop(obj, name);
            rel.GetMethod = @get_method;
            
            % same property but returns Map 
            rel_map = addprop(obj, strcat(name, 'Map'));
            rel_map.GetMethod = @get_as_map;
            rel_map.Hidden = true;
            
            function val = get_method(obj)
                obj.(dataAttr) = nix.Utils.fetchObjList(...
                    strcat(obj.alias, '::', name), obj.nix_handle, ...
                    constructor);
                val = obj.(dataAttr);
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
