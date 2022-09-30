function []=copyFcnVars(src,event)

%% PURPOSE: COPY THE VARIABLES FROM A FUNCTION (INPUT & OUTPUT)
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selFcn=handles.Process.fcnArgsUITree.SelectedNodes;

if ~isequal(selFcn.Parent,handles.Process.fcnArgsUITree) % Ensure that this is a function, not the variables or Input/Output label.
    return;
end

splitText=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitText,' ');
splitName=splitText(1:spaceIdx-1);
splitCode=splitText(spaceIdx+2:end-1);

Digraph=getappdata(fig,'Digraph');

nodeNum=selFcn.NodeData;

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

copiedVars.inputVarNames=Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode]);
copiedVars.inputVarNamesInCode=Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]);

copiedVars.outputVarNames=Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode]);
copiedVars.outputVarNamesInCode=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]);

setappdata(fig,'copiedVars',copiedVars);