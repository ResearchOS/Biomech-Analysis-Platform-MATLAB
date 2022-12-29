function []=addProjectButtonPushed(src)

%% PURPOSE: CREATE A NEW PROJECT, CHECK IT, AND SELECT IT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=promptName('Enter Project Name');

if isempty(projectName)
    return;
end

projectStruct=createProjectStruct(fig,projectName);

text=projectStruct.Text;

searchTerm=getSearchTerm(handles.Projects.searchField);

fillUITree(fig,'Project',handles.Projects.allProjectsUITree, ...
    searchTerm,handles.Projects.sortProjectsDropDown);