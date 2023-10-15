function []=fillAnalysisUITree(src, uiTree, uuid)

%% PURPOSE: GET THE ORDER OF PR & PG IN THE CURRENT AN AND FILL THE CURRENT ANALYSIS UI TREE
% 1. Look in the AN_PR & AN_PG tables for all objects in the current
% analysis.
% 2. Get all the PR in each PG, preserving PG_PR relationships.

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(uuid)
    delete(uiTree.Children);
    return;
end

%% The nodes in the current analysis or group.
tmpG = getSubgraph(globalG, uuid, 'up'); % Everything within the current analysis.

%% Get the list of functions & groups in the current analysis
% Returns edges only between PG, PR, AN objects.
orderedEdges = orderedList2Struct(tmpG);

fillAN_PG_UITree(uiTree, handles, orderedEdges);

switch uiTree
    case handles.Process.analysisUITree
        tab = handles.Process.currentAnalysisTab;
        label = handles.Process.currentAnalysisLabel;
    case handles.Process.groupUITree
        tab = handles.Process.subtabCurrent.SelectedTab;
        label = handles.Process.currentGroupLabel;
end
handles.Process.subtabCurrent.SelectedTab = tab;
label.Text = [getName(uuid) ' ' uuid];
drawnow;