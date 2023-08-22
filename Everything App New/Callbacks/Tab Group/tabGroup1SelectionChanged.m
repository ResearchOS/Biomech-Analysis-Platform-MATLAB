function []=tabGroup1SelectionChanged(src,currTab)

%% PURPOSE: STORE THE MOST RECENTLY SELECTED TAB SO THE PGUI CAN OPEN TO IT THE NEXT TIME
% Also, set the parent tab of the processing map figure objects to the
% currently selected tab.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% path=getProjectPath();

% if isempty(path)
%     disp('Check the project path!');
%     if ~isequal(handles.Tabs.tabGroup1.SelectedTab,handles.Settings.Tab)
%         handles.Tabs.tabGroup1.SelectedTab=handles.Projects.Tab;
%     end
% end

%% Store the current tab.
rootSettingsFile=getRootSettingsFile();
Current_Tab_Title=handles.Tabs.tabGroup1.SelectedTab.Title;
save(rootSettingsFile,'Current_Tab_Title','-append');

%% If switching between Plot and Process tab, change the visibility of the "Variables" tab.
if ismember(Current_Tab_Title,{'Projects','Import','Stats','Settings'})
    return;
end

parent=handles.(Current_Tab_Title).subTabAll;

set(handles.Process.variablesTab,'Parent',parent);

idx=ismember(parent.Children,handles.Process.variablesTab);
parent.Children=[parent.Children(idx); parent.Children(~idx)]; % Put the Variables tab on the far left.