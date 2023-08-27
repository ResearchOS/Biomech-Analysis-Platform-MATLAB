function []=fillUITree(fig, class, uiTree, searchTerm, sortDropDown)

%% PURPOSE: FILL IN THE UI TREE.

global conn;

delete(uiTree.Children);

tablename = getTableName(class);
sqlquery = ['SELECT UUID, Name FROM ' tablename ';'];
t = fetch(conn,sqlquery);
zIdx = contains(t.UUID,'ZZZ');
t(zIdx,:) = []; % ALWAYS REMOVE THE ZZZ ROW.

allUUIDs = cellstr(t.UUID);
allNames = cellstr(t.Name);

%% Get the list of all files
searchIdx = contains(allNames,searchTerm);
allSearchResults=allNames(searchIdx); % Include only the nodes that match the search term
allUUIDs=allUUIDs(searchIdx);

selNode=uiTree.SelectedNodes; % Get the currently selected node.

%% Delete all of the nodes that don't match the search results right off the bat. If no search term, nothing will be deleted.
% notInSearchResultsIdx=~ismember(currNodesTexts,allSearchResults);
% delete(uiTree.Children(notInSearchResultsIdx));

%% Create nodes in the UI tree for the new instances, and add their properties. If it would be filtered out, it will not appear here.
% checkedIdx=false(length(allSearchResults),1);
childIdx=0;
allTextsNoVis=allNames; % Includes class variable instances that are not visible.
for i=1:length(allSearchResults) % Iterate over all of the sibling nodes.    

    idx=ismember(allTextsNoVis,allSearchResults{i});

    % If deleting an existing node. Otherwise, doesn't touch existing nodes.
%     if ismember(allSearchResults{i},currNodesTexts)
%         currNode=findobj(uiTree.Children,'Text',allSearchResults{i});
%         if isequal(currNode,selNode)
%             selNode=[]; % Make selNode empty so that a new node will be selected and the selectionChangedFcn will trigger.
%         end
%         delete(currNode);
%         continue;
%     end

    addNewNode(uiTree, allUUIDs{i}, allSearchResults{i}, false);

    childIdx=childIdx+1;
    
%     if classVar(idx).Checked        
%         checkedIdx(childIdx)=true;
%     end

end

%% Check the appropriate nodes.
% if any(checkedIdx)
%     uiTree.CheckedNodes=uiTree.Children(checkedIdx);
% end

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
fillUITree_PS(fig, class, uiTree);