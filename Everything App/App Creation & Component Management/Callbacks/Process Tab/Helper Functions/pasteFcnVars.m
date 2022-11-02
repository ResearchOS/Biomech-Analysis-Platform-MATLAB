function []=pasteFcnVars(src,event)

%% PURPOSE: PASTE THE COPIED VARIABLES TO THE NEW FUNCTION
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selFcn=handles.Process.fcnArgsUITree.SelectedNodes;

if ~isequal(selFcn.Parent,handles.Process.fcnArgsUITree) % Ensure that this is a function, not the variables or Input/Output label.
    return;
end

Digraph=getappdata(fig,'Digraph');

nodeNum=selFcn.NodeData;

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

splitText=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitText,' ');
splitName=splitText(1:spaceIdx-1);
splitCode=splitText(spaceIdx+2:end-1);

copiedVars=getappdata(fig,'copiedVars');

if isempty(copiedVars)
    return;
end

Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode])=copiedVars.inputVarNames;
Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])=copiedVars.inputVarNamesInCode;

Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode])=copiedVars.outputVarNames;
Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])=copiedVars.outputVarNamesInCode;

setappdata(fig,'Digraph',Digraph);
setappdata(fig,'copiedVars','');

highlightedFcnsChanged(fig,Digraph);