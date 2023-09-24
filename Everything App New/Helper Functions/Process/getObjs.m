function [uuids] = getObjs(uuid,types,dir)

%% PURPOSE: GET THE OBJECTS OF THE SPECIFIED TYPE, UP OR DOWNSTREAM

global globalG;

if nargin<2
    types = getTypes();
    types(contains(types,{'ST'})) = [];
end

if ~iscell(types)
    types = {types};
end

if nargin<3
    dir = 'down'; % By default, find the objects downstream.
end

tmpG = globalG;
if isequal(dir,'up')
    tmpG = flipedge(globalG);
end

reachableNodes = getReachableNodes(tmpG, uuid);
idx = contains(reachableNodes,types);
uuids = globalG.Nodes.Name(idx);