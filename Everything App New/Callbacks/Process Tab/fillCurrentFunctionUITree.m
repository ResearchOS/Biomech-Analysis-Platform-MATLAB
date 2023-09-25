function []=fillCurrentFunctionUITree(src,digraphUUID)

%% PURPOSE: FILL THE CURRENT FUNCTION UI TREE WITH THE ARGUMENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

uiTree=handles.Process.functionUITree;

delete(uiTree.Children);

if isempty(selNode)
    handles.Process.currentFunctionLabel.Text = 'Current Process';
    return;
end

if nargin==1 || isempty(digraphUUID)
    uuid = selNode.NodeData.UUID;
else
    uuid = digraphUUID;
end
[abbrev, abstractID, ~] = deText(uuid);
if isequal(abbrev,'PG')
    handles.Process.currentFunctionLabel.Text = 'Current Process';
    return; % Process group selections can't fill the current function UI tree
end

handles.Process.currentFunctionLabel.Text = [selNode.Text ' ' uuid];

[inputVarsInst] = getAssignedVars(uuid, 'Input');
[outputVarsInst] = getAssignedVars(uuid, 'Output');

% Load project-independent file.
abstractUUID = genUUID(className2Abbrev(abbrev),abstractID);
abstractStruct=loadJSON(abstractUUID);

namesInCode = abstractStruct.InputVariablesNamesInCode;
if isequal(namesInCode,'NULL')
    return;
end

inputVarsAbstract=abstractStruct.InputVariablesNamesInCode;
outputVarsAbstract=abstractStruct.OutputVariablesNamesInCode;

% Create input variable nodes
for i=1:length(inputVarsAbstract)

    currArgsAbs=inputVarsAbstract{i};
    argNode=uitreenode(uiTree,'Text',['getArg ' num2str(currArgsAbs{1})]); % The ID number of the getArg/setArg is the first element.  
    currArgsAbs(1) = []; % Remove the numerical getArg ID
    argNode.NodeData.UUID = ''; % Because getNode needs everything to have a UUID    

    for j=1:length(currArgsAbs)
        idx = ismember(inputVarsInst.NameInCode, currArgsAbs{j});
        if any(idx)
            uuid = inputVarsInst.VR_ID{idx};
            suffix = [' (' uuid ')'];
        else
            suffix = '';
            uuid = suffix;
        end
        newNode = uitreenode(argNode,'Text',[currArgsAbs{j} suffix]);
        newNode.NodeData.UUID = uuid;
        assignContextMenu(newNode, handles);
    end

    expand(argNode);
end

% Create output variable nodes
for i=1:length(outputVarsAbstract)

    currArgsAbs=outputVarsAbstract{i};
    argNode=uitreenode(uiTree,'Text',['setArg ' num2str(currArgsAbs{1})]); % The ID number of the getArg/setArg is the first element.  
    currArgsAbs(1) = []; % Remove the numerical getArg ID
    argNode.NodeData.UUID = ''; % Because getNode needs everything to have a UUID    

    for j=1:length(currArgsAbs)
        idx = ismember(outputVarsInst.NameInCode, currArgsAbs{j});
        if any(idx)
            uuid = outputVarsInst.VR_ID{idx};
            suffix = [' (' uuid ')'];
        else
            suffix = '';
            uuid = suffix;
        end
        newNode = uitreenode(argNode,'Text',[currArgsAbs{j} suffix]);
        newNode.NodeData.UUID = uuid;
        assignContextMenu(newNode, handles);
    end

    expand(argNode);
end