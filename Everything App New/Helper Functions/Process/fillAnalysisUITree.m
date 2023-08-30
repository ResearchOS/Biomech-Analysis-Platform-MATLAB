function []=fillAnalysisUITree(src)

%% PURPOSE: GET THE ORDER OF PR & PG IN THE CURRENT AN AND FILL THE CURRENT ANALYSIS UI TREE
% 1. Look in the AN_PR & AN_PG tables for all objects in the current
% analysis.
% 2. Get all the PR in each PG, preserving PG_PR relationships.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

%% Get the list of functions & groups in the current analysis. How to order them?
[orderedList, listPR_PG_AN] = getRunList(anStruct.UUID);
orderedStruct = orderedList2Struct(orderedList, listPR_PG_AN);

uiTree = handles.Process.analysisUITree;
fillAN_PG_UITree(uiTree, handles, orderedStruct);

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;
drawnow;