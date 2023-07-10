function []=fillCurrentFunctionUITree(src,event)

%% PURPOSE: FILL THE CURRENT FUNCTION UI TREE WITH THE ARGUMENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uiTree=handles.Process.functionUITree;

delete(uiTree.Children);

uuid = selNode.NodeData.UUID;
[abbrev, abstractID, ~] = deText(uuid);
if isequal(abbrev,'PG')
    return; % Process group selections can't fill the current function UI tree
end

instStruct=loadJSON(uuid);

inputVarsPS=instStruct.InputVariables;
outputVarsPS=instStruct.OutputVariables;

% Load project-independent file.
abstractUUID = genUUID(className2Abbrev(abbrev,true),abstractID);
abstractStruct=loadJSON(abstractUUID);

inputVarsPI=abstractStruct.InputVariablesNamesInCode;
outputVarsPI=abstractStruct.OutputVariablesNamesInCode;

% Create input variable nodes
for i=1:length(inputVarsPI)

    try
        currArgs=inputVarsPS{i};
    catch
        currArgs='';
    end
    currArgsPI=inputVarsPI{i};
    argNode=uitreenode(uiTree,'Text',['getArg ' num2str(currArgsPI{1})]); % The ID number of the getArg/setArg is the first element.   
    
    for j=2:length(currArgsPI)
        if ~iscell(currArgs) || length(currArgs)<j || isempty(currArgs{j})
            suffix='';
        else
            suffix=[' (' currArgs{j} ')'];
        end
        newNode=uitreenode(argNode,'Text',[currArgsPI{j} suffix]);
        newNode.NodeData.UUID = currArgs{j};
        assignContextMenu(newNode,handles);
    end

    expand(argNode);
end

% Create output variable nodes
for i=1:length(outputVarsPI)

    if ~iscell(outputVarsPI) || isempty(outputVarsPI{i})
        continue;
    end

    try
        currArgs=outputVarsPS{i};
    catch
        currArgs='';
    end
    currArgsPI=outputVarsPI{i};
    argNode=uitreenode(uiTree,'Text',['setArg ' num2str(currArgsPI{1})]);  % The ID number of the getArg/setArg is the first element. 
    
    for j=2:length(currArgsPI)
        if ~iscell(currArgs) || length(currArgs)<j || isempty(currArgs{j})
            suffix='';
        else
            suffix=[' (' currArgs{j} ')'];
        end
        newNode=uitreenode(argNode,'Text',[currArgsPI{j} suffix]);
        newNode.NodeData.UUID = currArgs{j};
        assignContextMenu(newNode,handles);
    end

    expand(argNode);
end