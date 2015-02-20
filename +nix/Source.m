classdef Source < nix.Entity
    %Source nix Source object
    
    properties(Hidden)
        info
        sourcesCache
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
        
        % ----------------
        % get updated at
        % ----------------

        function ua = updatedAt(obj)
            ua = nix_mx('Source::updatedAt', obj.nix_handle);
        end;
        
        % ------------------
        % Sources methods
        % ------------------
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Source::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
           sourceHandle = nix_mx('Source::openSource', obj.nix_handle, id_or_name); 
           source = nix.Source(sourceHandle);
        end;

        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Source::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;
        
        % ------------------
        % Metadata methods
        % ------------------
        
        function hasMetadata = has_metadata(obj)
            getHasMetadata = nix_mx('Source::hasMetadataSection', obj.nix_handle);
            hasMetadata = logical(getHasMetadata.hasMetadataSection);
        end;
        
        function metadata = open_metadata(obj)
            metadata = {};
            metadataHandle = nix_mx('Source::openMetadataSection', obj.nix_handle);
            if obj.has_metadata()
                metadata = nix.Section(metadataHandle);
            end;
        end;

    end;
end