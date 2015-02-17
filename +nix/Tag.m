classdef Tag < nix.Entity
    %Tag nix Tag object

    properties(Hidden)
        info
    end;
    
    properties(Dependent)
        id
        type
        name
        definition
        position
        extent
        units
        featuresCount
        sourcesCount
        referenceCount
    end;

    methods
        function obj = Tag(h)
           obj@nix.Entity(h);
           obj.info = nix_mx('Tag::describe', obj.nix_handle);
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

        function position = get.position(tag)
            position = tag.info.position;
        end;

        function extent = get.extent(tag)
            extent = tag.info.extent;
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

        function referenceCount = get.referenceCount(tag)
            referenceCount = tag.info.referenceCount;
        end;
        
        function refList = list_references(obj)
            refList = nix_mx('Tag::listReferences', obj.nix_handle);
        end;

        function featureList = list_features(obj)
            featureList = nix_mx('Tag::listFeatures', obj.nix_handle);
        end;

        function sourceList = list_sources(obj)
            sourceList = nix_mx('Tag::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
            sourceHandle = nix_mx('Tag::openSource', obj.nix_handle, id_or_name);
            source = nix.Source(sourceHandle);
        end;

        function feature = open_feature(obj, id_or_name)
            featureHandle = nix_mx('Tag::openFeature', obj.nix_handle, id_or_name);
            feature = 'TODO: implement feature';
            %feature = nix.Feature(featureHandle);
        end;

        function dataArray = open_reference(obj, id_or_name)
            daHandle = nix_mx('Tag::openReferenceDataArray', obj.nix_handle, id_or_name);
            dataArray = nix.DataArray(daHandle);
        end;

        function metadata = open_metadata(obj)
            metadataHandle = nix_mx('Tag::openMetadataSection', obj.nix_handle);
            metadata = 'TODO: implement MetadataSection';
            %metadata = nix.Section(metadataHandle);
        end;
    end;

end