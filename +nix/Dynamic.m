classdef Dynamic < dynamicprops
    %Dynamic class to dynamically assign properties 
    % properties are dependent and fetch from 'info' attr
    
    properties (Abstract, Access = protected)
        dynamic_base_attrs
        dynamic_attrs
    end
    
    methods
        function obj = Dynamic()
            assert(iscellstr(obj.dynamic_base_attrs), ...
                '"dynamic_base_attrs" must be a cell array of strings.');
            assert(iscellstr(obj.dynamic_attrs), ...
                '"dynamic_attrs" must be a cell array of strings.');

            attrs = {obj.dynamic_attrs{:}, obj.dynamic_base_attrs{:}};
            for i=1:length(attrs)
                obj.add_dyn_attr(attrs{i}, [], false);
            end
        end
    end

    methods (Access = private)
        function add_dyn_attr(obj, prop, init_val, isReadOnly)
            % input arguments
            assert(nargin > 1);
            assert(nargin < 5);
            if nargin < 3, init_val = []; end
            if nargin < 4, isReadOnly = true; end

            % create dynamic property
            p = addprop(obj, prop);

            % set initial value if present
            obj.(prop) = init_val;

            % define property accessor methods
            p.GetMethod = @get_method;
            p.SetMethod = @set_method;

            function set_method(obj, val)
                if isReadOnly
                    ME = MException('MATLAB:class:SetProhibited', sprintf(...
                      'You cannot set the read-only property ''%s'' of %s', ...
                      prop, class(obj)));
                    throwAsCaller(ME);
                end
                
                % TODO implement setter for dynamic attrs
                %obj.(prop) = val;
                %obj.info = nix_mx('Block::describe', obj.nix_handle);
            end
            
            function val = get_method(obj)
                val = obj.info.(prop);
            end
        end
    end
end