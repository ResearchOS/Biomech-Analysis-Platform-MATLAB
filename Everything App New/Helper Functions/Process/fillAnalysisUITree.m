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
sqlquery = ['SELECT PG_ID FROM AN_PG WHERE AN_ID = ''' anStruct.UUID ''';'];
listPG = fetch(conn, sqlquery);
listPG = table2MyStruct(listPG);
listPG = listPG.PG_ID;
if isempty(listPG)
    listPG = {};
end
sqlquery = ['SELECT PR_ID FROM AN_PR WHERE AN_ID = ''' anStruct.UUID ''';'];
listPR = fetch(conn, sqlquery);
listPR = table2MyStruct(listPR);
listPR = listPR.PR_ID;
if isempty(listPR)
    listPR = {};
end
listPG_PR_FromAN = [listPR; listPG]; % The top level groups & functions in the analysis.
listPG_PR_FromAN(:,2) = {anStruct.UUID}; % Include the analysis name.
listPR_PG_AN = getPRFromPG(listPG_PR_FromAN(:,1), listPG_PR_FromAN); % Get all processing functions in the groups.
prIdx = contains(listPR_PG_AN(:,1),'PR'); % All processing functions together (from all groups in current analysis).
listPR_Only = listPR_PG_AN(prIdx,:); % Isolate the rows that have processing functions, not groups in groups.
links = loadLinks(listPR_Only(:,1)); % Convert unordered list of processing functions into a linkage table.
G = linkageToDigraph('PR', links);
orderedList = orderDeps(G,'full'); % All PR. Need to convert this to parent objects.
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