function []=argNameInCodeFieldValueChanged(src,nameInCode,nodeNum)

%% PURPOSE: SAVE CHANGES TO THE ARGUMENT'S NAME IN CODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('nameInCode','var')~=1
    nameInCode=handles.Process.argNameInCodeField.Value;
    runLog=true;
else
    handles.Process.argNameInCodeField.Value=nameInCode;
    runLog=false;
end

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    return;
end

if exist('nodeNum','var')~=1
    nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
else
    handles.Process.fcnArgsUITree.SelectedNodes=findobj(handles.Process.fcnArgsUITree,'NodeData',nodeNum);
end
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

if runLog
    desc='Changed argument name in code';
    updateLog(fig,desc,nameInCode,nodeNum);
end