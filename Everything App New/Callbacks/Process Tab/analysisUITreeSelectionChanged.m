function [] = analysisUITreeSelectionChanged(src)

%% PURPOSE: UPDATE THE GROUP OR FUNCTION TAB (DEPENDING ON NODE TYPE) WITH THE CURRENT SELECTION IN THE ANALYSIS TAB.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.analysisUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID; % The selected group or function.
abbrev = deText(uuid);
if isequal(abbrev,'PR')
    % Check if a process group encapsulates this process, and select that instead. 
    % If this process is not in a group, select the process.
    [uiTree,nodeList] = getUITreeFromNode(selNode);
    for i=1:length(nodeList)
        uuid = nodeList(i).NodeData.UUID;
        type = deText(uuid);
        if isequal(type,'PG')
            selNode = nodeList(i);
            uuid = selNode.NodeData.UUID;
            selectNode(uiTree, uuid);
            break;
        end
    end            
end

% Ensure that no specify trials are checked while the process group is selected.
checkSpecifyTrialsUITree({}, handles.Process.allSpecifyTrialsUITree);

fillProcessGroupUITree(fig);

if isempty(handles.Process.groupUITree.Children)
    return;
end

lastNode = handles.Process.groupUITree.Children(end);

selectNode(lastNode, lastNode.NodeData.UUID);

fillCurrentFunctionUITree(fig);