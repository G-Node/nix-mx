classdef Source < nix.Entity
    %Source nix Source object
    
    properties(Hidden)
        info
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        sourceCount
    end;
    
    methods
        function obj = Source(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Source::describe', obj.nix_handle);
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
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Source::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
           sourceHandle = nix_mx('Source::openSource', obj.nix_handle, id_or_name); 
           source = nix.Source(sourceHandle);
        end;

        function metadata = open_metadata(obj)
            metadataHandle = nix_mx('Source::openMetadataSection', obj.nix_handle);
            metadata = 'TODO: implement MetadataSection';
            %metadata = nix.Section(metadataHandle);
        end;
    end;

end