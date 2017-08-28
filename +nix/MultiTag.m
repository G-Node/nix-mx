% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef MultiTag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn
    % MultiTag nix MultiTag object

    properties (Hidden)
        % namespace reference for nix-mx functions
        alias = 'MultiTag'
    end

    methods
        function obj = MultiTag(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.add_dyn_attr(obj, 'units', 'rw');

            % assign relations
            nix.Dynamic.add_dyn_relation(obj, 'references', @nix.DataArray);
            nix.Dynamic.add_dyn_relation(obj, 'features', @nix.Feature);
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
            r = nix.Utils.openEntity(obj, 'openReferences', idName, @nix.DataArray);
        end

        function r = openReferenceIdx(obj, index)
            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieveData(obj, positionIdx, idName)
            posIdx = nix.Utils.handleIndex(positionIdx);
            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nix_handle, posIdx, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveDataIdx(obj, positionIdx, referenceIdx)
            posIdx = nix.Utils.handleIndex(positionIdx);
            refIdx = nix.Utils.handleIndex(referenceIdx);
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, posIdx, refIdx);
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
            addId = nix.Utils.parseEntityId(entity, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nix_handle, addId, linkType);
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

        function r = retrieveFeatureData(obj, positionIdx, idName)
            posIdx = nix.Utils.handleIndex(positionIdx);
            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nix_handle, posIdx, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveFeatureDataIdx(obj, positionIdx, featureIdx)
            posIdx = nix.Utils.handleIndex(positionIdx);
            featIdx = nix.Utils.handleIndex(featureIdx);
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nix_handle, posIdx, featIdx);
            r = nix.Utils.transposeArray(data);
        end

        function r = featureCount(obj)
            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filterFeatures(obj, filter, val)
            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end

        % ------------------
        % Positions methods
        % ------------------

        function r = hasPositions(obj)
            fname = strcat(obj.alias, '::hasPositions');
            r = nix_mx(fname, obj.nix_handle);
        end

        function r = openPositions(obj)
            r = nix.Utils.fetchObj(obj, 'openPositions', @nix.DataArray);
        end

        function [] = addPositions(obj, entity)
            nix.Utils.addEntity(obj, 'addPositions', entity, 'nix.DataArray');
        end

        % ------------------
        % Extents methods
        % ------------------

        function r = openExtents(obj)
            r = nix.Utils.fetchObj(obj, 'openExtents', @nix.DataArray);
        end

        function [] = setExtents(obj, entity)
            if (isempty(entity))
                fname = strcat(obj.alias, '::setNoneExtents');
                nix_mx(fname, obj.nix_handle, 0);
            else
                nix.Utils.addEntity(obj, 'setExtents', entity, 'nix.DataArray');
            end
        end
    end

end
