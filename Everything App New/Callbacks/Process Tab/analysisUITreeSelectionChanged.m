function [] = analysisUITreeSelectionChanged()

%% PURPOSE: UPDATE THE GROUP OR FUNCTION TAB (DEPENDING ON NODE TYPE) WITH THE CURRENT SELECTION IN THE ANALYSIS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

delete(handles.Process.groupUITree.Children);

% If a function is selected, then the processGroupUITree will just have the
% one function in it.
fillProcessGroupUITree(fig);