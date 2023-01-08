function []=fillProcessGroupUITree(src)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNodeAllGroups=handles.Process.allGroupsUITree.SelectedNodes;

fullPath=getClassFilePath(selNodeAllGroups);
struct=loadJSON(fullPath);

list=struct.ExecutionList;

types=list(:,1); % Process functions or groups
names=list(:,2); % The names of each function/group

uiTree=handles.Process.groupUITree;
nodes=uiTree.Children;
if ~isempty(nodes)
    currNodesTexts={nodes.Text};
else
    currNodesTexts={};
end

if isempty(list)
    delete(uiTree.Children);
    return;
end

selNode=uiTree.SelectedNodes;
selNodeIdx=ismember(uiTree.Children,selNode);
selNodeIdxNum=find(selNodeIdx==1);
if isempty(selNodeIdxNum)
    selNodeIdxNum=1;
end

for i=1:length(names)

    if ismember(names{i},currNodesTexts)
        if 
end