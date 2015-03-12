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

        function s = create_source(obj, name, type)
            s = nix.Source(nix_mx('Source::createSource', obj.nix_handle, name, type));
            obj.sourcesCache.lastUpdate = 0;
        end;

        function delCheck = delete_source(obj, del)
            [delCheck, obj.sourcesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Source', 'Source::deleteSource', obj.sourcesCache);
        end;

        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                'Source::openSource', id_or_name, @nix.Source);
        end;
        
    end;
end