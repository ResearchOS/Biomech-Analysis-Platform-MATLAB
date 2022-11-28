function []=fillUITree(classFolder, uiTree)

%% PURPOSE: FILL IN THE UI TREE.
% NOTE: THIS FUNCTION CURRENTLY ONLY IS SET TO ADD NEW NODES. IT IS
% CURRENTLY INCAPABLE OF REMOVING THEM.

slash=filesep;
pathSplit=strsplit(classFolder,slash);
class=pathSplit{end}; % The name of the current class folder.

% Get all of the existing nodes' text
nodes=uiTree.Children;
if ~isempty(nodes)
    texts={nodes.Text};
else
    texts={};
end

%% Sort the nodes. For now, just alphabetically, but in the future allow options.
newTexts={newNodes.Text};
allTexts=[texts newTexts];
[~,idx]=sort(upper(allTexts));
allTexts=allTexts(idx);
[~,a,b]=intersect(newTexts,allTexts); % NEED TO FIX THIS LINE AFTER I GET DATA!

for i=1:length(newNodes) % Iterate over all of the sibling nodes.    
    newNode=uitreenode(uiTree,nodes(i),'after','Text',newTexts{i});
    nodeProps=fieldnames(newNodes{i});
    nodeProps=nodeProps(~ismember(nodeProps,{'Children','Text'}));
    for j=1:length(nodeProps)
        newNode.(nodeProps{j})=newNodes{i}.(nodeProps{j}); % Store all of the class's properties to the node.
    end
    if i==1
        uiTree.SelectedNodes=newNode;
    end
end