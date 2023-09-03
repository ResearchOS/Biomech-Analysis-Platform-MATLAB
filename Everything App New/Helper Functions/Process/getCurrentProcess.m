function [Current_Process_Name] = getCurrentProcess(src)

%% PURPOSE: GET THE CURRENT PROCESS SELECTED IN THE CURRENT GROUP UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.groupUITree.SelectedNodes;
Current_Process_Name = '';
if isempty(selNode)    
    return;
end

[~,list] = getUITreeFromNode(selNode);
for i=1:length(list)
    uuid = list(i).NodeData.UUID;
    if contains(uuid,'PR')
        Current_Process_Name = uuid;
        return;
    end
end