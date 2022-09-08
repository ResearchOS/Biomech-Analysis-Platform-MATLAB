function []=unassignVarsButtonPushed(src,nodeNum,varNameInGUI,splitCode)

%% PURPOSE: REMOVE AN INPUT OR OUTPUT VARIABLE FROM THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

% projectSettingsVars=whos('-file',projectSettingsMATPath);
% projectSettingsVarNames={projectSettingsVars.name};
% 
% assert(ismember('Digraph',projectSettingsVarNames));

% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(fig,'Digraph');

if isempty(Digraph)
    return;
end

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
a=handles.Process.fcnArgsUITree.SelectedNodes;
b=a.Parent;

if ~isprop(b,'Text') || ~ismember(b.Text,{'Inputs','Outputs'}) % Ensure that this is a variable
    disp('Must have a variable name selected!');
    return;
end

for i=1:2
    if ~isempty(nodeNum)
        break;
    end
    a=a.Parent;
    nodeNum=a.NodeData;
end

assert(~isempty(nodeNum));

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

varName=handles.Process.fcnArgsUITree.SelectedNodes.Text;

text=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
splitCode=text(spaceIdx+2:end-1); % Currently selected split.

if ismember({'Inputs'},b.Text)
    varIdx=ismember(Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode]),varName);
    Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode])=Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode])(~varIdx);
    Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])=Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(~varIdx);
    b=findobj(a,'Text','Inputs');
elseif ismember('Outputs',b.Text)
    varIdx=ismember(Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode]),varName);
    Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode])=Digraph.Nodes.OutputVariableNames{nodeRow}.([splitName '_' splitCode])(~varIdx);
    Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(~varIdx);
    b=findobj(a,'Text','Outputs');
end

c=findobj(b,'Text',varName);
delete(c);

handles.Process.fcnArgsUITree.SelectedNodes=a;
functionsUITreeSelectionChanged(fig);
% handles.Process.argDescriptionTextArea.Value={''};
% handles.Process.convertVarHardDynamicButton.Value=0;
% handles.Process.argNameInCodeField.Value='';

% highlightedFcnsChanged(fig,Digraph,nodeNum);

% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);