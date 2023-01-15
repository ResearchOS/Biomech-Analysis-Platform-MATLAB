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

% Load project-specific file.
fullPath=getClassFilePath_PS(selNode.Text, 'Process', fig);
struct=loadJSON(fullPath);

inputVarsPS=struct.InputVariables;
outputVarsPS=struct.OutputVariables;

% Load project-independent file.
piText=getPITextFromPS(selNode.Text);
fullPathPI=getClassFilePath(piText{1}, 'Process', fig);
piStruct=loadJSON(fullPathPI);

inputVarsPI=piStruct.InputVariablesNamesInCode;
outputVarsPI=piStruct.OutputVariablesNamesInCode;

% Create input variable nodes
for i=1:length(inputVarsPI)

    if ~iscell(inputVarsPS) || isempty(inputVarsPS{i})
        continue;
    end

    try
        currArgs=inputVarsPS{i};
    catch
        currArgs='';
    end
    currArgsPI=inputVarsPI{i};
    argNode=uitreenode(uiTree,'Text',['getArg ' num2str(currArgsPI{1})]); % The ID number of the getArg/setArg is the first element.    
    
    for j=2:length(currArgsPI)
        if ~iscell(currArgs) || length(currArgs)<j || isempty(currArgs{j})
            uitreenode(argNode,'Text',currArgsPI{j});
        else
            uitreenode(argNode,'Text',[currArgsPI{j} ' (' currArgs{j} ')']);
        end
    end
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
            uitreenode(argNode,'Text',currArgsPI{j});
        else
            uitreenode(argNode,'Text',[currArgsPI{j} ' (' currArgs{j} ')']);
        end
    end

end