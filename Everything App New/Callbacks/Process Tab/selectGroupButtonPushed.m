function []=selectGroupButtonPushed(src,groupName)

%% PURPOSE: SELECT THE CURRENTLY SELECTED PI GROUP. IF NO CORRESPONDING PS GROUP, CREATE IT AND ASSIGN THAT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('groupName','var')~=1
    groupNode=handles.Process.allGroupsUITree.SelectedNodes;

    if isempty(groupNode)
        return;
    end
end

projectPath=getProjectPath();
if isempty(projectPath)
    return;
end

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);

% Create new PS process group struct if PI node is selected
if exist('groupName','var')~=1
    if isequal(groupNode.Parent,handles.Process.allGroupsUITree)
        fullPath=getClassFilePath(groupNode);
        piStruct=loadJSON(fullPath);
        psStruct=createProcessGroupStruct_PS(piStruct);
        Current_ProcessGroup_Name=psStruct.Text;
        uitreenode(groupNode,'Text',psStruct.Text); % Create new PS node.
    else % Use pre-existing PS node.
        Current_ProcessGroup_Name=groupNode.Text;
    end
else
    Current_ProcessGroup_Name=groupName;
end

%% Create project-specific processing group file if one does not exist already.
projectSettings.Current_ProcessGroup_Name=Current_ProcessGroup_Name;
writeJSON(projectSettingsFile,projectSettings);

handles.Process.currentGroupLabel.Text=Current_ProcessGroup_Name;

fillProcessGroupUITree(fig);