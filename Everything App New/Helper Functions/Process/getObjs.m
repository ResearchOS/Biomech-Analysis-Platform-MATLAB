function [uuidsOut] = getObjs(uuids, types, dir, tmpG)

%% PURPOSE: GET THE OBJECTS OF THE SPECIFIED TYPE, UP OR DOWNSTREAM

global globalG;

if nargin<2
    types = getTypes();
    types(contains(types,{'ST'})) = []; % Because ST is abstract (?)
end

if ~iscell(types)
    types = {types};
end

if nargin<3
    dir = 'down'; % By default, find the objects downstream.
end

if ~iscell(dir)
    dir = {dir};
end

uuidsOut = {};
for i=1:length(dir)

    if exist('tmpG','var')~=1
        tmpG = globalG;
        if isequal(dir{i},'up')
            tmpG = flipedge(globalG);
        end
    end

    reachableNodes = getReachableNodes(tmpG, uuids);
    idx = contains(reachableNodes,types);
    uuidsOut = [uuidsOut; reachableNodes(idx)];

end

uuidsOut = unique(uuidsOut,'stable');