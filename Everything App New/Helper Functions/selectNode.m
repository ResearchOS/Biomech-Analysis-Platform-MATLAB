function [selNode]=selectNode(uiTree,uuid)

%% PURPOSE: SELECT THE NODE WITH THE CORRESPONDING UUID. Also runs the selection changed function!

if isempty(uuid)
    selNode=[];
    uiTree.SelectedNodes=selNode;
    return;
end

selNode = getNode(uiTree, uuid); % The heavy lifting to select the proper node.
uiTree.SelectedNodes=selNode;

fig=ancestor(uiTree,'figure','toplevel');
% feval(uiTree.SelectionChangedFcn, fig);