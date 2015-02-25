classdef Dynamic < dynamicprops
    %Dynamic class to dynamically assign properties 
    % properties are dependent and fetch from 'info' attr
    
    properties (Abstract, Access = protected)
        alias
        dynamic_base_attrs
        dynamic_attrs
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
    end
end