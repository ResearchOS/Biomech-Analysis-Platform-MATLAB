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

% Update visible group, update visible process functions, etc.
groupName=getCurrentProcessGroup();
selectGroupButtonPushed(fig,groupName);

searchTerm=getSearchTerm(handles.Process.groupsSearchField);
sortDropDown=handles.Process.sortGroupsDropDown;
fillUITree(fig,'ProcessGroup',handles.Process.allGroupsUITree,searchTerm,sortDropDown);

save(rootSettingsFile,'Current_Project_Name','-append');