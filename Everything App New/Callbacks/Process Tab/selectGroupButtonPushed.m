function []=selectGroupButtonPushed(src,event)

%% PURPOSE: SELECT THE CURRENTLY SELECTED GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(groupNode)
    return;
end

Current_ProcessGroup_Name=groupNode.Text;

rootSettingsFile=getRootSettingsFile();

save(rootSettingsFile,'Current_ProcessGroup_Name','-append');

handles.Process.currentGroupLabel.Text=Current_ProcessGroup_Name;

fillProcessGroupUITree(fig);