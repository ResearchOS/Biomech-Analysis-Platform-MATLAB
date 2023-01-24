function []=fillCurrentComponentUITree(src,event)

%% PURPOSE: FILL THE CURRENT COMPONENT UI TREE WITH THE COMPONENTS ASSIGNED TO THE CURRENT PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.plotUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uiTree=handles.Plot.componentUITree;

delete(uiTree.Children);

% Load project-specific file.
fullPathPS=getClassFilePath_PS(selNode.Text, 'Component', fig);
struct=loadJSON(fullPathPS);

inputVarsPS=struct.InputVariables;

% Load project-independent file.
piText=getPITextFromPS(selNode.Text);
fullPathPI=getClassFilePath(piText, 'Component', fig);
piStruct=loadJSON(fullPathPI);

inputVarsPI=piStruct.InputVariablesNamesInCode;

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

    expand(argNode);
end