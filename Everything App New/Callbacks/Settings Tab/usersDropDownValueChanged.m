function [] = usersDropDownValueChanged(src,event)

%% PURPOSE: CHANGE THE CURRENT USER.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value = handles.Settings.usersDropDown.Value;

setCurrent('Current_User', value);

%% Change the current project.
Current_Project = getCurrent('Current_Project_Name');
selectNode(handles.Projects.allProjectsUITree, Current_Project);
allProjectsUITreeSelectionChanged(fig);
currentProjectButtonPushed(fig);

%% Change the current tab.
Current_Tab_Title = getCurrent('Current_Tab_Title');
handles.Tabs.tabGroup1.SelectedTab = handles.Tabs.(Current_Tab_Title);
tabGroup1SelectionChanged(fig, Current_Tab_Title);