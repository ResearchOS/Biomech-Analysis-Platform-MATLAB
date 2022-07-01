function []=tabGroup1SelectionChanged(src,event)

%% PURPOSE: STORE THE MOST RECENTLY SELECTED TAB SO THE PGUI CAN OPEN TO IT THE NEXT TIME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Tabs.tabGroup1.SelectedTab.Title;

% Check if the project-independent settings file exists. If not, do not
% allow other tabs besides Projects to be selected.

settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path

if getappdata(fig,'allowAllTabs')==1
    save(settingsMATPath,'currTab','-mat','-append'); % Save the most recent (i.e. current) project name, and the project's settings struct with the path name to the code folder
else
    handles.Tabs.tabGroup1.SelectedTab=handles.Projects.Tab;
    currTab=handles.Tabs.tabGroup1.SelectedTab.Title;
    save(settingsMATPath,'currTab','-mat','-v6');
end