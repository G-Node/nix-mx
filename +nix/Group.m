% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Group < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % Group nix Group object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Group'
    end

    methods
        function obj = Group(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'dataArrays', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'tags', @nix.Tag);
            nix.Dynamic.add_dyn_relation(obj, 'multiTags', @nix.MultiTag);
        end

        % -----------------
        % DataArray methods
        % -----------------

        function r = dataArrayCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'dataArrayCount');
        end

        function r = hasDataArray(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasDataArray', idName);
        end

        function r = getDataArray(obj, idName)
            r = nix.Utils.openEntity(obj, 'getDataArray', idName, @nix.DataArray);
        end

        function r = openDataArrayIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openDataArrayIdx', idx, @nix.DataArray);
        end

        function [] = addDataArray(obj, entity)
            nix.Utils.addEntity(obj, 'addDataArray', entity, 'nix.DataArray');
        end

        function [] = addDataArrays(obj, entityArray)
            nix.Utils.addEntityArray(obj, 'addDataArrays', entityArray, 'nix.DataArray');
        end

        function r = removeDataArray(obj, del)
            r = nix.Utils.deleteEntity(obj, 'removeDataArray', del, 'nix.DataArray');
        end

        function r = filterDataArrays(obj, filter, val)
            r = nix.Utils.filter(obj, 'dataArraysFiltered', filter, val, @nix.DataArray);
        end

        % -----------------
        % Tags methods
        % -----------------

        function [] = addTag(obj, entity)
            nix.Utils.addEntity(obj, 'addTag', entity, 'nix.Tag');
        end

        function [] = addTags(obj, entityArray)
            nix.Utils.addEntityArray(obj, 'addTags', entityArray, 'nix.Tag');
        end

        function r = hasTag(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasTag', idName);
        end

        function r = getTag(obj, idName)
            r = nix.Utils.openEntity(obj, 'getTag', idName, @nix.Tag);
        end

        function r = openTagIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openTagIdx', idx, @nix.Tag);
        end

        function r = removeTag(obj, del)
            r = nix.Utils.deleteEntity(obj, 'removeTag', del, 'nix.Tag');
        end

        function r = tagCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'tagCount');
        end

        function r = filterTags(obj, filter, val)
            r = nix.Utils.filter(obj, 'tagsFiltered', filter, val, @nix.Tag);
        end

        % -----------------
        % MultiTag methods
        % -----------------

        function [] = addMultiTag(obj, entity)
            nix.Utils.addEntity(obj, 'addMultiTag', entity, 'nix.MultiTag');
        end

        function [] = addMultiTags(obj, entityArray)
            nix.Utils.addEntityArray(obj, 'addMultiTags', entityArray, 'nix.MultiTag');
        end

        function r = hasMultiTag(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasMultiTag', idName);
        end

        function r = getMultiTag(obj, idName)
            r = nix.Utils.openEntity(obj, 'getMultiTag', idName, @nix.MultiTag);
        end

        function r = openMultiTagIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openMultiTagIdx', idx, @nix.MultiTag);
        end

        function r = removeMultiTag(obj, del)
            r = nix.Utils.deleteEntity(obj, 'removeMultiTag', del, 'nix.MultiTag');
        end

        function r = multiTagCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'multiTagCount');
        end

        function r = filterMultiTags(obj, filter, val)
            r = nix.Utils.filter(obj, 'multiTagsFiltered', filter, val, @nix.MultiTag);
        end
    end

end
