function [proceed]=deleteNode(selNode)

%% PURPOSE: DELETE THE SELECTED NODE, AND UPDATE THE OTHER CURRENT UI TREES ACCORDINGLY, AS NECESSARY.

proceed = true;
fig=ancestor(selNode,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = getUITreeFromNode(selNode);

idxNum = find(ismember(uiTree.Children,selNode)==1,1,'last');

if isempty(idxNum)
    disp('Cannot delete a group node in the analysis window, or a subgroup node in the group window!')
    proceed = false;
    return;
end
idxNum = max([1 idxNum-1]); % Always >=1, selects the node just before the one to be deleted.

delete(selNode);

children = uiTree.Children;

if ~isempty(children)
    newNode = uiTree.Children(idxNum);
    selectNode(uiTree, newNode.NodeData.UUID);
end

if isequal(uiTree, handles.Process.analysisUITree)
    fillProcessGroupUITree(fig);
else
    fillCurrentFunctionUITree(fig);
end
