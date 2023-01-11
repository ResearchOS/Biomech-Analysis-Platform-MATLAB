function []=currentProjectButtonPushed(src)

%% PURPOSE: SELECT THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

handles.Projects.projectsLabel.Text=selNode.Text;

rootSettingsFile=getRootSettingsFile();

Current_Project_Name=selNode.Text;

save(rootSettingsFile,'Current_Project_Name','-append');

%% Indicates whether tabs besides the projects tab can be used.
projectPath=getProjectPath(fig);

if isempty(projectPath)
    setappdata(fig,'existProjectPath',false);
else
    setappdata(fig,'existProjectPath',true);
end