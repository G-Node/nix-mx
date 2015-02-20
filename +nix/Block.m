classdef Block < nix.Entity
    %Block nix Block object
    
    properties(Hidden)
        info
        dataArraysCache
        sourcesCache
        tagsCache
        multiTagsCache
    end;
    
    properties(Dependent)
        id
        type
        name
        dataArrayCount
        sourceCount
        tagCount
        multiTagCount
        
        dataArrays
        sources
        tags
        multiTags
    end;
    
    methods
        function obj = Block(h)
            obj@nix.Entity(h);
            obj.info = nix_mx('Block::describe', obj.nix_handle);
            
            obj.dataArraysCache.lastUpdate = 0;
            obj.dataArraysCache.data = {};
            obj.sourcesCache.lastUpdate = 0;
            obj.sourcesCache.data = {};
            obj.tagsCache.lastUpdate = 0;
            obj.tagsCache.data = {};
            obj.multiTagsCache.lastUpdate = 0;
            obj.multiTagsCache.data = {};
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
        
        function dataArrayCount = get.dataArrayCount(block)
            dataArrayCount = block.info.dataArrayCount;
        end;
        
        function sourceCount = get.sourceCount(block)
            sourceCount = block.info.sourceCount;
        end;
        
        function tagCount = get.tagCount(block)
            tagCount = block.info.tagCount;
        end;
        
        function multiTagCount = get.multiTagCount(block)
            multiTagCount = block.info.multiTagCount;
        end;
        
        % -----------------
        % DataArray methods
        % -----------------
        
        function das = list_data_arrays(obj)
            das = nix_mx('Block::listDataArrays', obj.nix_handle);
        end;
        
        function da = data_array(obj, id_or_name)
           dh = nix_mx('Block::openDataArray', obj.nix_handle, id_or_name); 
           da = nix.DataArray(dh);
        end;
        
        function da = get.dataArrays(obj)
            [obj.dataArraysCache, da] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Block::dataArrays', obj.nix_handle, obj.dataArraysCache, @nix.DataArray);
        end;
        
        % -----------------
        % Sources methods
        % -----------------
        
        function sourcesList = list_sources(obj)
            sourcesList = nix_mx('Block::listSources', obj.nix_handle);
        end;

        function source = open_source(obj, id_or_name)
           sh = nix_mx('Block::openSource', obj.nix_handle, id_or_name); 
           source = nix.Source(sh);
        end;

        function sources = get.sources(obj)
            [obj.sourcesCache, sources] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Block::sources', obj.nix_handle, obj.sourcesCache, @nix.Source);
        end;
        
        % -----------------
        % Tags methods
        % -----------------
        
        function hasTag = has_tag(obj, id_or_name)
            getHasTag = nix_mx('Block::hasTag', obj.nix_handle, id_or_name);
            hasTag = logical(getHasTag.hasTag);
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
        
        function tags = get.tags(obj)
            [obj.tagsCache, tags] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Block::tags', obj.nix_handle, obj.tagsCache, @nix.Tag);
        end;
        
        % -----------------
        % MultiTag methods
        % -----------------
        
        function hasMTag = has_multi_tag(obj, id_or_name)
            getHasMTag = nix_mx('Block::hasMultiTag', obj.nix_handle, id_or_name);
            hasMTag = logical(getHasMTag.hasMultiTag);
        end;
        
        function tag = open_multi_tag(obj, id_or_name)
           tagHandle = nix_mx('Block::openMultiTag', obj.nix_handle, id_or_name); 
           tag = nix.MultiTag(tagHandle);
        end;
        
        function mtags = get.multiTags(obj)
            [obj.multiTagsCache, mtags] = nix.Utils.fetchObjList(obj.updatedAt, ...
                'Block::multiTags', obj.nix_handle, obj.multiTagsCache, @nix.MultiTag);
        end;
        
        % -----------------
        % Metadata methods
        % -----------------
        
        function hasMetadata = has_metadata(obj)
            getHasMetadata = nix_mx('Block::hasMetadataSection', obj.nix_handle);
            hasMetadata = logical(getHasMetadata.hasMetadataSection);
        end;
        
        function metadata = open_metadata(obj)
            metadata = {};
            metadataHandle = nix_mx('Block::openMetadataSection', obj.nix_handle);
            if obj.has_metadata()
                metadata = nix.Section(metadataHandle);
            end;
        end;

    end;
end