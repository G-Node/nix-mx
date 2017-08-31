% nix.MultiTag class to annotate ('tag') multiple regions of interrest in DataArrays.
%
% Besides the DataArray the Tag entities can be considered as the other core entities 
% of the data model. They are meant to attach annotations directly to the data and to 
% establish meaningful links between different kinds of stored data. Most importantly 
% Tags allow the definition of points or regions of interest in data that is stored in 
% other DataArray entities. The DataArray entities the Tag applies to are defined by 
% its property references. One Tag can reference data in multiple DataArrays.
%
% Further the referenced data is defined by an origin DataArray called position and an 
% optional extent DataArray that defines its size. Therefore position and extent of a Tag, 
% together with the references field defines a group of points or regions of interest 
% collected from a subset of all available DataArray entities.
%
% Further Tags have a field called nix.Features which makes it possible to associate other 
% data with the Tag. Semantically a Feature of a Tag is some additional data that 
% contains additional information about the points of hyperslabs defined by the Tag. 
% This could be for example data that represents a stimulus (e.g. an image or a signal) 
% that was applied in a certain interval during the recording.
%
% nix.MultiTag dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, optional description of the entity.
%   unit ([char]):     read-write, the array of units is applied to all values for 
%                        position and extent in order to calculate the right position
%                        vectors in referenced DataArrays.
%
% nix.MultiTag dynamic child entity properties:
%   references   access to all nix.DataArray child entities referenced by the MultiTag.
%   features     access to all nix.Features child entities referenced by the MultiTag.
%   sources      access to all first level nix.Source child entities.
%
% See also nix.DataArray, nix.Feature, nix.Source, nix.Section.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef MultiTag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn

    properties (Hidden)
        alias = 'MultiTag'  % nix-mx namespace to access MultiTag specific nix backend functions.
    end

    methods
        function obj = MultiTag(h)
            obj@nix.NamedEntity(h);
            obj@nix.MetadataMixIn();
            obj@nix.SourcesMixIn();

            % assign dynamic properties
            nix.Dynamic.addProperty(obj, 'units', 'rw');

            % assign child entities
            nix.Dynamic.addGetChildEntities(obj, 'references', @nix.DataArray);
            nix.Dynamic.addGetChildEntities(obj, 'features', @nix.Feature);
        end

        % ------------------
        % References methods
        % ------------------

        function [] = addReference(obj, idNameEntity)
            % Add a nix.DataArray to the referenced list of the invoking MultiTag.
            %
            % idNameEntity (char/nix.DataArray):  The id or name of an existing DataArray,
            %                                     or a valid nix.DataArray entity.
            %
            % Example:  currMultiTag.addReferences('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currMultiTag.addReferences('subTrial2');
            %           currFile.blocks{1}.multiTags{1}.addReferences(currDataArrayEntity);
            %
            % See also nix.DataArray.

            nix.Utils.addEntity(obj, 'addReference', idNameEntity, 'nix.DataArray');
        end

        function [] = addReferences(obj, entityArray)
            % Set the list of referenced DataArrays for the invoking MultiTag.
            %
            % Previously referenced DataArrays that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.DataArray]):  A cell array of nix.DataArrays.
            %
            % Example:  currMultiTag.addReferences({dataArray1, dataArray2});
            %
            % See also nix.DataArray.

            nix.Utils.addEntityArray(obj, 'addReferences', entityArray, 'nix.DataArray');
        end

        function r = hasReference(obj, idName)
            % Check if a nix.DataArray is referenced by the invoking MultiTag.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (logical) True if the DataArray exists, false otherwise.
            %
            % Example:  check = currMultiTag.hasReference('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.multiTags{1}.hasReference('sessionData2');
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchHasEntity(obj, 'hasReference', idName);
        end

        function r = removeReference(obj, idNameEntity)
            % Removes the reference to a nix.DataArray from the invoking MultiTag.
            %
            % This method removes the association between the DataArray and the
            % MultiTag, the DataArray itself will not be removed from the file.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the reference to the DataArray 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currMultiTag.removeReference('some-id');
            %           check = currMultiTag.removeReference('sessionData2');
            %           check = currFile.blocks{1}.multiTags{1}.removeReference(newDataArray);
            %
            % See also nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'removeReference', idNameEntity, 'nix.DataArray');
        end

        function r = openReference(obj, idName)
            % Retrieves a referenced DataArray from the invoking MultiTag.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (nix.DataArray) The nix.DataArray or an empty cell, 
            %                       if the DataArray was not found.
            %
            % Example:  getDA = currMultiTag.openReference('some-id');
            %           getDA = currFile.blocks{1}.multiTags{1}.openReference('subTrial2');
            %
            % See also nix.DataArray.

            r = nix.Utils.openEntity(obj, 'openReferences', idName, @nix.DataArray);
        end

        function r = openReferenceIdx(obj, index)
            % Retrieves a referenced nix.DataArray from the invoking MultiTag, 
            % accessed by index.
            %
            % index (double):  The index of the DataArray to read.
            %
            % Returns:  (nix.DataArray) The DataArray at the given index.
            %
            % Example:  getDA = currMultiTag.openReferenceIdx(1);
            %
            % See also nix.DataArray.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieveData(obj, positionIdx, idName)
            % Returns the data from a DataArray tagged by a certain position and extent
            % of a certain reference by the invoking MultiTag.
            %
            % positionIdx (double):  The index of the requested position.
            % idName (char):         Name or ID of the requested DataArray.
            %
            % Returns:  (var) Data of the DataArray referenced by the MultiTag.
            %                   The Data is detached from the nix.File,
            %                   changes to this data will not be saved to the file.
            %
            % Example:  data = currMultiTag.retriveData(2, 'some-id');
            %           data = currFile.blocks{1}.multiTags{1}.retrieveData(1, 'subTrial2');
            %
            % See also nix.DataArray

            posIdx = nix.Utils.handleIndex(positionIdx);
            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nixhandle, posIdx, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveDataIdx(obj, positionIdx, referenceIdx)
            % Returns the data from a DataArray tagged by a certain position and extent
            % of a certain reference by the invoking MultiTag.
            %
            % positionIdx (double):   The index of the requested position.
            % referenceIdx (double):  The index of the referenced DataArray.
            %
            % Returns:  (var) Data of the DataArray referenced by the MultiTag.
            %                   The Data is detached from the nix.File,
            %                   changes to this data will not be saved to the file.
            %
            % Example:  data = currMultiTag.retriveDataIdx(2, 1);
            %           data = currFile.blocks{1}.multiTags{1}.retrieveDataIdx(1, 3);
            %
            % See also nix.DataArray

            posIdx = nix.Utils.handleIndex(positionIdx);
            refIdx = nix.Utils.handleIndex(referenceIdx);
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nixhandle, posIdx, refIdx);
            r = nix.Utils.transposeArray(data);
        end

        function r = referenceCount(obj)
            % Get the number nix.DataArrays referenced by the invoking MultiTag.
            %
            % Returns:  (uint) The number of referenced DataArrays.
            %
            % Example:  dc = currMultiTag.referenceCount();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchEntityCount(obj, 'referenceCount');
        end

        function r = filterReferences(obj, filter, val)
            % Get a filtered cell array of all DataArrays referenced by the 
            % invoking MultiTag.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.DataArray]) A cell array of DataArrays filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getDAs = currMultiTag.filterReferences(nix.Filter.type, 'ephys_data');
            %
            % See also nix.DataArray, nix.Filter.

            r = nix.Utils.filter(obj, 'referencesFiltered', filter, val, @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = createFeature(obj, idNameEntity, linkType)
            % Create a new nix.Feature entity associated with a nix.DataArray,
            % that is used by the invoking MultiTag.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the DataArray to be
            %                                     used or the DataArray itself.
            % linkType (nix.LinkType):  nix.LinkType describing how the DataArray is 
            %                           used by the MultiTag.
            %
            % Returns:  (nix.Feature) The newly created Feature.
            %
            % Example:  newFeat = currMultiTag.createFeature('subTrial2', nix.LinkType.Untagged);
            %
            % See also nix.Feature, nix.LinkType.

            id = nix.Utils.parseEntityId(idNameEntity, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nixhandle, id, linkType);
            r = nix.Utils.createEntity(h, @nix.Feature);
        end

        function r = hasFeature(obj, id)
            % Check if a nix.Feature is associated with the invoking MultiTag.
            %
            % id (char):  ID of the Feature.
            %
            % Returns:  (logical) True if the Feature exists, false otherwise.
            %
            % Example:  check = currMultiTag.hasFeature('some-id-2345-and-bla');
            %
            % See also nix.Feature.

            r = nix.Utils.fetchHasEntity(obj, 'hasFeature', id);
        end

        function r = deleteFeature(obj, idEntity)
            % Deletes a nix.Feature from the invoking MultiTag.
            %
            % This method deletes a Feature from the invoking MultiTag, the DataArray 
            % referenced by this Feature will not be removed from the file.
            %
            % idEntity (char/nix.Feature):  id of the Feature to be deleted
            %                                 or the Feature itself.
            %
            % Returns:  (logical) True if the Feature has been removed, false otherwise.
            %
            % Example:  check = currMultiTag.deleteFeature('some-feat-id-blub');
            %           check = currFile.blocks{1}.multiTags{1}.deleteFeature(newFeature);
            %
            % See also nix.Feature, nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'deleteFeature', idEntity, 'nix.Feature');
        end

        function r = openFeature(obj, id)
            % Retrieves an associated Feature from the invoking MultiTag.
            %
            % id (char):  ID of the Feature.
            %
            % Returns:  (nix.Feature) The Feature or an empty cell, 
            %                         if the Feature was not found.
            %
            % Example:  getFeat = currMultiTag.openFeature('some-feat-id-2378');
            %
            % See also nix.Feature.

            r = nix.Utils.openEntity(obj, 'openFeature', id, @nix.Feature);
        end

        function r = openFeatureIdx(obj, index)
            % Retrieves an associated nix.Feature from the invoking MultiTag, 
            % accessed by index.
            %
            % index (double):  The index of the Feature to retrieve.
            %
            % Returns:  (nix.Feature) The Feature at the given index.
            %
            % Example:  getFeat = currMultiTag.openFeatureIdx(1);
            %
            % See also nix.Feature.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieveFeatureData(obj, positionIdx, idName)
            % Returns the raw data from the DataArray attached to the 
            % Feature associated with the invoking MultiTag related to a certain
            % position of this MultiTag.
            %
            % Depending on the nix.LinkType used by the Feature,
            % only the requested sections of the DataArray will be returned.
            % 
            % positionIdx (double):  The index of the requested position.
            % idName (char):         ID or name of the Feature.
            %
            % Returns:  (var) Data from the referenced DataArray, 
            %                 modified by LinkType of the Feature.
            %
            % Example:  getFeatData = currMultiTag.retrieveFeatureData(1, 'some-id');
            %           gFD = currFile.blocks{1}.multiTags{1}.retrieveFeatureData(...
            %                                                       2, 'multiTagName');
            %
            % See also nix.Feature, nix.LinkType.

            posIdx = nix.Utils.handleIndex(positionIdx);
            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nixhandle, posIdx, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveFeatureDataIdx(obj, positionIdx, featureIdx)
            % Returns the raw data from the DataArray attached to the 
            % Feature associated with the invoking MultiTag related to a certain
            % position of this MultiTag.
            %
            % Depending on the nix.LinkType used by the Feature,
            % only the requested sections of the DataArray will be returned.
            % 
            % positionIdx (double):  The index of the requested position.
            % featureIdx (double):   The index of the requested Feature.
            %
            % Returns:  (var) Data from the referenced DataArray, 
            %                 modified by LinkType of the Feature.
            %
            % Example:  getFeatData = currMultiTag.retrieveFeatureDataIdx(1, 3);
            %           gFD = currFile.blocks{1}.multiTags{1}.retrieveFeatureDataIdx(2, 1);
            %
            % See also nix.Feature, nix.LinkType.

            posIdx = nix.Utils.handleIndex(positionIdx);
            featIdx = nix.Utils.handleIndex(featureIdx);
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nixhandle, posIdx, featIdx);
            r = nix.Utils.transposeArray(data);
        end

        function r = featureCount(obj)
            % Get the number nix.Features associated with the invoking MultiTag.
            %
            % Returns:  (uint) The number of associated Features.
            %
            % Example:  fc = currMultiTag.featureCount();
            %
            % See also nix.Feature.

            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filterFeatures(obj, filter, val)
            % Get a filtered cell array of all Features associated with the 
            % invoking MultiTag.
            %
            % filter (nix.Filter):  The nix.Filter to be applied. The filters 
            %                       nix.Filter.acceptall, nix.Filter.id and
            %                       nix.Filter.ids are supported.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.Feature]) A cell array of Features filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getFeatures = currMultiTag.filterFeatures(nix.Filter.id, 'some-fancy-id');
            %
            % See also nix.Feature, nix.Filter.

            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end

        % ------------------
        % Positions methods
        % ------------------

        function r = hasPositions(obj)
            % Check if the invoking MultiTag has a positions DataArray.
            %
            % Returns:  (logical) True if the positions are set, false otherwise.
            %
            % Example:  check = currMultiTag.hasPositions();
            %
            % See also nix.DataArray.

            fname = strcat(obj.alias, '::hasPositions');
            r = nix_mx(fname, obj.nixhandle);
        end

        function r = openPositions(obj)
            % The positions of a MultiTag are defined in a DataArray. This DataArray 
            % has to define a set of origin vectors, each defining a point inside the 
            % referenced data or the beginning of a region of interest.
            %
            % Returns: (nix.DataArray) The DataArray defining the regions of
            %                           interest referenced by this MultiTag.
            %
            % Example:  posDA = currMultiTag.openPositions();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchObj(obj, 'openPositions', @nix.DataArray);
        end

        function [] = setPositions(obj, idNameEntity)
            % Set a nix.DataArray as the positions data of the invoking Tag.
            %
            % If positions were already set, using this method again will
            % replace the reference to the old DataArray with a reference
            % to the current one.
            %
            % idNameEntity (char/nix.DataArray):  The id or name of an existing DataArray,
            %                                     or a valid nix.DataArray entity.
            %
            % Example:  currMultiTag.setPositions('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currMultiTag.setPositions('subTrial2');
            %           currFile.blocks{1}.multiTags{1}.setPositions(currDataArrayEntity);
            %
            % See also nix.DataArray.

            nix.Utils.addEntity(obj, 'addPositions', idNameEntity, 'nix.DataArray');
        end

        % ------------------
        % Extents methods
        % ------------------

        function r = openExtents(obj)
            % Returns the extents of the invoking MultiTag.
            %
            % The extents of a MultiTag are defined in an associated DataArray. 
            % This array has to define a set of extent vectors, each defining the 
            % size of the corresponding region of interest.
            %
            % Returns:  (nix.DataArray) The defined extents of the invoking MultiTag.
            %
            % Example:  extentsDA = currMultiTag.openExtents();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchObj(obj, 'openExtents', @nix.DataArray);
        end

        function [] = setExtents(obj, idNameEntity)
            % Set a nix.DataArray as the extents data of the invoking MultiTag.
            %
            % If extents were already set, using this method again will
            % replace the reference to the old DataArray with a reference
            % to the current one.
            %
            % extents can be removed by handing an empty string to the method.
            %
            % idNameEntity (char/nix.DataArray):  The id or name of an existing DataArray,
            %                                     or a valid nix.DataArray entity.
            %
            % Example:  currMultiTag.setExtents('some-data-array-id');
            %           currMultiTag.setExtents('subTrial2');
            %           currFile.blocks{1}.multiTags{1}.setExtents(currDataArrayEntity);
            %
            % See also nix.DataArray.

            if (isempty(idNameEntity))
                fname = strcat(obj.alias, '::setNoneExtents');
                nix_mx(fname, obj.nixhandle, 0);
            else
                nix.Utils.addEntity(obj, 'setExtents', idNameEntity, 'nix.DataArray');
            end
        end
    end

end
