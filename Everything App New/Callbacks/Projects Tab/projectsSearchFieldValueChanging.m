function []=projectsSearchFieldValueChanging(src,event)

%% PURPOSE: SEARCH FOR SPECIFIC PROJECTS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

searchTerm=getSearchTerm(handles.Projects.searchField);

fillUITree(fig,'Project',handles.Projects.allProjectsUITree, ...
    searchTerm, handles.Projects.sortProjectsDropDown);