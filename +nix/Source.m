% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Source < nix.NamedEntity & nix.MetadataMixIn
    %Source nix Source object
    
    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Source'
    end
    
    methods
        function obj = Source(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
           
            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
        end;
        
        % ------------------
        % Sources methods
        % ------------------

        function c = source_count(obj)
            c = nix_mx('Source::sourceCount', obj.nix_handle);
        end

        function s = create_source(obj, name, type)
            s = nix.Source(nix_mx('Source::createSource', obj.nix_handle, name, type));
        end;

        function hasSource = has_source(obj, id_or_name)
            hasSource = nix_mx('Source::hasSource', obj.nix_handle, id_or_name);
        end;
        
        function delCheck = delete_source(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Source', 'Source::deleteSource');
        end;

        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Source::openSource', id_or_name, @nix.Source);
        end;

        function retObj = parent_source(obj)
            retObj = nix.Utils.fetchObj('Source::parentSource', ...
                obj.nix_handle, @nix.Source);
        end

        function retObj = referring_data_arrays(obj)
            retObj = nix.Utils.fetchObjList('Source::referringDataArrays', ...
                obj.nix_handle, @nix.DataArray);
        end
    end;
end
