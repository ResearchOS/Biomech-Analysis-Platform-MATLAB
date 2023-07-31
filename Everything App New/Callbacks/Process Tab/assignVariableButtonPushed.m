function []=assignVariableButtonPushed(src,allVarUUID)

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

varNameInCode = strsplit(currVarNode.Text);
varNameInCode = varNameInCode{1};

% currVarUUID = currVarNode.NodeData.UUID;

parentNode = currVarNode.Parent;
if isequal(parentNode, processUITree)
    disp('Cannot select the getArg or setArg nodes! Must select the specific variables.');
    return;
end

% Only not true when pasting a variable.
if exist('allVarUUID','var')~=1
    allVarUUID = allNode.NodeData.UUID;    
end
[type, abstractID, instanceID] = deText(allVarUUID);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    figure(fig);
    varStruct = createNewObject(true, 'Variable', allNode.Text, abstractID, '', true);
    allVarUUID = varStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allVariablesUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, allVarUUID, varStruct.Text);
else
    varStruct = loadJSON(allVarUUID);
end

getSetArgIdxNum = str2double(parentNode.Text(isstrprop(parentNode.Text,'digit'))); % Number of this getArg or setArg

isOut = false;
if isequal(parentNode.Text(1:6),'getArg')
    fldName = 'InputVariables';
    absFldName = 'InputVariablesNamesInCode';
elseif isequal(parentNode.Text(1:6),'setArg')
    isOut = true;
    fldName = 'OutputVariables';
    absFldName = 'OutputVariablesNamesInCode';
end

% Check that this variable has not been an output of any functions anywhere
% else. If so, stop the process.
if isOut
    linksFolder = [getCommonPath() filesep 'Linkages'];
    linksFilePath = [linksFolder filesep 'Linkages.json'];
    links = loadJSON(linksFilePath);
    if ismember(allVarUUID,links(:,2))
        disp('This variable is already an output elsewhere!');
        return;
    end
end

currFcnUUID = currFcnNode.NodeData.UUID;
fcnStruct = loadJSON(currFcnUUID);
prevInputVars = getVarNamesArray(fcnStruct, 'InputVariables');
prevOutputVars = getVarNamesArray(fcnStruct,'OutputVariables');

[fcnType, fcnAbstractID, fcnInstanceID] = deText(currFcnUUID);
absFcnUUID = genUUID(fcnType, fcnAbstractID);
absFcnStruct = loadJSON(absFcnUUID);

getSetArgIdx = [];
for i=1:length(fcnStruct.(fldName))
    if isequal(fcnStruct.(fldName){i}{1},getSetArgIdxNum)
        getSetArgIdx = i;
        break;
    end
end
assert(~isempty(getSetArgIdx));

argIdx = ismember(absFcnStruct.(absFldName){getSetArgIdx}(2:end),varNameInCode); % Get which argument this is.
argIdx = [false; argIdx];
fcnStruct.(fldName){getSetArgIdx}(argIdx) = {allVarUUID};
if isequal(fldName,'InputVariables')
    fcnStruct.InputSubvariables{getSetArgIdx}(argIdx) = {''}; % Changing the variable, so the subvariable should be reset.
end


%% Update function OutOfDate parameter if any input or output variable has changed.
newInputVars = getVarNamesArray(fcnStruct, 'InputVariables');
newOutputVars = getVarNamesArray(fcnStruct,'OutputVariables');
if ~(isequal(newInputVars,prevInputVars) && isequal(newOutputVars, prevOutputVars))
    fcnStruct.OutOfDate = true;
end

writeJSON(getJSONPath(fcnStruct), fcnStruct);

currVarNode.NodeData.UUID = allVarUUID;
argTextSplit = strsplit(currVarNode.Text);
currVarNode.Text = [argTextSplit{1} ' (' allVarUUID ')'];

%% Link objects. Update variable OutOfDate field.
if isequal(parentNode.Text(1:6),'getArg')
    linkObjs(allVarUUID, currFcnUUID);
elseif isequal(parentNode.Text(1:6),'setArg')
    linkObjs(currFcnUUID, allVarUUID);
    varStruct.OutOfDate = true;
    writeJSON(getJSONPath(varStruct), varStruct);
end

%% Unlink the previous variable, if applicable.
if length(argTextSplit)>1 % There was a variable there.
    prevVarUUID = argTextSplit{2}(2:end-1); % Omit the parentheses
    if ~isequal(prevVarUUID,allVarUUID) % This only happens if there's a fluke.
        if isequal(parentNode.Text(1:6),'getArg')
            unlinkObjs(prevVarUUID, currFcnUUID);
        elseif isequal(parentNode.Text(1:6),'setArg')
            unlinkObjs(currFcnUUID, prevVarUUID);
        end
    end
end

%% Change OutOfDate values for any functions or variables downstream.
if fcnStruct.OutOfDate
    list = orderDeps(getappdata(fig,'digraph'), fcnStruct.UUID,[]);
    for i = 1:length(list)
        currFcnStruct = loadJSON(list{i});
        currFcnStruct.OutOfDate = true;
        writeJSON(getJSONPath(currFcnStruct), currFcnStruct);

        % Update variables.
        varsOut = getVarNamesArray(currFcnStruct, 'OutputVariables');
        for j = 1:length(varsOut)
            if isempty(varsOut{j})
                continue;
            end
            varStruct = loadJSON(varsOut{j});
            varStruct.OutOfDate = true;
            writeJSON(getJSONPath(varStruct), varStruct);
        end
    end
end

%% Update the digraph
toggleDigraphCheckboxValueChanged(fig);