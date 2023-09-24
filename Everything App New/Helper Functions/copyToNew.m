function [newUUIDs] = copyToNew(uuids)

%% PURPOSE: COPY A NODE AND ALL OF ITS DIRECT PREDECESSORS TO NEW VERSIONS.

global globalG;

% The graph with uuids to rename (only where the edge contains 2 UUID's to replace)
tmpG = subgraph(globalG, uuids);

% 1. Create new UUID's and copy the objects to them.
for i=1:length(uuids)
    [type, abstractID] = deText(tmpG.Nodes.Name{i});
    instanceID = createID_Instance(abstractID, type);
    tmpG.Nodes.Name{i} = genUUID(type, abstractID, instanceID);
end
newUUIDs = tmpG.Nodes.Name;

% 2. Find all the edges in globalG with only ONE node being
% replaced.
col1idx = ismember(globalG.Edges.EndNodes(:,1),uuids) & ~ismember(globalG.Edges.EndNodes(:,2),uuids);
col2idx = ismember(globalG.Edges.EndNodes(:,2),uuids) & ~ismember(globalG.Edges.EndNodes(:,1),uuids);
EndNodes = globalG.Edges.EndNodes(col1idx | col2idx,:);

% 3. Replace the one node in each edge.
for i=1:size(newUUIDs)
    idx1 = ismember(EndNodes(:,1),newUUIDs{i});
    idx2 = ismember(EndNodes(:,2),newUUIDs{i});
    EndNodes(idx1,1) = newUUIDs(i);
    EndNodes(idx2,2) = newUUIDs(i);
end

% 4. Add those edges to tmpG.
edgeTable = table(EndNodes);
tmpG = addedge(tmpG, edgeTable);

% 5. Add tmpG to the globalG.
tmp_globalG = digraph([globalG.Edges; tmpG.Edges]);

assert(isdag(tmp_globalG));

% 6. Create the new uuids & links
for i=1:length(newUUIDs)
    a = loadJSON(uuids{i});
    a.UUID = newUUIDs{i};
    saveClass(a); % Insert the newly renamed object into the database.
end
for i=1:size(tmpG.Edges.EndNodes,1)
    linkObjs(tmpG.Edges.EndNodes{i,1},tmpG.Edges.EndNodes{i,2});
end
globalG = tmp_globalG;












% %% If copying a PR, also do the following:
% % 1. Copy the input VR's names in code (same VR UUID's, new PR UUID)
% % 2. Copy the output VR's names in code (new PR UUID, new VR UUID)
% if ~isequal(origType,'PR')
%     return;
% end
% 
% %% Inputs
% % The links for the old VR's to the old PR.
% for uuidNum=1:length(allUUIDs)
%     prevVRs = preds(contains(preds,'VR'));
%     vrStr = getCondStr(prevVRs);
%     sqlquery = ['SELECT VR_ID, NameInCode, Subvariable FROM VR_PR WHERE VR_ID IN ' vrStr ' AND PR_ID = ''' allUUIDs{uuidNum} ''';'];
%     t = fetch(conn, sqlquery);
%     tOldPR = table2MyStruct(t);
%     if isempty(fieldnames(tOldPR))
% 
%     end
%     if ~iscell(tOldPR.VR_ID)
%         tOldPR.VR_ID = {tOldPR.VR_ID};
%         tOldPR.NameInCode = {tOldPR.NameInCode};
%         tOldPR.Subvariable = {tOldPR.Subvariable};
%     end
% 
%     % The links for the old VR's to the new PR.
%     sqlquery = ['SELECT VR_ID FROM VR_PR WHERE VR_ID IN ' vrStr ' AND PR_ID = ''' newUUID ''';'];
%     t = fetch(conn, sqlquery);
%     tNewPR = table2MyStruct(t);
%     if isempty(fieldnames(tNewPR))
% 
%     end
%     if ~iscell(tNewPR.VR_ID)
%         tNewPR.VR_ID = {tNewPR.VR_ID};
%     end
% 
%     % Put the new VR UUID's in the same order as the VR's came back from the
%     % SQL database
%     % newVRs = reconnects(contains(reconnects,'VR'));
%     idx = makeSameOrder(tNewPR.VR_ID, tOldPR.VR_ID);
%     oldVrs = tOldPR.VR_ID(idx);
%     oldNamesInCode = tOldPR.NameInCode(idx);
%     oldSubvars = tOldPR.Subvariable(idx);
% 
%     for i=1:length(oldVrs)
%         sqlquery = ['UPDATE VR_PR SET NameInCode = ''' oldNamesInCode{i} ''', Subvariable = ''' oldSubvars{i} ''' WHERE VR_ID = ''' oldVrs{i} ''' AND PR_ID = ''' newUUID ''';'];
%         execute(conn, sqlquery);
%     end
% end