function [] = analysisUITreeSelectionChanged(src, digraphUUID)

%% PURPOSE: UPDATE THE GROUP OR FUNCTION TAB (DEPENDING ON NODE TYPE) WITH THE CURRENT SELECTION IN THE ANALYSIS TAB.
% If a group node is selected, just update the groupUITree with its run
% list.
% If a function node is selected, update the groupUITree (with run list if part of a
% group, or just the function's UUID if not) AND update the functionUITree

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.analysisUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if nargin==1 || isempty(digraphUUID)
    origUUID = selNode.NodeData.UUID; % The selected group or function.
else
    origUUID = digraphUUID;
end
abbrev = deText(origUUID);

prUUID = ''; % A group was selected.
pgUUID = '';
if isequal(abbrev, 'PR')
    prUUID = origUUID; % A function node was selected
    [~,list] = getUITreeFromNode(selNode);
    if length(list)>2
        pgUUID = list(2).NodeData.UUID;
    end
else
    pgUUID = origUUID;
end

% Ensure that no specify trials are checked while the process group is selected.
if isequal(abbrev,'PG')
    checkSpecifyTrialsUITree({}, handles.Process.allSpecifyTrialsUITree);
elseif ~isempty(prUUID)
    checkSpecifyTrialsUITree(getST(prUUID), handles.Process.allSpecifyTrialsUITree);
end

%% The nodes in the current analysis
tmpG = getSubgraph(globalG, pgUUID, 'up'); % Everything within the current analysis.

%% Get the list of functions & groups in the current analysis
% Returns edges only between PG, PR, AN objects.
orderedEdges = orderedList2Struct(tmpG);

uiTree = handles.Process.groupUITree;
fillAN_PG_UITree(uiTree, handles, orderedEdges);

% handles.Process.subtabCurrent.SelectedTab = handles.Process.currentGroupTab;
drawnow;

if isequal(abbrev,'PG')
    return;
end

selectNode(uiTree, origUUID);
fillCurrentFunctionUITree(fig, origUUID);