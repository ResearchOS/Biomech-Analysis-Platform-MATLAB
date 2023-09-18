function []=fillUITree(fig, class, uiTree, searchTerm, sortDropDown)

%% PURPOSE: FILL IN THE UI TREE.

global conn;

delete(uiTree.Children);

tablename = getTableName(class);

sqlquery = ['SELECT UUID, Name FROM ' tablename ';'];
t = fetch(conn,sqlquery);
t = table2MyStruct(t);

if ~iscell(t.UUID)
    t.UUID = {t.UUID};
    t.Name = {t.Name};
end

allUUIDs = t.UUID;
allNames = t.Name;

%% Get the list of all objects of the current type in the current project
if ~contains(tablename,{'Project'})
    O = getAllObjLinks();

    % Work backwards to get the "main branch" of objects leading to this
    % Project.
    H = transclosure(flipedge(O));
    Current_Project_Name = getCurrent('Current_Project_Name');
    projIdx = ismember(O.Nodes.Name,Current_Project_Name);
    R = full(adjacency(H));
    for i=1:length(R)
        R(i,i) = 1; % Insert 1's on the main diagonal, indicating that nodes are reachable from themselves.
    end
    % Objects currently or previously on the "main branch" that connects to this project OR never associated with any project at all.
    inclIdx = projIdx | (indegree(O)==0 & outdegree(O)==0);
    allObjsInst = O.Nodes.Name(any(logical(R(inclIdx,:)),1));

    type = className2Abbrev(class);
    allObjsInst = allObjsInst(contains(allObjsInst,type));

    % Now, work forwards to get all reachable objects from the "main
    % branch" (this includes outputs that aren't used, and therefore are
    % offshoots from the "main branch"). By definition, these branches
    % terminate before reaching a "Project" node (or they would have been
    % caught above)
    H2 = transclosure(O);
    R = full(adjacency(H2));
    for i=1:length(R)
        R(i,i) = 1;
    end    
    idx = ismember(O.Nodes.Name,allObjsInst);
    inclIdx = logical(any(R(idx,:),1));
    offBranchObjsInst = O.Nodes.Name(inclIdx);    
    offBranchObjsInst = offBranchObjsInst(contains(offBranchObjsInst,type));

    allObjsInst = unique([allObjsInst; offBranchObjsInst],'stable'); % Append

    [types, abstractIDs] = deText(allObjsInst);
    abstractUUIDs = genUUID(types, abstractIDs);
    allUUIDsIdx = ismember(allUUIDs,abstractUUIDs);

    allUUIDs = allUUIDs(allUUIDsIdx);
    allNames = allNames(allUUIDsIdx);
end

%% Get the list of the objects that match the search term.
searchIdx = contains(allNames,searchTerm);
allSearchResults=allNames(searchIdx); % Include only the nodes that match the search term
allUUIDs=allUUIDs(searchIdx);

selNode=uiTree.SelectedNodes; % Get the currently selected node.

%% Create nodes in the UI tree for the new instances, and add their properties. If it would be filtered out, it will not appear here.
childIdx=0;
allTextsNoVis=allNames; % Includes class variable instances that are not visible.
for i=1:length(allSearchResults) % Iterate over all of the sibling nodes.    

    idx=ismember(allTextsNoVis,allSearchResults{i});

    addNewNode(uiTree, allUUIDs{i}, allSearchResults{i}, false);

    childIdx=childIdx+1;

end

%% Sort the nodes based on how it was specified.
if exist('sortDropDown','var')==1
    sortMethod=sortDropDown.Value;
    sortUITree(uiTree, sortMethod);
end

if isempty(uiTree.Children)
    return; % No nodes!
end

if isempty(selNode)
    selNode = uiTree.Children(1);
end

selectNode(uiTree, selNode.NodeData.UUID);

%% ADD THE PROJECT-SPECIFIC VERSIONS TO THE UI TREE
fillUITree_PS(fig, class, uiTree, allUUIDs);