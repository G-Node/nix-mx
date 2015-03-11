classdef SourcesMixIn < handle
    %SourcesMixIn
    % mixin class for nix entities that can be related with sources
    % depends on 
    % - nix.Entity
    % - nix.Dynamic
    
    properties (Abstract, Access = protected)
        alias
    end
    
    methods
        function obj = SourcesMixIn()
            obj.add_dyn_relation('sources', @nix.Source);
        end
        
        function [] = add_source(obj, add_this)
            obj.sourcesCache = nix.Utils.add_entity(obj, ...
                add_this, 'nix.Source', ...
                strcat(obj.alias, '::addSource'), obj.sourcesCache);
        end;

        function delCheck = remove_source(obj, del)
            [delCheck, obj.sourcesCache] = nix.Utils.delete_entity(obj, ...
                del, 'nix.Source', strcat(obj.alias, '::removeSource'), ...
                obj.sourcesCache);
        end;

        function retObj = open_source(obj, id_or_name)
            retObj = nix.Utils.open_entity(obj, ...
                strcat(obj.alias, '::openSource'), id_or_name, ...
                @nix.Source);
        end;
    end
    
end

