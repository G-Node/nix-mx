classdef Block < nix.Entity
    %Block nix Block object
    
    properties(Hidden)
        info
    end;
    
    properties(Dependent)
        id
        type
        name
        sourceCount
        dataArrayCount
        tagCount
        multiTagCount
    end;
    
    methods
        function obj = Block(h)
            obj@nix.Entity(h);
            obj.info = nix_mx('Block::describe', obj.nix_handle);
        end;
        
        function id = get.id(block)
           id = block.info.id; 
        end;
        
        function type = get.type(block)
            type = block.info.type;
        end;
        
        function name = get.name(block)
           name = block.info.name;
        end;
        
        function sourceCount = get.sourceCount(block)
            sourceCount = block.info.sourceCount;
        end;
        
        function dataArrayCount = get.dataArrayCount(block)
            dataArrayCount = block.info.dataArrayCount;
        end;
        
        function tagCount = get.tagCount(block)
            tagCount = block.info.tagCount;
        end;
        
        function multiTagCount = get.multiTagCount(block)
            multiTagCount = block.info.multiTagCount;
        end;
        
        function das = data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end;
        
        function da = data_array(obj, id_or_name)
           dh = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
           da = nix.DataArray(dh);
        end;
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Block::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
           sh = nix_mx('Block::openSource', obj.nix_handle, id_or_name); 
           source = nix.Source(sh);
        end;
        
        function hasTag = has_tag(obj, id_or_name)
            getHasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
            hasTag = getHasTag.hasTag;
        end;
        
        function tagList = list_tags(obj)
            tagList = nix_mx('Block::listTags', obj.nix_handle);
        end;
        
        function tag = open_tag(obj, id_or_name)
           tagHandle = nix_mx('Block::openTag', obj.nix_handle, id_or_name); 
           tag = nix.Tag(tagHandle);
        end;
        
        function tagList = list_multi_tags(obj)
            tagList = nix_mx('Block::listMultiTags', obj.nix_handle);
        end;
        
        function hasTag = has_multi_tag(obj, id_or_name)
            hasTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
        end;
        
        function tag = open_multi_tag(obj, id_or_name)
           tagHandle = nix_mx('Block::openMultiTag', obj.nix_handle, id_or_name); 
           tag = nix.MultiTag(tagHandle);
        end;
        
        function metadata = open_metadata(obj)
            metadataHandle = nix_mx('Block::openMetadataSection', obj.nix_handle);
            metadata = 'TODO: implement MetadataSection';
            %metadata = nix.Section(metadataHandle);
        end;
        
    end;

end