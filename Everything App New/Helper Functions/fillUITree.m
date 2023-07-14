function []=fillUITree(fig, class, uiTree, searchTerm, sortDropDown)

%% PURPOSE: FILL IN THE UI TREE.

delete(uiTree.Children);

slash=filesep;
commonPath=getCommonPath();
classFolder=[commonPath slash class];
classVar=loadClassVar(classFolder);
handles=getappdata(fig,'handles');

%% Get all of the existing nodes' text. The node text is the ".Text" field of the struct
nodes=uiTree.Children;
if ~isempty(nodes)
    currNodesTexts={nodes.Text};
else
    currNodesTexts={};   
end

if isempty(classVar)
    delete(uiTree.Children); % Just triple checking that there are no nodes in the box when there are no files present.
    return;
end

if exist('searchTerm','var')~=1
    searchTerm='';
end

%% Get the list of all files
% isVis=[classVar.Visible];
allTexts={classVar.Text}; % Has the existing node texts and the ones to be added already in it.
% allTexts=allTexts(isVis);
allUUIDs = {classVar.UUID};
% allUUIDs=allUUIDs(isVis);
searchIdx = contains(allTexts,searchTerm);
allSearchResults=allTexts(searchIdx); % Include only the nodes that match the search term
allUUIDs=allUUIDs(searchIdx);

selNode=uiTree.SelectedNodes; % Get the currently selected node.

%% Delete all of the nodes that don't match the search results right off the bat. If no search term, nothing will be deleted.
% notInSearchResultsIdx=~ismember(currNodesTexts,allSearchResults);
% delete(uiTree.Children(notInSearchResultsIdx));

%% Create nodes in the UI tree for the new instances, and add their properties. If it would be filtered out, it will not appear here.
% checkedIdx=false(length(allSearchResults),1);
childIdx=0;
allTextsNoVis={classVar.Text}; % Includes class variable instances that are not visible.
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

    addNewNode(uiTree, allUUIDs{i}, allSearchResults{i});

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