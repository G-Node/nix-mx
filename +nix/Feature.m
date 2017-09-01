% nix.Feature class provides additional functionality to nix.Tag and nix.MultiTag.
%
% Features are created from a nix.Tag or a nix.MultiTag, linking these to an
% additional nix.DataArray. The way how data from the respective DataArray
% and the Tag/MultiTag are connected, is specified by the nix.LinkType of
% the associated nix.Feature.
%
% nix.Property properties:
%   id (char):                read-only, automatically created id of the entity.
%   linkType (nix.LinkType):  see nix.LinkType description below.
%
% nix.LinkType.Tagged
%   This LinkType indicates, that the position and extent will be applied also 
%   to the data stored via the Feature when it is fetched via the Tag/MultiTag.
%
% nix.LinkType.Untagged
%   This implies that the whole data stored in the linked DataArray belongs to
%   the Feature.
%
% nix.LinkType.Indexed
%   This LinkType is only valid for MultiTags where it indicates that the data linked 
%   via this Feature has to be accessed according to the index in the respective 
%   MulitTag position entry.
%
% Examples:  %-- Returns the Features LinkType.
%            lt = currFeature.linkType();
%            %-- Sets the Feature LinkType. Has to be a valid nix.LinkType.
%            currFeature.linkType(nix.LinkType.Tagged);
%
% See also nix.LinkType, nix.DataArray, nix.Tag, nix.MultiTag.
%
%
% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef Feature < nix.Entity

    properties (Hidden)
        alias = 'Feature'  % nix-mx namespace to access Feature specific nix backend functions.
    end

    properties (Dependent)
        id
        linkType
    end

    methods
        function obj = Feature(h)
           obj@nix.Entity(h);
        end

        function r = get.id(obj)
           r = obj.info.id; 
        end

        function r = get.linkType(obj)
            fname = strcat(obj.alias, '::getLinkType');
            r = nix_mx(fname, obj.nixhandle);
        end

        function [] = set.linkType(obj, linkType)
            fname = strcat(obj.alias, '::setLinkType');
            nix_mx(fname, obj.nixhandle, linkType);
        end

        function r = openData(obj)
            % Returns the DataArray referenced by the invoking Feature.
            %
            % Returns:  (nix.DataArray) The unmodified DataArray entity
            %                           referenced by the invoking Feature.
            %
            % Example: getDataArray = currFeature.openData();
            %
            % See also nix.DataArray.

            fname = strcat(obj.alias, '::openData');
            h = nix_mx(fname, obj.nixhandle);
            r = nix.Utils.createEntity(h, @nix.DataArray);
        end

        function [] = setData(obj, idNameEntity)
            % Sets the DataArray referenced by the invoking Feature.
            %
            % idNameEntity (char/nix.DataArray):  Name or id of the DataArray to be set 
            %                                     or the DataArray itself. Sets the 
            %                                     reference to the DataArray associated 
            %                                     with the invoking Feature. Will replace
            %                                     any previous set reference.
            %
            % Example:  currFeature.setData('some-data-array-id');
            %           currFeature.setData('sessionData1');
            %           currFeature.setData(dataArrayEntity);
            %
            % See also nix.DataArray.

            parsed = nix.Utils.parseEntityId(idNameEntity, 'nix.DataArray');
            fname = strcat(obj.alias, '::setData');
            nix_mx(fname, obj.nixhandle, parsed);
        end
    end

end
