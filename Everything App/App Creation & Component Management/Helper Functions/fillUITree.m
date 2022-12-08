function []=fillUITree(fig, class, uiTree, searchTerm)

%% PURPOSE: FILL IN THE UI TREE.
% NOTE: THIS FUNCTION CURRENTLY ONLY IS SET TO ADD NEW NODES. IT IS
% CURRENTLY INCAPABLE OF REMOVING THEM.

classVar=getappdata(fig,class); % Get the variable that stores all instances of a specific class.

%% Get all of the existing nodes' text. The node text is equal to its file name.
nodes=uiTree.Children;
if ~isempty(nodes)
    currNodesTexts={nodes.Text};
else
    currNodesTexts={};   
end

%% Create folders for each node based on selections. Or just be a filter?
% Per-project folders (for all types)
% Plots: plot level, plot type (user-defined?)
% Variables: variable size/class (scalar, matrix, char, hard-coded)
% Components: component type, plot level
% Stats: 

if isempty(classVar)
    delete(uiTree.Children); % Just triple checking that there are no nodes in the box when there are no files present.
    return;
end

if exist('searchTerm','var')~=1
    searchTerm='';
end

%% Get the list of all files
allTexts={classVar.Texts}; % Has the existing node texts and the ones to be added already in it.
allSearchResults=allTexts(contains(allTexts,searchTerm)); % Include only the nodes that match the search term
newTexts=allSearchResults(~ismember(allSearchResults,currNodesTexts)); % Exclude the entries that are already in the ui tree

if isempty(newTexts)
    return; % Nothing new being added here.
end

[~,a,~]=intersect(newTexts,allSearchResults); % Get the indices of the new texts.

selNode=uiTree.SelectedNodes; % Get the currently selected node.

%% Delete all of the nodes that don't match the search results right off the bat. If no search term, nothing will be deleted.
notInSearchResultsIdx=~ismember(currNodesTexts,allSearchResults);
delete(uiTree.Children(notInSearchResultsIdx));

%% Create nodes in the UI tree for the new instances, and add their properties. If it would be filtered out, it will not appear here.
for i=1:length(allSearchResults) % Iterate over all of the sibling nodes.    

    if ismember(allSearchResults{i},currNodesTexts) % If deleting an existing node. Otherwise, don't touch existing nodes.
        if classVar(i).Visible==0
            currNode=findobj(uiTree.Children,'Text',allSearchResults{i});
            if isequal(currNode,selNode)
                selNode=[]; % Make selNode empty so that a new node will be selected and the selectionChangedFcn will trigger.
            end
            delete(currNode);
        end
        continue;        
    end
    newNode=uitreenode(uiTree,'Text',allSearchResults{i});

    newNodeStruct=classVar(a(i)); % The struct for the current instance of the class
    nodeProps=fieldnames(newNodeStruct);
    nodeProps=nodeProps(~ismember(nodeProps,{'Children','Text'}));

    for j=1:length(nodeProps)
        newNode.(nodeProps{j})=newNodeStruct.(nodeProps{j}); % Store all of the class's properties to the node.
    end
    if i==1 && isempty(selNode)
        uiTree.SelectedNodes=newNode; % Set the currently selected node if there was none selected before.
        feval(uiTree.SelectionChangedFcn,uiTree); % Run the selection changed function because a new node was selected
    end
end

%% Sort the nodes based on how it was specified.
sortUITree(uiTree);
