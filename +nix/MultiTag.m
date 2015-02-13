classdef MultiTag < nix.Entity
    %MultiTag nix MultiTag object

    properties(Hidden)
        info
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        units
        featuresCount
        sourcesCount
        dataArrayReferenceCount
    end;

    methods
        function obj = MultiTag(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('MultiTag::describe', obj.nix_handle);
        end;
        
        function id = get.id(tag)
           id = tag.info.id; 
        end;
        
        function name = get.name(tag)
           name = tag.info.name;
        end;
        
        function type = get.type(tag)
            type = tag.info.type;
        end;

        function definition = get.definition(tag)
            definition = tag.info.definition;
        end;

        function units = get.units(tag)
            units = tag.info.units;
        end;

        function featuresCount = get.featuresCount(tag)
            featuresCount = tag.info.featuresCount;
        end;

        function sourcesCount = get.sourcesCount(tag)
             sourcesCount = tag.info.sourcesCount;
        end;

        function dataArrayReferenceCount = get.dataArrayReferenceCount(tag)
            dataArrayReferenceCount = tag.info.dataArrayReferenceCount;
        end;
        
        function refList = list_references(obj)
            refList = nix_mx('MultiTag::listReferences', obj.nix_handle);
        end;

        function featureList = list_features(obj)
            featureList = nix_mx('MultiTag::listFeatures', obj.nix_handle);
        end;

        function sourceList = list_sources(obj)
            sourceList = nix_mx('MultiTag::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
            sourceHandle = nix_mx('MultiTag::openSource', obj.nix_handle, id_or_name);
            source = 'TODO: implement source';
            %source = nix.Source(sourceHandle);
        end;

        function feature = open_feature(obj, id_or_name)
            featureHandle = nix_mx('MultiTag::openFeature', obj.nix_handle, id_or_name);
            feature = 'TODO: implement feature';
            %feature = nix.Feature(featureHandle);
        end;

        function dataArray = open_referenced_data_array(obj, id_or_name)
            daHandle = nix_mx('MultiTag::openReferenceDataArray', obj.nix_handle, id_or_name);
            dataArray = nix.DataArray(daHandle);
        end;

        function metadata = open_metadata(obj)
            metadataHandle = nix_mx('MultiTag::openMetadataSection', obj.nix_handle);
            metadata = 'TODO: implement MetadataSection';
            %metadata = nix.Section(metadataHandle);
        end;
    end;

end