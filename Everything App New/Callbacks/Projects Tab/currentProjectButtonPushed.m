function []=currentProjectButtonPushed(src)

%% PURPOSE: SELECT THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Include name & UUID because the name isn't guaranteed to be unique
uuid = selNode.NodeData.UUID;
handles.Projects.projectsLabel.Text=[selNode.Text ' ' uuid];

setCurrent(uuid, 'Current_Project_Name');

% Select the current analysis node, and show its entries.
Current_Analysis = getCurrent('Current_Analysis');
selectNode(handles.Process.allAnalysesUITree, Current_Analysis);
selectAnalysisButtonPushed(fig);

% Select the current logsheet.
Current_Logsheet = getCurrent('Current_Logsheet');
selectNode(handles.Import.allLogsheetsUITree, Current_Logsheet);
allLogsheetsUITreeSelectionChanged(fig);