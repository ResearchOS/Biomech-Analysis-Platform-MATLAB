function []=selectAnalysisButtonPushed(src)

%% PURPOSE: SHOW THE ENTRIES FOR THE CURRENTLY SELECTED ANALYSIS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.allAnalysesUITree.SelectedNodes;

if isempty(selNode)
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

% Delete pre-existing 
delete(handles.Process.analysisUITree.Children);
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);

fillAnalysisUITree(fig);