% Copyright (c) 2016, German Neuroinformatics Node (G-Node)
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted under the terms of the BSD License. See
% LICENSE file in the root of the Project.

classdef SourcesMixIn < handle
    %SourcesMixIn
    % mixin class for nix entities that can be related with sources

    properties (Abstract, Hidden)
        alias
    end
    
    methods
        function obj = SourcesMixIn()
            nix.Dynamic.add_dyn_relation(obj, 'sources', @nix.Source);
        end
        
        function [] = add_source(obj, add_this)
            nix.Utils.add_entity(obj, add_this, ...
                'nix.Source', strcat(obj.alias, '::addSource'));
        end;

        function delCheck = remove_source(obj, del)
            delCheck = nix.Utils.delete_entity(obj, del, ...
                'nix.Source', strcat(obj.alias, '::removeSource'));
        end;

        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                strcat(obj.alias, '::openSource'), id_or_name, ...
                @nix.Source);
        end;
    end
    
end
