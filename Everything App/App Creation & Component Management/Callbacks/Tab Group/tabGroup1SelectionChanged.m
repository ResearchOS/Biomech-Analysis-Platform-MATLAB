function []=tabGroup1SelectionChanged(src,event)

%% PURPOSE: STORE THE MOST RECENTLY SELECTED TAB SO THE PGUI CAN OPEN TO IT THE NEXT TIME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path

currTab=handles.Tabs.tabGroup1.SelectedTab.Title;
prevTab=load(settingsMATPath,'currTab');
prevTab=prevTab.currTab;

if getappdata(fig,'allowAllTabs')==2 % All tabs
    okTabs={'Projects','Import','Process','Plot','Stats','Settings','Exemplar'};
elseif getappdata(fig,'allowAllTabs')==1 % Projects & Import tabs only
    okTabs={'Projects','Import'};
elseif getappdata(fig,'allowAllTabs')==0 % Projects tab only
    okTabs={'Projects'};
end

if ~ismember(currTab,okTabs)
    handles.Tabs.tabGroup1.SelectedTab=handles.(prevTab).Tab;
    currTab=handles.Tabs.tabGroup1.SelectedTab.Title;
    drawnow;
end

if exist(settingsMATPath,'file')~=2
    save(settingsMATPath,'currTab','-mat','-v6');
else
    save(settingsMATPath,'currTab','-mat','-append'); % Save the most recent (i.e. current) project name, and the project's settings struct with the path name to the code folder
end