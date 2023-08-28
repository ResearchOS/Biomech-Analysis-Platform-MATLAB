function [Current_ProcessGroup_Name]=getCurrentProcessGroup(src)

%% PURPOSE: RETURN THE CURRENT PROCESS GROUP UUID AS SELECTED IN THE GUI.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.analysisUITree.SelectedNodes;
Current_ProcessGroup_Name = '';
if isempty(selNode)    
    return;
end

list = getUITreeFromNode(selNode);
for i=1:length(list)
    uuid = list(i).NodeData.UUID;
    if contains(uuid,'PG')
        Current_ProcessGroup_Name = uuid;
        return;
    end
end