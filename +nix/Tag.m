% nix.Tag class to annotate ('tag') regions of interrest in DataArrays.
%
% Besides the DataArray the Tag entities can be considered as the other core entities 
% of the data model. They are meant to attach annotations directly to the data and to 
% establish meaningful links between different kinds of stored data. Most importantly 
% Tags allow the definition of points or regions of interest in data that is stored in 
% other DataArray entities. The DataArray entities the Tag applies to are defined by 
% its property references. One Tag can reference data in multiple DataArrays.
%
% Further the referenced data is defined by an origin vector called position and an 
% optional extent vector that defines its size. Therefore position and extent of a Tag, 
% together with the references field defines a group of points or regions of interest 
% collected from a subset of all available DataArray entities.
%
% Further Tags have a field called nix.Features which makes it possible to associate other 
% data with the Tag. Semantically a Feature of a Tag is some additional data that 
% contains additional information about the points of hyperslabs defined by the Tag. 
% This could be for example data that represents a stimulus (e.g. an image or a signal) 
% that was applied in a certain interval during the recording.
%
% nix.Tag dynamic properties:
%   id (char):          read-only, automatically created id of the entity.
%   name (char):        read-only, name of the entity.      
%   type (char):        read-write, type can be used to give semantic meaning to an 
%                         entity and expose it to search methods in a broader context.
%   definition (char):  read-write, optional description of the entity.
%   position (double):  read-write, the position is a vector that points into referenced 
%                         DataArrays.
%   extent (double):    read-write, given a specified position vector, the extent vector 
%                         defined the size of a region of interest in the 
%                         referenced DataArray entities.
%   unit ([char]):      read-write, the array of units is applied to all values for 
%                         position and extent in order to calculate the right position
%                         vectors in referenced DataArrays.
%
%   info (struct):      Entity property summary. The values in this structure are detached
%                       from the entity, changes will not be persisted to the file.
%
% nix.Tag dynamic child entity properties:
%   references   access to all nix.DataArray child entities referenced by the Tag.
%   features     access to all nix.Features child entities referenced by the Tag.
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

classdef Tag < nix.NamedEntity & nix.MetadataMixIn & nix.SourcesMixIn

    properties (Hidden)
        alias = 'Tag'  % namespace for Tag nix backend function access.
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

            % assign child entities
            nix.Dynamic.addGetChildEntities(obj, 'references', @nix.DataArray);
            nix.Dynamic.addGetChildEntities(obj, 'features', @nix.Feature);
        end

        % ------------------
        % References methods
        % ------------------

        function [] = addReference(obj, idNameEntity)
            % Add a nix.DataArray to the referenced list of the invoking Tag.
            %
            % idNameEntity (char/nix.DataArray):  The id or name of an existing DataArray,
            %                                     or a valid nix.DataArray entity.
            %
            % Example:  currTag.addReferences('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           currTag.addReferences('subTrial2');
            %           currFile.blocks{1}.tags{1}.addReferences(currDataArrayEntity);
            %
            % See also nix.DataArray.

            nix.Utils.addEntity(obj, 'addReference', idNameEntity, 'nix.DataArray');
        end

        function [] = addReferences(obj, entityArray)
            % Set the list of referenced DataArrays for the invoking Tag.
            %
            % Previously referenced DataArrays that are not in the
            % references cell array will be removed.
            %
            % entityArray ([nix.DataArray]):  A cell array of nix.DataArrays.
            %
            % Example:  currTag.addReferences({dataArray1, dataArray2});
            %
            % See also nix.DataArray.

            nix.Utils.addEntityArray(obj, 'addReferences', entityArray, 'nix.DataArray');
        end

        function r = hasReference(obj, idName)
            % Check if a nix.DataArray is referenced by the invoking Tag.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (logical) True if the DataArray exists, false otherwise.
            %
            % Example:  check = currTag.hasReference('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.tags{1}.hasReference('sessionData2');
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchHasEntity(obj, 'hasReference', idName);
        end

        function r = removeReference(obj, idNameEntity)
            % Removes the reference to a nix.DataArray from the invoking Tag.
            %
            % This method removes the association between the DataArray and the
            % Tag, the DataArray itself will not be removed from the file.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the entity to
            %                                   be deleted or the entity itself.
            %
            % Returns:  (logical) True if the reference to the DataArray 
            %                     has been removed, false otherwise.
            %
            % Example:  check = currTag.removeReference('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currTag.removeReference('sessionData2');
            %           check = currFile.blocks{1}.tags{1}.removeReference(newDataArray);
            %
            % See also nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'removeReference', idNameEntity, 'nix.DataArray');
        end

        function r = openReference(obj, idName)
            % Retrieves a referenced DataArray from the invoking Tag.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (nix.DataArray) The nix.DataArray or an empty cell, 
            %                       if the DataArray was not found.
            %
            % Example:  getDA = currTag.openReference('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           getDA = currFile.blocks{1}.tags{1}.openReference('subTrial2');
            %
            % See also nix.DataArray.

            r = nix.Utils.openEntity(obj, 'openReferenceDataArray', idName, @nix.DataArray);
        end

        function r = openReferenceIdx(obj, index)
            % Retrieves a referenced nix.DataArray from the invoking Tag, 
            % accessed by index.
            %
            % index (double):  The index of the DataArray to read.
            %
            % Returns:  (nix.DataArray) The DataArray at the given index.
            %
            % Example:  getDA = currTag.openReferenceIdx(1);
            %
            % See also nix.DataArray.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openReferenceIdx', idx, @nix.DataArray);
        end

        function r = retrieveData(obj, idName)
            % Returns the data from a DataArray referenced by the invoking Tag.
            %
            % idName (char):  Name or ID of the DataArray.
            %
            % Returns:  (var) Data of the DataArray referenced by the Tag.
            %                   The Data is detached from the nix.File,
            %                   changes to this data will not be saved to the file.
            %
            % Example:  data = currTag.retriveData('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           data = currFile.blocks{1}.tags{1}.retrieveData('subTrial2');
            %
            % See also nix.DataArray

            fname = strcat(obj.alias, '::retrieveData');
            data = nix_mx(fname, obj.nixhandle, idName);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveDataIdx(obj, index)
            % Returns the data from a DataArray referenced by the invoking Tag.
            %
            % index (double):  index of the referenced DataArray.
            %
            % Returns:  (var) Data of the DataArray referenced by the Tag.
            %                   The Data is detached from the nix.File,
            %                   changes to this data will not be saved to the file.
            %
            % Example:  data = currTag.retriveDataIdx(1);
            %
            % See also nix.DataArray

            idx = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::retrieveDataIdx');
            data = nix_mx(fname, obj.nixhandle, idx);
            r = nix.Utils.transposeArray(data);
        end

        function r = referenceCount(obj)
            % Get the number nix.DataArrays referenced by the invoking Tag.
            %
            % Returns:  (uint) The number of referenced DataArrays.
            %
            % Example:  dc = currTag.referenceCount();
            %
            % See also nix.DataArray.

            r = nix.Utils.fetchEntityCount(obj, 'referenceCount');
        end

        function r = filterReferences(obj, filter, val)
            % Get a filtered cell array of all DataArrays referenced by the 
            % invoking Tag.
            %
            % filter (nix.Filter):  The nix.Filter to be applied.
            % val (char):           Value that is applied with the selected
            %                       filter.
            %
            % Returns:  ([nix.DataArray]) A cell array of DataArrays filtered according
            %                           to the applied nix.Filter.
            %
            % Example:  getDAs = currTag.filterReferences(nix.Filter.type, 'ephys_data');
            %
            % See also nix.DataArray, nix.Filter.

            r = nix.Utils.filter(obj, 'referencesFiltered', filter, val, @nix.DataArray);
        end

        % ------------------
        % Features methods
        % ------------------

        function r = createFeature(obj, idNameEntity, linkType)
            % Create a new nix.Feature entity associated with a nix.DataArray,
            % that is used by the invoking Tag.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the DataArray to be
            %                                     used or the DataArray itself.
            % linkType (nix.LinkType):  nix.LinkType describing how the DataArray is 
            %                           used by the Tag.
            %
            % Returns:  (nix.Feature) The newly created Feature.
            %
            % Example:  newFeat = currTag.createFeature('subTrial2', nix.LinkType.Tagged);
            %
            % See also nix.Feature, nix.LinkType.

            id = nix.Utils.parseEntityId(idNameEntity, 'nix.DataArray');
            fname = strcat(obj.alias, '::createFeature');
            h = nix_mx(fname, obj.nixhandle, id, linkType);
            r = nix.Utils.createEntity(h, @nix.Feature);
        end

        function r = hasFeature(obj, id)
            % Check if a nix.Feature is associated with the invoking Tag.
            %
            % id (char):  ID of the Feature.
            %
            % Returns:  (logical) True if the Feature exists, false otherwise.
            %
            % Example:  check = currTag.hasFeature('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %
            % See also nix.Feature.

            r = nix.Utils.fetchHasEntity(obj, 'hasFeature', id);
        end

        function r = deleteFeature(obj, idEntity)
            % Deletes a nix.Feature from the invoking Tag.
            %
            % This method deletes a Feature from the invoking Tag, the DataArray 
            % referenced by this Feature will not be removed from the file.
            %
            % idEntity (char/nix.Feature):  id of the Feature to be deleted
            %                                 or the Feature itself.
            %
            % Returns:  (logical) True if the Feature has been removed, false otherwise.
            %
            % Example:  check = currTag.deleteFeature('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %           check = currFile.blocks{1}.tags{1}.deleteFeature(newFeature);
            %
            % See also nix.Feature, nix.DataArray.

            r = nix.Utils.deleteEntity(obj, 'deleteFeature', idEntity, 'nix.Feature');
        end

        function r = openFeature(obj, id)
            % Retrieves an associated Feature from the invoking Tag.
            %
            % id (char):  ID of the Feature.
            %
            % Returns:  (nix.Feature) The Feature or an empty cell, 
            %                         if the Feature was not found.
            %
            % Example:  getFeat = currTag.openFeature('23bb8a99-1812-4bc6-a52c-45e96864756b');
            %
            % See also nix.Feature.

            r = nix.Utils.openEntity(obj, 'openFeature', id, @nix.Feature);
        end

        function r = openFeatureIdx(obj, index)
            % Retrieves an associated nix.Feature from the invoking Tag, 
            % accessed by index.
            %
            % index (double):  The index of the Feature to retrieve.
            %
            % Returns:  (nix.Feature) The Feature at the given index.
            %
            % Example:  getFeat = currTag.openFeatureIdx(1);
            %
            % See also nix.Feature.

            idx = nix.Utils.handleIndex(index);
            r = nix.Utils.openEntity(obj, 'openFeatureIdx', idx, @nix.Feature);
        end

        function r = retrieveFeatureData(obj, id)
            % Returns the raw data from the DataArray attached to the 
            % Feature associated with the invoking Tag.
            %
            % Depending on the nix.LinkType used by the Feature,
            % only the requested sections of the DataArray will be returned.
            % 
            % id (char):  ID of the Feature.
            %
            % Returns:  (var) Data from the referenced DataArray, 
            %                 modified by LinkType of the Feature.
            %
            % Example:  getFeatData = currTag.retrieveFeatureData('some-id');
            %
            % See also nix.Feature, nix.LinkType.

            fname = strcat(obj.alias, '::featureRetrieveData');
            data = nix_mx(fname, obj.nixhandle, id);
            r = nix.Utils.transposeArray(data);
        end

        function r = retrieveFeatureDataIdx(obj, index)
            % Returns the raw data from the DataArray attached to the 
            % Feature associated with the invoking Tag.
            %
            % Depending on the nix.LinkType used by the Feature,
            % only the requested sections of the DataArray will be returned.
            % 
            % index (double):  index of the associated Feature.
            %
            % Returns:  (var) Data from the referenced DataArray, 
            %                 modified by LinkType of the Feature.
            %
            % Example:  getFeatData = currTag.retrieveFeatureDataIdx(3);
            %
            % See also nix.Feature, nix.LinkType.

            idx = nix.Utils.handleIndex(index);
            fname = strcat(obj.alias, '::featureRetrieveDataIdx');
            data = nix_mx(fname, obj.nixhandle, idx);
            r = nix.Utils.transposeArray(data);
        end

        function r = featureCount(obj)
            % Get the number nix.Features associated with the invoking Tag.
            %
            % Returns:  (uint) The number of associated Features.
            %
            % Example:  fc = currTag.featureCount();
            %
            % See also nix.Feature.

            r = nix.Utils.fetchEntityCount(obj, 'featureCount');
        end

        function r = filterFeatures(obj, filter, val)
            % Get a filtered cell array of all Features associated with the 
            % invoking Tag.
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
            % Example:  getFeatures = currTag.filterFeatures(nix.Filter.id, 'some-id');
            %
            % See also nix.Feature, nix.Filter.

            r = nix.Utils.filter(obj, 'featuresFiltered', filter, val, @nix.Feature);
        end
    end

end
