function []=selectGroupButtonPushed(src,event)

%% PURPOSE: SELECT THE CURRENTLY SELECTED GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(groupNode)
    return;
end

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_ProcessGroup_Name');

projectPath=getProjectPath(fig);
if isempty(projectPath)
    return;
end

slash=filesep;
%% Create project-specific processing group file if one does not exist already.
names=getClassFilenames(fig,'ProcessGroup',[projectPath slash 'Project_Settings']);
if ~contains(Current_ProcessGroup_Name,names)
    psStruct=createPSProcessGroupStruct(fig);
    Current_ProcessGroup_Name=psStruct.Text;
    save(rootSettingsFile,'Current_ProcessGroup_Name','-append');
end

handles.Process.currentGroupLabel.Text=Current_ProcessGroup_Name;

fillProcessGroupUITree(fig);