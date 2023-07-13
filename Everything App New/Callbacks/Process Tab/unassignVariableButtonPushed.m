function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Current process group UI tree
currFcnNode = handles.Process.groupUITree.SelectedNodes;

if isempty(currFcnNode)
    return;
end

% Current process UI tree
processUITree=handles.Process.functionUITree; 

currVarNode=processUITree.SelectedNodes;

if isempty(currVarNode)
    return;
end

currVarUUID = currVarNode.NodeData.UUID;

parentNode = currVarNode.Parent;
if isequal(parentNode,processUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
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
fcnStruct.(fldName){getSetArgIdx}(argIdx) = {''};
if isequal(fldName,'InputVariables')
    fcnStruct.InputSubvariables{getSetArgIdx}(argIdx) = {''}; % Changing the variable, so the subvariable should be reset.
end
writeJSON(getJSONPath(fcnStruct), fcnStruct);

currVarNode.NodeData.UUID = '';
argTextSplit = strsplit(currVarNode.Text);
currVarNode.Text = argTextSplit{1};

%% Unlink the variable from the process function
if isequal(parentNode.Text(1:6),'getArg')
    unlinkObjs(currVarUUID, currFcnUUID);
elseif isequal(parentNode.Text(1:6),'setArg')
    unlinkObjs(currFcnUUID, currVarUUID);
end