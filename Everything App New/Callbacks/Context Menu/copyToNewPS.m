function [newUUID]=copyToNewPS(src, args)

%% PURPOSE: COPY THE SPECIFIED OBJECT TO A NEW OBJECT, MAINTAINING CONNECTIONS TO OTHER OBJECTS.
% MULTIPLE TYPES OF COPIES:
% 1. COPY TO NEW ANALYSIS (CREATES NEW UUID). MAINTAIN ALL PREVIOUS CONNECTIONS UP AND DOWN
% STREAM.
    % Why would I want to do this? I've done it with copying an analysis
    % within the same project, which is like #4.
% 2. COPY TO NEW ANALYSIS. MAINTAIN ALL PREVIOUS CONNECTIONS UP STREAM, AND DOWN STREAM 
% EXCEPT FOR ONES THAT LEAD TO OTHER AN (IN FUTURE, MAYBE SELECT WHICH AN CONNECTIONS TO PRESERVE IF WANT
% CHANGES TO AFFECT E.G. 2/N ANALYSES.
    % Likely the most common. Any time a node being modified is common to
    % multiple analyses (or projects)
% 3. COPY WHILE KEEPING THE SAME ANALYSES. USEFUL WHEN CREATING MANY
% REPETITIONS OF AN OBJECT (E.G. PR INSTANCE)

% NOTE: COPIES CAN BE OF 1+ NODES. IN THE CASE OF 2+ NODES, MAINTAIN THE
% INTERNAL-RELATIONSHIPS.

% 4. Copy analysis to same project.
% 5. Copy analysis to new project (existing or not).
% Functionality I am purposefully not implementing: copy all objects in a
% container to new UUID's. That goes against the purpose of sharing all
% upstream objects while they haven't been changed/are common to multiple
% upstream nodes.
% 6. Copy analysis to new project. In this case there are not nodes common
% to multiple analyses, but common to one analysis in multiple projects.

% NOTE 2: There is also the "copyToNew.m" that already has some of the
% logic for maintaining internal relationships.

% NOTE 3: Sometimes, "copy to new" really means "only make changes to the
% current (pre-existing) analysis". How to manage that?

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uuid=args.UUID;
newANBool = true;
rmANBool = true; % By default, remove the previous analysis.
if isfield(args,'rmAN')
    rmANBool = args.rmAN;
end
if isfield(args,'newANBool')
    newANBool = args.newAN;
end
% The connection to remove from the copied object. This is for duplicating
% an object into a new analysis, then removing the connection to the
% previous analysis.
anList = getObjs(uuid, {'AN'}, 'down', globalG);
Current_Analysis = getCurrent('Current_Analysis');
anList(ismember(anList,Current_Analysis)) = [];

%% 1. Get all of the things that this object is connected to, store as edge table.
edgesIdx = ismember(globalG.Edges.EndNodes(:,1),uuid) | ismember(globalG.Edges.EndNodes(:,2),uuid);
edgesTable = globalG.Edges(edgesIdx,:);

%% 2. If removing analyses, then remove all of the new node's edges to nodes that are in other analyses.
% AND remove all of the old node's edges to nodes in this analysis.
if rmANBool    
    % Edges to this analysis only. Ready to be replaced with new UUID.
    % Need to ensure that the nodes upstream are not removed, because they
    % shouldn't be affected by this copy.
    otherANNodes = getReachableNodes(globalG, anList, 'up');
    edgesTable(ismember(edgesTable.EndNodes(:,2),otherANNodes),:) = [];

    currANNodes = getReachableNodes(globalG, Current_Analysis, 'up');
    rmEdgesIdx = ismember(globalG.Edges.EndNodes(:,1),uuid) & ismember(globalG.Edges.EndNodes(:,2),currANNodes); % The edges to the current analysis to remove
    rmEdgesTable = globalG.Edges(rmEdgesIdx,:); % The edges to remove.    
end

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

idxNums = find(ismember(tmpG.Edges.EndNodes(:,1), rmEdgesTable.EndNodes(:,1)) & ...
    ismember(tmpG.Edges.EndNodes(:,2), rmEdgesTable.EndNodes(:,2)));

if ~isdag(tmpG)
    disp('Cannot copy object as it creates a cyclic graph');
    return;
end
saveObj(prev); % Saves new nodes to SQL and digraph.
linkObjs(edgesTable); % Saves new edges to SQL and digraph.

%% 5. Unlink the old edges.
if rmANBool
    unlinkObjs(rmEdgesTable.EndNodes(:,1), rmEdgesTable.EndNodes(:,2));
end