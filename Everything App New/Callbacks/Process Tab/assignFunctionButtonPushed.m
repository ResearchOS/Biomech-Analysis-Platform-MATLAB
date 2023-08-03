function []=assignFunctionButtonPushed(src)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT ANALYSIS OR PROCESSING GROUP
% If on Analysis tab, assign function directly to analysis
% If on Group tab, assign function to group.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allProcessUITree.SelectedNodes;

if isempty(selNode)
    return;
end

selUUID = selNode.NodeData.UUID;

[type, abstractID, instanceID] = deText(selUUID);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    figure(fig);
    prStruct = createNewObject(true, 'Process', selNode.Text, abstractID, '', true);
    selUUID = prStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allProcessUITree, abstractUUID);

    % Add input, input subvariables, and output variables to process struct.
    absStruct = loadJSON(abstractUUID);
    numIns = length(absStruct.InputVariablesNamesInCode);
    prStruct.InputVariables = cell(numIns,1);
    for i=1:numIns
        prStruct.InputVariables{i} = cell(length(absStruct.InputVariablesNamesInCode{i}),1);
        prStruct.InputVariables{i}{1} = absStruct.InputVariablesNamesInCode{i}{1};
        prStruct.InputSubvariables{i} = cell(length(absStruct.InputVariablesNamesInCode{i}),1);
    end
    numOuts = length(absStruct.OutputVariablesNamesInCode);
    prStruct.OutputVariables = cell(numIns,1);
    for i=1:numOuts
        prStruct.OutputVariables{i} = cell(length(absStruct.OutputVariablesNamesInCode{i}),1);
        prStruct.OutputVariables{i}{1} = absStruct.OutputVariablesNamesInCode{i}{1};
        prStruct.OutputSubvariables{i} = cell(length(absStruct.OutputVariablesNamesInCode{i}),1);
    end

    % Create the new node in the "all" UI tree
    addNewNode(absNode, selUUID, prStruct.Text);
    writeJSON(getJSONPath(prStruct), prStruct);
end

[containerUUID, uiTree] = getContainer(selUUID, fig);
contStruct = loadJSON(containerUUID);
contStruct.RunList = [contStruct.RunList; {selUUID}];
writeJSON(getJSONPath(contStruct), contStruct);
selStruct = loadJSON(selUUID);

% Add a new node to the current UI tree
addNewNode(uiTree, selStruct.UUID, selStruct.Text);
selectNode(uiTree, selStruct.UUID);

% Add a new node to the analysis UI tree
addNewNode(getNode(handles.Process.analysisUITree, containerUUID), selUUID, selStruct.Text);

linkObjs(selStruct.UUID, containerUUID);

switch uiTree
    case handles.Process.analysisUITree           
        fillProcessGroupUITree(fig); % Added function or group to analysis. Completely refill the current process group UI tree
    case handles.Process.groupUITree
        fillCurrentFunctionUITree(fig); % Added function to group. Fill the current function UI tree     
    otherwise
        error('Where am I?');
end

%% This happens if the function has been removed from the analysis previously, and is now being re-added.
% This helps keep a history!
inVars = getVarNamesArray(selStruct, 'InputVariables');
outVars = getVarNamesArray(selStruct, 'OutputVariables');

if ~all(cellfun(@isempty, inVars))
    linkObjs(inVars, selStruct);
end

if ~all(cellfun(@isempty, outVars))
    linkObjs(selStruct, outVars);
end