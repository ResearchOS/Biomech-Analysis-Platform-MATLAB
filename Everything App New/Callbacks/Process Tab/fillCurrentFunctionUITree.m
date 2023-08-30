function []=fillCurrentFunctionUITree(src,digraphUUID)

%% PURPOSE: FILL THE CURRENT FUNCTION UI TREE WITH THE ARGUMENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uiTree=handles.Process.functionUITree;

delete(uiTree.Children);

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
abstractUUID = genUUID(className2Abbrev(abbrev,true),abstractID);
abstractStruct=loadJSON(abstractUUID);

% Test here
return;

namesInCode = abstractStruct.InputVariablesNamesInCode;
if isequal(namesInCode,'NULL')
    return;
end

allVars = [inputVarsInst; outputVarsInst]
for i=1:length(namesInCode)
    name = namesInCode{i};
    varIdx = ismember(input)


end

% inputVarsAbstract=abstractStruct.InputVariablesNamesInCode;
% outputVarsAbstract=abstractStruct.OutputVariablesNamesInCode;

% Create input variable nodes
for i=1:length(inputVarsAbstract)

    try
        currArgsInst=inputVarsInst{i};
    catch
        currArgsInst='';
    end
    currArgsAbs=inputVarsAbstract{i};
    argNode=uitreenode(uiTree,'Text',['getArg ' num2str(currArgsAbs{1})]); % The ID number of the getArg/setArg is the first element.  
    argNode.NodeData.UUID = ''; % Because getNode needs everything to have a UUID
    
    for j=2:length(currArgsAbs)
        if ~iscell(currArgsInst) || length(currArgsInst)<j || isempty(currArgsInst{j})
            suffix='';
            uuid = '';
        else
            suffix=[' (' currArgsInst{j} ')'];
            uuid = currArgsInst{j};
        end
        newNode=uitreenode(argNode,'Text',[currArgsAbs{j} suffix]);
        newNode.NodeData.UUID = uuid;
        assignContextMenu(newNode,handles);
    end

    expand(argNode);
end

% Create output variable nodes
for i=1:length(outputVarsAbstract)

    if ~iscell(outputVarsAbstract) || isempty(outputVarsAbstract{i})
        continue;
    end

    try
        currArgsInst=outputVarsInst{i};
    catch
        currArgsInst='';
    end
    currArgsAbs=outputVarsAbstract{i};
    argNode=uitreenode(uiTree,'Text',['setArg ' num2str(currArgsAbs{1})]);  % The ID number of the getArg/setArg is the first element. 
    
    for j=2:length(currArgsAbs)
        if ~iscell(currArgsInst) || length(currArgsInst)<j || isempty(currArgsInst{j})
            suffix='';
            uuid = '';
        else
            suffix=[' (' currArgsInst{j} ')'];
            uuid = currArgsInst{j};
        end        
        newNode=uitreenode(argNode,'Text',[currArgsAbs{j} suffix]);
        newNode.NodeData.UUID = uuid;
        assignContextMenu(newNode,handles);
    end

    expand(argNode);
end