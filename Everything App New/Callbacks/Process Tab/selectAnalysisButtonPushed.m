function []=selectAnalysisButtonPushed(src)

%% PURPOSE: SHOW THE ENTRIES FOR THE CURRENTLY SELECTED ANALYSIS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.allAnalysesUITree.SelectedNodes;

delete(handles.Process.analysisUITree.Children);
if isempty(selNode)    
    handles.Process.currentAnalysisLabel.Text = 'Current Analysis';
    return;
end

uuid = selNode.NodeData.UUID;

[abbrev, abstractID, instanceID] = deText(uuid);

% Check that it's an instance.
if isempty(instanceID)
    return;
end

% Include name & UUID because the name isn't guaranteed to be unique.
handles.Process.currentAnalysisLabel.Text = [selNode.Text ' ' uuid];
Current_Analysis = selNode.NodeData.UUID;
setCurrent(Current_Analysis,'Current_Analysis');

% Link the current analysis to the current project. How to unlink??
Current_Project = getCurrent('Current_Project_Name');
linkObjs(Current_Analysis, Current_Project);

% Delete pre-existing 
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);

fillAnalysisUITree(fig);