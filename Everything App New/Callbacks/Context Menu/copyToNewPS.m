function []=copyToNewPS(src, event)

%% PURPOSE: COPY THE SPECIFIED PS STRUCT TO A NEW PS STRUCT.

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

%% 1. Get all of the things that this object is connected to, store as edge table.
edgesIdx = ismember(globalG.Edges.EndNodes(:,1),uuid) | ismember(globalG.Edges.EndNodes(:,2),uuid);
edgesTable = globalG.Edges(edgesIdx,:);

%% 2. Create another instance, save it as a copy.
prev = loadJSON(uuid);
[type, abstractID] = deText(uuid);
instanceID = createID_Instance(abstractID, type);
newUUID = genUUID(type, abstractID, instanceID);
name = promptName('Enter New Name',prev.Name);
if isempty(name)
    return;
end
prev.UUID = newUUID;
prev.Name = name;
nodeIdx = ismember(globalG.Nodes.Name,uuid);
nodeTable = globalG.Nodes(nodeIdx,:);
nodeTable.Name = {newUUID};
tmpG = addnode(globalG, nodeTable);

%% 3. Replace the old UUID with the new UUID in the edges table.
col1Idx = ismember(edgesTable.EndNodes(:,1),uuid);
col2Idx = ismember(edgesTable.EndNodes(:,2),uuid);
edgesTable.EndNodes(col1Idx,1) = {newUUID};
edgesTable.EndNodes(col2Idx,2) = {newUUID};
tmpG = addedge(tmpG, edgesTable);

if ~isdag(tmpG)
    disp('Cannot copy object as it creates a cyclic graph');
    return;
end
saveObj(prev); % Saves new nodes to SQL and digraph.
linkObjs(edgesTable); % Saves new edges to SQL and digraph.

%% 4. Update the GUI.
uiTree = getUITreeFromNode(selNode);
switch uiTree
    case handles.Process.analysisUITree
        fillAnalysisUITree(fig);
    case handles.Process.groupUITree
        pgUUID = getCurrentProcessGroup(fig);
        fillProcessGroupUITree(fig, uuid, pgUUID);
    case handles.Process.functionUITree
        disp('Cannot copy variables in this UI tree!');
    otherwise        
        fillUITree(fig, type, uiTree, ''); % Search term should be re-implemented at a later date.
end
selectNode(uiTree, newUUID);

Current_View = getCurrent('Current_View');
struct = loadJSON(Current_View);
if ismember(uuid, struct.InclNodes)
    addToViewButtonPushed(fig);    
end



%% 5. Commit the changes in SQL and the digraph.


% newUUIDs = copyToNew(uuid); % By default, not creating a whole new analysis. In the future, ask the user (or have a default setting)
% 


% 
% refreshDigraph(fig);
% 
% currentProjectButtonPushed(fig);