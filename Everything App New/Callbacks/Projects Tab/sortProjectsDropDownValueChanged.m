function []=sortProjectsDropDownValueChanged(src,event)

%% PURPOSE: SORT THE PROJECTS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

sortMethod=handles.Projects.sortProjectsDropDown.Value;

sortUITree(uiTree,sortMethod);