function []=argNameInCodeFieldValueChanged(src,event)

%% PURPOSE: SAVE CHANGES TO THE ARGUMENT'S NAME IN CODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

nameInCode=handles.Process.argNameInCodeField.Value;

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    return;
end

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
a=handles.Process.fcnArgsUITree.SelectedNodes;
for i=1:2
    if ~isempty(nodeNum)
        break;
    end
    a=a.Parent;
    nodeNum=a.NodeData;
end

assert(~isempty(nodeNum));

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

text=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
splitCode=text(spaceIdx+2:end-1); % Currently selected split.

% Get the selected variable name and whether it is an input or output variable.
varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;
if isequal(handles.Process.fcnArgsUITree.SelectedNodes.Parent.Text,'Inputs')
    varIdx=ismember(Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode]),varName); 
    Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]){varIdx}=nameInCode;
elseif isequal(handles.Process.fcnArgsUITree.SelectedNodes.Parent.Text,'Outputs')
    varIdx=ismember(Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode]),varName);
    Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]){varIdx}=nameInCode;
else
    return;
end

save(projectSettingsMATPath,'Digraph','-append');