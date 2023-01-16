function []=fillUITree(fig, class, uiTree, searchTerm, sortDropDown)

%% PURPOSE: FILL IN THE UI TREE.

slash=filesep;
commonPath=getCommonPath(fig);
classFolder=[commonPath slash class];
classVar=loadClassVar(fig,classFolder);
handles=getappdata(fig,'handles');

%% Get all of the existing nodes' text. The node text is equal to its file name.
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
isVis=[classVar.Visible];
allTexts={classVar.Text}; % Has the existing node texts and the ones to be added already in it.
allTexts=allTexts(isVis);
allSearchResults=allTexts(contains(allTexts,searchTerm)); % Include only the nodes that match the search term

selNode=uiTree.SelectedNodes; % Get the currently selected node.
selNodeIdx=ismember(uiTree.Children,selNode); % The index of the currently selected node
selNodeIdxNum=find(selNodeIdx==1);
if isempty(selNodeIdxNum)
    selNodeIdxNum=1;
end

%% Delete all of the nodes that don't match the search results right off the bat. If no search term, nothing will be deleted.
notInSearchResultsIdx=~ismember(currNodesTexts,allSearchResults);
delete(uiTree.Children(notInSearchResultsIdx));

%% Create nodes in the UI tree for the new instances, and add their properties. If it would be filtered out, it will not appear here.
checkedIdx=false(length(allSearchResults),1);
childIdx=0;
allTextsNoVis={classVar.Text}; % Includes class variable instances that are not visible.
for i=1:length(allSearchResults) % Iterate over all of the sibling nodes.    

    idx=ismember(allTextsNoVis,allSearchResults{i});

    % If deleting an existing node. Otherwise, doesn't touch existing nodes.
    if ismember(allSearchResults{i},currNodesTexts)
        if classVar(idx).Visible==0
            currNode=findobj(uiTree.Children,'Text',allSearchResults{i});
            if isequal(currNode,selNode)
                selNode=[]; % Make selNode empty so that a new node will be selected and the selectionChangedFcn will trigger.
            end
            delete(currNode);
        end
        continue;
    end

    newNode=uitreenode(uiTree,'Text',allSearchResults{i});

    newNode.ContextMenu=handles.Process.commonContextMenu;

    childIdx=childIdx+1;
    
    if classVar(idx).Checked        
        checkedIdx(childIdx)=true;
    end

end

%% Check the appropriate nodes.
if any(checkedIdx)
    uiTree.CheckedNodes=uiTree.Children(checkedIdx);
end

%% Sort the nodes based on how it was specified.
sortMethod=sortDropDown.Value;
sortUITree(uiTree, sortMethod);

% selNode is empty if the selected node was just removed. It's not empty if
% a new node was just added.
if ~isempty(uiTree.Children)
    if isempty(selNode) && ~isempty(selNodeIdxNum)
        uiTree.SelectedNodes=uiTree.Children(selNodeIdxNum);
    elseif isempty(selNode) % Startup
        uiTree.SelectedNodes=uiTree.Children(1);
    end
end

%% ADD THE PROJECT-SPECIFIC VERSIONS TO THE UI TREE
if isequal(class,'Project')
    return;
end

fillUITree_PS(fig, class, uiTree);