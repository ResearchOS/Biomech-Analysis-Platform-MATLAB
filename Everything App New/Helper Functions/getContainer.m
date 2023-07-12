function [containerUUID, handle] = getContainer(src)

%% PURPOSE: RETURN WHETHER THIS FUNCTION OR FUNCTION GROUP SHOULD BE ADDED TO AN ANALYSIS OR GROUP
% Determination based on which subtab I am currently on.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

container = handles.Process.subtabCurrent.SelectedTab.Title;
switch container
    case 'Analysis'
        containerUUID = getCurrent('Current_Analysis');
        handle = handles.Process.analysisUITree;
    case 'Group'
        groupNode = handles.Process.analysisUITree.SelectedNodes;
        containerUUID = groupNode.NodeData.UUID;
        handle = handles.Process.groupUITree;
    otherwise
        
end