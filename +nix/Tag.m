% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Tag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % Tag nix Tag object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'Tag'
    end

    methods
        function obj = Tag(h)
            obj@nix.NamedEntity(h); % this should be first
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'position', 'rw');
            nix.Dynamic.addProperty(obj, 'extent', 'rw');
            nix.Dynamic.addProperty(obj, 'units', 'rw');

            % assign relations
            nix.Dynamic.addGetChildEntities(obj, 'references', @nix.DataArray);
            nix.Dynamic.addGetChildEntities(obj, 'features', @nix.Feature);
        end

        % ------------------
        % References methods
        % ------------------

        function [] = addReference(obj, entity)
            nix.Utils.addEntity(obj, 'addReference', entity, 'nix.DataArray');
        end

        function [] = addReferences(obj, entityArray)
            nix.Utils.addEntityArray(obj, 'addReferences', entityArray, 'nix.DataArray');
        end

        function r = hasReference(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasReference', idName);
        end

        function r = removeReference(obj, del)
            r = nix.Utils.deleteEntity(obj, 'removeReference', del, 'nix.DataArray');
        end

        function r = openReference(obj, idName)
            r = nix.Utils.openEntity(obj, 'openReferenceDataArray', idName, @nix.DataArray);
        end

        function r = openReferenceIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieveData(obj, idName)
            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nix_handle, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveDataIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, idx);
            r = nix.Utils.transposeArray(data);
        end

        function r = referenceCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'referenceCount');
        end

        function r = filterReferences(obj, filter, val)
            r = nix.Utils.filter(obj, 'referencesFiltered', filter, val, @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = addFeature(obj, entity, linkType)
            id = nix.Utils.parseEntityId(entity, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nix_handle, id, linkType);
            r = nix.Utils.createEntity(h, @nix.Feature);
        end

        function r = hasFeature(obj, idName)
            r = nix.Utils.fetchHasEntity(obj, 'hasFeature', idName);
        end

        function r = removeFeature(obj, del)
            r = nix.Utils.deleteEntity(obj, 'deleteFeature', del, 'nix.Feature');
        end

        function r = openFeature(obj, idName)
            r = nix.Utils.openEntity(obj, 'openFeature', idName, @nix.Feature);
        end

        function r = openFeatureIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieveFeatureData(obj, idName)
            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nix_handle, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveFeatureDataIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, idx);
            r = nix.Utils.transposeArray(data);
        end

        function r = featureCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filterFeatures(obj, filter, val)
            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end
    end

end
