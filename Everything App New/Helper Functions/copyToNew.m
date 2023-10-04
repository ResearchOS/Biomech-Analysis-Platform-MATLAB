function [newUUIDs] = copyToNew(uuids)

%% PURPOSE: COPY NODES TO NEW VERSIONS

global globalG;

if ~iscell(uuids)
    uuids = {uuids};
end

% The graph containing only uuids to rename
tmpG = subgraph(globalG, uuids);

% 1. Create new UUID's and copy the objects' UUID's to them.
for i=1:length(uuids)
    [type, abstractID] = deText(tmpG.Nodes.Name{i});
    instanceID = createID_Instance(abstractID, type);
    tmpG.Nodes.Name{i} = genUUID(type, abstractID, instanceID);
end
newUUIDs = tmpG.Nodes.Name;

% 2. Find all the edges in globalG with only ONE node being replaced.
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

% 5. Add tmpG to the tmp_globalG.
tmp_globalG = digraph([globalG.Edges; tmpG.Edges]);

assert(isdag(tmp_globalG));

%% Put the changes in SQL
% 6. Create the new uuids & links
for i=1:length(newUUIDs)
    a = loadJSON(uuids{i});
    a.UUID = newUUIDs{i};
    saveClass(a); % Insert the newly renamed object into the database.
end
for i=1:size(tmpG.Edges.EndNodes,1)
    linkObjs(tmpG.Edges.EndNodes{i,1},tmpG.Edges.EndNodes{i,2});
end