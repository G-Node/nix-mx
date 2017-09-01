% Class implements methods to dynamically assign properties.
%
% Utility class, do not use out of context.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Dynamic

    methods (Static)
        function addProperty(obj, prop, mode)
            if (nargin < 3)
                mode = 'r'; 
            end

            % create dynamic property
            p = addprop(obj, prop);

            % define property accessor methods
            p.GetMethod = @getMethod;
            p.SetMethod = @setMethod;

            function setMethod(obj, val)
                if (strcmp(mode, 'r'))
                    msg = 'You cannot set the read-only property ''%s'' of %s';
                    ME = MException('MATLAB:class:SetProhibited', msg, prop, class(obj));
                    throwAsCaller(ME);
                end

                if (isempty(val))
                    fname = strcat(obj.alias, '::setNone', upper(prop(1)), prop(2:end));
                    nix_mx(fname, obj.nixhandle, 0);
                elseif ((strcmp(prop, 'units') || strcmp(prop, 'labels')) && (~iscell(val)))
                %-- BUGFIX: Matlab crashes, if units in Tags and MultiTags
                %-- or labels of SetDimension are set using anything else than a cell.
                    msg = 'This value only supports cells.';
                    ME = MException('MATLAB:class:SetProhibited', msg);
                    throwAsCaller(ME);
                else
                    fname = strcat(obj.alias, '::set', upper(prop(1)), prop(2:end));
                    nix_mx(fname, obj.nixhandle, val);
                end
            end

            function val = getMethod(obj)
                val = obj.info.(prop);
            end
        end

        function addGetChildEntities(obj, name, constructor)
            dataAttr = strcat(name, 'Data');
            data = addprop(obj, dataAttr);
            data.Hidden = true;
            obj.(dataAttr) = {};

            % adds a proxy property
            rel = addprop(obj, name);
            rel.GetMethod = @getMethod;

            function val = getMethod(obj)
                obj.(dataAttr) = nix.Utils.fetchObjList(obj, name, constructor);
                val = obj.(dataAttr);
            end
        end
    end

end
