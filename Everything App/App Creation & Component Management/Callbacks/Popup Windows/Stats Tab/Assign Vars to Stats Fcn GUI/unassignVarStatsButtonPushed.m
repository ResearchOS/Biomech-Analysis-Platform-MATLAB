function []=unassignVarStatsButtonPushed(src)

%% PURPOSE: ASSIGN A DYNAMIC VARIABLE TO THE COMPONENT'S VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currNode=getappdata(fig,'currNode');

selVarNode=handles.selVarsListbox.SelectedNodes;
if isempty(selVarNode)
    disp('Must select a variable!');
    return;
end

pgui=findall(0,'Name','pgui');
VariableNamesList=getappdata(pgui,'VariableNamesList');

varName=selVarNode.Text;

idx=ismember(currNode.GUINames,varName);
currNode.GUINames=currNode.GUINames(~idx);
currNode.NamesInCode=currNode.NamesInCode(~idx);
% comp.IsHardCoded=comp.IsHardCoded(~idx);

[~,idx]=sort(upper(VariableNamesList.GUINames));
setappdata(fig,'currNode',currNode);
makeVarNodesStatsArgsPopup(fig,idx,VariableNamesList,currNode);