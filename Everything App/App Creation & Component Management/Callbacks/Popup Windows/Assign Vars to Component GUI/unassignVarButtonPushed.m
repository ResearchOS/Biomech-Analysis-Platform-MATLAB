function []=unassignVarButtonPushed(src)

%% PURPOSE: ASSIGN A DYNAMIC VARIABLE TO THE COMPONENT'S VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

selVarNode=handles.selVarsListbox.SelectedNodes;
if isempty(selVarNode)
    disp('Must select a variable!');
    return;
end

pgui=findall(0,'Name','pgui');
VariableNamesList=getappdata(pgui,'VariableNamesList');

varName=selVarNode.Text;

idx=ismember(comp.Names,varName);
comp.Names=comp.Names(~idx);
comp.NamesInCode=comp.NamesInCode(~idx);
comp.IsHardCoded=comp.IsHardCoded(~idx);

[~,idx]=sort(upper(VariableNamesList.GUINames));
setappdata(fig,'structComp',comp);
makeVarNodesPlotArgsPopup(fig,idx,VariableNamesList,comp);