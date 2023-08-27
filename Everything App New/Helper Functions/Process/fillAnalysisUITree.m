function []=fillAnalysisUITree(src)

%% PURPOSE: FILL THE CURRENT ANALYSIS UI TREE
% 1. Look in the AN_PR & AN_PG tables for all objects in the current
% analysis.
% 2. Get all the PR in each PG, preserving PG_PR relationships.
global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

%% Get the list of functions & groups in the current analysis. How to order them?
[orderedList, listPR_PG_AN] = getRunList(anStruct.UUID);
orderedStruct = orderedList2Struct(orderedList, listPR_PG_AN);

uiTree = handles.Process.analysisUITree;

% Delete all existing entries in current UI trees.
delete(uiTree.Children);
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentGroupLabel.Text = 'Current Group';
handles.Process.currentFunctionLabel.Text = 'Current Process';

prettyList = getName(orderedList);
for i=1:length(orderedList)
    uuid = list{i};
    
    addNewNode(uiTree, uuid, prettyList{i});

end

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;