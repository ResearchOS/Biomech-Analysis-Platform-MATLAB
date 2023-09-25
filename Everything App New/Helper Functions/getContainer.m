function [containerUUID] = getContainer(tab)

%% PURPOSE: RETURN WHETHER THIS FUNCTION OR FUNCTION GROUP SHOULD BE ADDED TO AN ANALYSIS OR GROUP
% Determination based on which subtab I am currently on.

%% Provided a char UUID.
fig=ancestor(tab,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab = tab.Title;
switch currTab
    case 'Analysis'   
        containerUUID = getCurrent('Current_Analysis');
    case 'Group'
        containerUUID = getCurrentProcessGroup(fig);
end