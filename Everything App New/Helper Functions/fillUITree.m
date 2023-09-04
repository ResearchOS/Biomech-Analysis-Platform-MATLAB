function []=fillUITree(fig, class, uiTree, searchTerm, sortDropDown)

%% PURPOSE: FILL IN THE UI TREE.

global conn;

delete(uiTree.Children);

tablename = getTableName(class);
sqlquery = ['SELECT UUID, Name FROM ' tablename ';'];
t = fetch(conn,sqlquery);
t = table2MyStruct(t);

allUUIDs = t.UUID;
allNames = t.Name;

%% Get the list of all objects of the current type in the current analysis
O = getObjLinks();
H = transclosure(flipedge(O));
Current_Analysis = getCurrent('Current_Analysis');
anIdx = ismember(O.Nodes.Name,Current_Analysis);
R = full(adjacency(H));
allObjsInst = O.Nodes.Name(any(logical(R(anIdx,:)),1));

type = className2Abbrev(class);
allObjsInst = allObjsInst(contains(allObjsInst,type));

[types, abstractIDs] = deText(allObjsInst);
abstractUUIDs = genUUID(types, abstractIDs);
allUUIDsIdx = ismember(allUUIDs,abstractUUIDs);

allUUIDs = allUUIDs(allUUIDsIdx);
allNames = allNames(allUUIDsIdx);

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
fillUITree_PS(fig, class, uiTree, allObjsInst);