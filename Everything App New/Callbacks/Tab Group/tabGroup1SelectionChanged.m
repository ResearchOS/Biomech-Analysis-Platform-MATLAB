function []=tabGroup1SelectionChanged(src,currTab)

%% PURPOSE: STORE THE MOST RECENTLY SELECTED TAB SO THE PGUI CAN OPEN TO IT THE NEXT TIME
% Also, set the parent tab of the processing map figure objects to the
% currently selected tab.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

existProjectPath=getappdata(fig,'projectPath');

if existProjectPath==1
    return;
end

path=getProjectPath(fig);

if isempty(path)
    handles.Tabs.tabGroup1.SelectedTab=handles.Projects.Tab;
end