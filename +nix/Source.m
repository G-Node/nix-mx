classdef Source < nix.Entity
    %Source nix Source object
    
    properties(Hidden)
        info
        sourcesCache
        metadataCache
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        sourceCount
        
        sources
    end;
    
    methods
        function obj = Source(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Source::describe', obj.nix_handle);
           
           obj.sourcesCache.lastUpdate = 0;
           obj.sourcesCache.data = {};
           obj.metadataCache.lastUpdate = 0;
           obj.metadataCache.data = {};
        end;
        
        function id = get.id(source)
           id = source.info.id; 
        end;
        
        function type = get.type(source)
            type = source.info.type;
        end;
        
        function name = get.name(source)
           name = source.info.name;
        end;
        
        function type = get.definition(source)
            type = source.info.definition;
        end;
        
        function sourceCount = get.sourceCount(source)
            sourceCount = source.info.sourceCount;
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

        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Source::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;
        
        % ------------------
        % Metadata methods
        % ------------------
        
        function metadata = open_metadata(obj)
            [obj.metadataCache, metadata] = nix.Utils.fetchObj(obj.updatedAt, ...
                'Source::openMetadataSection', obj.nix_handle, obj.metadataCache, @nix.Section);
        end;

    end;
end