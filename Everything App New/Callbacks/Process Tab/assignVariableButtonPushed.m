function []=assignVariableButtonPushed(src,varName,varNameInCode)

%% PURPOSE: ASSIGN VARIABLE TO CURRENT PROCESSING FUNCTION

% motherNode is the "grouping" class object, and daughterNode is the
% "grouped" class object.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% All variables UI tree
allNode=handles.Process.allVariablesUITree.SelectedNodes;

if isempty(allNode)
    return;
end

processUITree=handles.Process.functionUITree;

% Current process group UI tree
currFcnNode = handles.Process.groupUITree.SelectedNodes;

if isempty(currFcnNode)
    return;
end

% Current function UI tree
currVarNode=processUITree.SelectedNodes;

if isempty(currVarNode)
    return;
end

currVarUUID = currVarNode.NodeData.UUID;

parentNode = currVarNode.Parent;
if isequal(parentNode, processUITree)
    disp('Cannot select the getArg or setArg nodes! Must select the specific variables.');
    return;
end

allVarUUID = allNode.NodeData.UUID;
[type, abstractID, instanceID] = deText(allVarUUID);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    varStruct = createNewObject(true, 'Variable', allNode.Text, abstractID, '', true);
    allVarUUID = varStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allVariablesUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, allVarUUID, varStruct.Text);
end

getSetArgIdxNum = str2double(parentNode.Text(isstrprop(parentNode.Text,'digit'))); % Number of this getArg or setArg

if isequal(parentNode.Text(1:6),'getArg')
    fldName = 'InputVariables';
elseif isequal(parentNode.Text(1:6),'setArg')
    fldName = 'OutputVariables';
end

currFcnUUID = currFcnNode.NodeData.UUID;
fcnStruct = loadJSON(currFcnUUID);

getSetArgIdx = [];
for i=1:length(fcnStruct.(fldName))
    if isequal(fcnStruct.(fldName){i}{1},getSetArgIdxNum)
        getSetArgIdx = i;
        break;
    end
end
assert(~isempty(getSetArgIdx));

argIdx = ismember(fcnStruct.(fldName){getSetArgIdx}(2:end),currVarUUID); % Get which argument this is.
argIdx = [false; argIdx];
fcnStruct.(fldName){getSetArgIdx}(argIdx) = {allVarUUID};
if isequal(fldName,'InputVariables')
    fcnStruct.InputSubvariables{getSetArgIdx}(argIdx) = {''}; % Changing the variable, so the subvariable should be reset.
end
writeJSON(getJSONPath(fcnStruct), fcnStruct);

currVarNode.NodeData.UUID = allVarUUID;
argTextSplit = strsplit(currVarNode.Text);
currVarNode.Text = [argTextSplit{1} ' (' allVarUUID ')'];