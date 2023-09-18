function [] = copyToNew(origUUID)

%% PURPOSE: COPY A NODE AND ALL OF ITS DIRECT PREDECESSORS TO NEW VERSIONS.
% Behavior depends on what type the original UUID is, and what the user intends.
% 1. User clicks "copy to new"
% 2. Dialog box asking if this should be within the same analysis, or a
% different analysis.
% 3a. If same analysis:
%   Input VR: Copy the input VR to new, copy the PR to new, copy output VR
%   to new, and link new output VR's to same successor PR's, PR to same
%   PG/AN successors but new VR successors, and input VR's to new PR.
%
%   PR: Copy PR to new, copy output VR to new, and link new output VR's to
%   same successor PR's, PR to same PG/AN successors but new VR successors,
%   and link same input VR's to new PR.
%
%   PG: Copy to new, link to same predecessors and successors
% 3b. If different analysis:
%   Input VR: Get all downstream objects that are part of the current
%   analysis. Copy them all to new, and update their links to each other
%   and new analysis.
%
%   PR: Get all downstream objects that are part of the current analysis.
%   Copy them all to new, and update their links to each other and new
%   analysis.
%
%   PG: Get all downstream objects that are part of the current analysis.
%   Copy them all to new, and update their links to each other and new
%   analysis.
%
%   AN/PJ: Copy all upstream objects, link them to new AN/PJ object
%   (includes VW & LG).
% 
%   VW: Copy to new, link with current analysis.
%
%   LG: Copy to new, copy the output VR's and all downstream objects in the
%   current analysis to a new analysis.

%%% ATTEMPT WITH getAllObjLinks
G = getAllObjLinks();
preds = predecessors(G, origUUID);
newUUIDs = cell(size(preds));
for i=1:length(preds)
    [type, abstractID] = deText(preds{i});
    obj = createNewObject(true, type, getName(preds{i}), abstractID, '', true);
    newUUIDs{i} = obj.UUID; % New node names.
end

edgesIdx = ismember(G.Edges.EndNodes(:,1), preds) & ismember(G.Edges.EndNodes(:,2), origUUID);
edgeTable = G.Edges.EndNodes(edgesIdx,:);

% Create the new node object
[type, abstractID] = deText(origUUID);
newNode = createNewObject(true, type, getName(origUUID), abstractID, '', true);

% Add the new & old object to list of new & old names
newUUIDs = [newUUIDs; {newNode.UUID}];
preds = [preds; {origUUID}];

% Update every edge with new node names.
for i=1:length(preds)
    idx1 = ismember(edgeTable(:,1), preds{i});
    idx2 = ismember(edgeTable(:,2), preds{i});
    edgeTable(idx1,1) = newUUIDs{i};    
    edgeTable(idx2,2) = newUUIDs{i};
end

% Link the new versions of objects in the SQL table.
for i=1:size(edgeTable,1)
    linkObjs(edgeTable{i,1},edgeTable{i,2});
end

% Link the new node to its successors.
succs = successors(G, origUUID);
if ~isempty(succs)
    linkObjs(newNode.UUID, succs);
end



G2 = getAllObjsLinksInContainer(G, containerUUID, 'up');
uuids = G2.Nodes.Name;
newUUIDs = cell(size(uuids));
for i=1:length(uuids)
    [type, abstractID] = deText(uuids{i});
    obj = createNewObject(true, type, getName(uuids{i}), abstractID, '', true);
    newUUIDs{i} = obj.UUID; % New node names.
end
edgeTable = G2.Edges.EndNodes;

% Update every edge with new node names.
for i=1:length(uuids)
    idx1 = ismember(edgeTable(:,1), uuids{i});
    idx2 = ismember(edgeTable(:,2), uuids{i});
    edgeTable(idx1,1) = newUUIDs{i};
    edgeTable(idx2,2) = newUUIDs{i};
end

% Link the objects in the SQL table.
for i=1:size(edgeTable,1)
    linkObjs(edgeTable{i,1},edgeTable{i,2});
end

% Get the parent object of the original container, link the new container
% to the parent object.
succs = successors(G, containerUUID);
if ~isempty(succ) % Should only be empty if copying a project to new, because projects have no successors.
    linkObjs(containerUUID, succs);
end