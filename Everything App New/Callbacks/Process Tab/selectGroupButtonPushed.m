function []=selectGroupButtonPushed(src,event)

%% PURPOSE: SELECT THE CURRENTLY SELECTED PI GROUP. IF NO CORRESPONDING PS GROUP, CREATE IT AND ASSIGN THAT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(groupNode)
    return;
end

projectPath=getProjectPath(fig);
if isempty(projectPath)
    return;
end

projectSettingsFile=getProjectSettingsFile(fig);
projectSettings=loadJSON(projectSettingsFile);

% Create new PS process group struct if PI node is selected
if isequal(groupNode.Parent,handles.Process.allGroupsUITree)
    fullPath=getClassFilePath(groupNode);
    piStruct=loadJSON(fullPath);
    psStruct=createProcessGroupStruct_PS(fig, piStruct);
    Current_ProcessGroup_Name=psStruct.Text;
    uitreenode(groupNode,'Text',psStruct.Text); % Create new PS node.
else % Use pre-existing PS node.
    Current_ProcessGroup_Name=groupNode.Text;
end

%% Create project-specific processing group file if one does not exist already.
projectSettings.Current_ProcessGroup_Name=Current_ProcessGroup_Name;
writeJSON(projectSettingsFile,projectSettings);

handles.Process.currentGroupLabel.Text=Current_ProcessGroup_Name;

fillProcessGroupUITree(fig);