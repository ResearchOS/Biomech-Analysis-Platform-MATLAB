function []=unassignVarsButtonPushed(src,event)

%% PURPOSE: REMOVE AN INPUT OR OUTPUT VARIABLE FROM THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

assert(ismember('Digraph',projectSettingsVarNames));

load(projectSettingsMATPath,'Digraph');

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
    Digraph.Nodes.InputVariableNames{nodeRow}=Digraph.Nodes.InputVariableNames{nodeRow}(~varIdx);
    Digraph.Nodes.InputVariableNamesInCode{nodeRow}=Digraph.Nodes.InputVariableNamesInCode{nodeRow}(~varIdx);
    b=findobj(a,'Text','Inputs');
elseif ismember('Outputs',b.Text)
    varIdx=ismember(Digraph.Nodes.OutputVariableNames{nodeRow},varName);
    Digraph.Nodes.OutputVariableNames{nodeRow}=Digraph.Nodes.OutputVariableNames{nodeRow}(~varIdx);
    Digraph.Nodes.OutputVariableNamesInCode{nodeRow}=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}(~varIdx);
    b=findobj(a,'Text','Outputs');
end

c=findobj(b,'Text',varName);
delete(c);

handles.Process.fcnArgsUITree.SelectedNodes=a;
handles.Process.argDescriptionTextArea.Value={''};
handles.Process.convertVarHardDynamicButton.Value=0;
handles.Process.argNameInCodeField.Value='';

% highlightedFcnsChanged(fig,Digraph,nodeNum);

save(projectSettingsMATPath,'Digraph','-append');