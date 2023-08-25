function [] = analysisUITreeSelectionChanged(src, digraphUUID)

%% PURPOSE: UPDATE THE GROUP OR FUNCTION TAB (DEPENDING ON NODE TYPE) WITH THE CURRENT SELECTION IN THE ANALYSIS TAB.
% If a group node is selected, just update the groupUITree with its run
% list.
% If a function node is selected, update the groupUITree (with run list if part of a
% group, or just the function's UUID if not) AND update the functionUITree

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
if isequal(abbrev, 'PR')
    prUUID = origUUID; % A function node was selected
end


% containerUUID = origUUID; % No processing group encloses the selection.
% 
% if isequal(abbrev,'PR')
%     % Check if a process group encapsulates this process, and select that instead. 
%     % If this process is not in a group, select the process.
%     [uiTree,nodeList] = getUITreeFromNode(selNode);
%     for i=1:length(nodeList)
%         containerUUID = nodeList(i).NodeData.UUID;
%         type = deText(containerUUID);
%         if isequal(type,'PG')
%             selNode = nodeList(i);
%             containerUUID = selNode.NodeData.UUID;
%             selectNode(uiTree, containerUUID);
%             break;
%         end
%     end         
% end

% Ensure that no specify trials are checked while the process group is selected.
if isequal(abbrev,'PG')
    checkSpecifyTrialsUITree({}, handles.Process.allSpecifyTrialsUITree);
end

fillProcessGroupUITree(fig, prUUID);