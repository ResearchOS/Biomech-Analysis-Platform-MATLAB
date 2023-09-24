function []=fillAnalysisUITree(src)

%% PURPOSE: GET THE ORDER OF PR & PG IN THE CURRENT AN AND FILL THE CURRENT ANALYSIS UI TREE
% 1. Look in the AN_PR & AN_PG tables for all objects in the current
% analysis.
% 2. Get all the PR in each PG, preserving PG_PR relationships.

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');

%% The nodes in the current analysis
tmpG = getSubgraph(globalG, Current_Analysis, 'up'); % Everything within the current analysis.
order = toposort(tmpG);
orderedNodes = tmpG.Nodes.Name(order);
nodeIdx = contains(orderedNodes,{'PG','PR','AN'});
rmNodes = orderedNodes(~nodeIdx);
orderedNodes = orderedNodes(nodeIdx);
tmpG = rmnode(tmpG, rmNodes);

%% Get the list of functions & groups in the current analysis
tmpG.Nodes.Name = orderedNodes;
orderedEdges = orderedList2Struct(tmpG); % Nodes are in the topologically sorted order!

uiTree = handles.Process.analysisUITree;
fillAN_PG_UITree(uiTree, handles, orderedEdges);

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;
drawnow;