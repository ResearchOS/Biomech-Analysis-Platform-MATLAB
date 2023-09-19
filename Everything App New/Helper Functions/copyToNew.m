function [] = copyToNew(origUUID, newVersion)

%% PURPOSE: COPY A NODE AND ALL OF ITS DIRECT PREDECESSORS TO NEW VERSIONS.
% Behavior depends on what type the original UUID is, and what the user intends (newVersion true or false).
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

if nargin==1
    newVersion = false;
end

[origType] = deText(origUUID);

G = getAllObjLinks();

% Get the UUID's to copy and create new ID's for.
if newVersion
    if isequal(origType,'PJ')
        endNode = getCurrent('Current_Project_Name');
    else
        endNode = getCurrent('Current_Analysis');
    end
    G2 = getAllObjsLinksInContainer(G, endNode, 'up'); % Nodes upstream from the specified node.
    H2 = transclosure(G2); % Downstream connections within this container
    R2 = full(adjacency(H2));
    for i=1:size(R2,1)
        R2(i,i)=1; % Include the base node
    end
    if ismember(origType,{'VR','PR','PG'})                
        uuidIdx = ismember(G2.Nodes.Name, origUUID);
        downstreamIdx = any(logical(R2(uuidIdx,:)),1);        
        uuids = G2.Nodes.Name(downstreamIdx); % Downstream nodes. NOTE: Views not included because not downstream.
    elseif isequal(origType,'VW') 
        uuids = {origUUID}; % Just the view object that copyToNew was called in reference to.
    else% LG, PJ, AN
        uuids = G2.Nodes.Name;
    end    
else % Not creating a new analysis (propagating changes) so just get the immediate successor objects.
    uuids = {origUUID};
    if ismember(origType,{'VR','PR'})
        succs = successors(G, origUUID); % The immediate successors.
        uuids = [uuids; succs];
    end
end

% 1. Create new UUID's and copy the objects to them.
newUUIDs = cell(size(uuids));
for i=1:length(newUUIDs)
    [type, abstractID] = deText(uuids{i});
    instanceID = createID_Instance(abstractID, type);
    newUUIDs{i} = genUUID(type, abstractID, instanceID);
    a = loadJSON(uuids{i});
    a.UUID = newUUIDs{i};
    saveClass(a); % Insert the newly renamed object into the database.
end

% 2. Link together the new UUID's in the same way as the original UUID's
% (all nodes within the G2 graph)
edgesIdx = ismember(G.Edges.EndNodes(:,1), uuids) & ismember(G.Edges.EndNodes(:,2), uuids);
edgeTable = G.Edges.EndNodes(edgesIdx,:);
for i=1:length(uuids)
    idx1 = ismember(edgeTable(:,1), uuids{i});
    idx2 = ismember(edgeTable(:,2), uuids{i});
    edgeTable(idx1,1) = newUUIDs{i};    
    edgeTable(idx2,2) = newUUIDs{i};
end
for i=1:size(edgeTable,1)
    linkObjs(edgeTable{i,1},edgeTable{i,2});
end

% 3. Link the new UUID with: (connect the new nodes to the existing graph)
%   original predecessors only (PR)
%   original successors only (VW)
%   none (LG, PJ, ST, VR)
%   original predecessor and successors (PG, AN)
preds = {}; succs = {};
if ismember(origType,{'PG','AN','PR'})
    preds = predecessors(G,origUUID);    
end
if ismember(origType,{'PG','AN','VW'})
    succs = successors(G,origUUID);
end
reconnects = [preds; succs];

% Get the new UUID of the original UUID, and connect it to the same things
% as the original UUID is.
origUUIDIdx = ismember(uuids,origUUID);
newUUID = newUUIDs(origUUIDIdx);
for i=1:length(reconnects)
    linkObjs(reconnects, newUUID); % Important that newUUID be on the right, because position matters for the VR_PR table. All the rest will reorder accordingly.
end