function []=unassignFunctionButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING FUNCTION FROM PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab = handles.Process.subtabCurrent.SelectedTab.Title;
switch currTab
    case 'Analysis'
        uiTree = handles.Process.analysisUITree;
    case 'Group'
        uiTree = handles.Process.groupUITree;
end

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[containerUUID] = getContainer(selUUID, fig);

type = deText(selUUID);

if ~isequal(type,'PR')
    disp('Must have a process selected to use this button!');
    return;
end

%% Update GUI
% Delete the function from the group UI tree
proceed = deleteNode(selNode);
if ~proceed
    return;
end
% Delete the function from the analysis UI tree
% proceed = deleteNode(getNode(handles.Process.analysisUITree, selUUID));

%% Remove the group from the current group or analysis.
contStruct = loadJSON(containerUUID);
idx = ismember(contStruct.RunList,selUUID);
contStruct.RunList(idx) = [];

writeJSON(getJSONPath(contStruct), contStruct);

%% Unlink process function from group or analysis.
unlinkObjs(selUUID, contStruct);

%% Unlink the variables from the function. However, this maintains the variables in the function JSON!
fcnStruct = loadJSON(selUUID);
inVars = getVarNamesArray(fcnStruct, 'InputVariables');
outVars = getVarNamesArray(fcnStruct, 'OutputVariables');
if any(~cellfun(@isempty, inVars))
    unlinkObjs(inVars, fcnStruct);
end
if any(~cellfun(@isempty, outVars))
    unlinkObjs(fcnStruct, outVars);
end