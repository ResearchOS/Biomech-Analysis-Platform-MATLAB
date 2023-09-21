function [newUUID] = copyToNew(origUUID, newVersion)

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

global conn;

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
        succs(~contains(succs,'VR')) = []; % Only create a new variable, if not creating new analysis.
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
    edgeTable(idx1,1) = newUUIDs(i);    
    edgeTable(idx2,2) = newUUIDs(i);
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
if ismember(origType,{'PG','AN','VW','PR'})
    succs = successors(G,origUUID);
    succs(contains(succs,'VR')) = []; % Remove output VR.
end
reconnects = [preds; succs];

% Get the new UUID of the original UUID, and connect it to the same things
% as the original UUID is.
origUUIDIdx = ismember(uuids,origUUID);
newUUID = newUUIDs{origUUIDIdx};
for i=1:length(reconnects)
    linkObjs(reconnects{i}, newUUID); % Important that newUUID be on the right, because position matters for the VR_PR table. All the rest will reorder accordingly.
end

%% If copying a PR, also do the following: 
% 1. Copy the input VR's names in code (same VR UUID's, new PR UUID)
% 2. Copy the output VR's names in code (new PR UUID, new VR UUID)
if ~isequal(origType,'PR')
    return;
end

%% Inputs
% The links for the old VR's to the old PR.
prevVRs = preds(contains(preds,'VR'));
vrStr = getCondStr(prevVRs);
sqlquery = ['SELECT VR_ID, NameInCode, Subvariable FROM VR_PR WHERE VR_ID IN ' vrStr ' AND PR_ID = ''' origUUID ''';'];
t = fetch(conn, sqlquery);
tOldPR = table2MyStruct(t);

% The links for the old VR's to the new PR.
sqlquery = ['SELECT VR_ID FROM VR_PR WHERE VR_ID IN ' vrStr ' AND PR_ID = ''' newUUID ''';'];
t = fetch(conn, sqlquery);
tNewPR = table2MyStruct(t);

% Put the new VR UUID's in the same order as the VR's came back from the
% SQL database
% newVRs = reconnects(contains(reconnects,'VR'));
idx = makeSameOrder(tNewPR.VR_ID, tOldPR.VR_ID);
oldVrs = tOldPR.VR_ID(idx);
oldNamesInCode = tOldPR.NameInCode(idx);
oldSubvars = tOldPR.Subvariable(idx);

for i=1:length(oldVrs)
    sqlquery = ['UPDATE VR_PR SET NameInCode = ''' oldNamesInCode{i} ''', Subvariable = ''' oldSubvars{i} ''' WHERE VR_ID = ''' oldVrs{i} ''' AND PR_ID = ''' newUUID ''';'];
    execute(conn, sqlquery);
end
