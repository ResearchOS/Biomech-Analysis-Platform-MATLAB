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
idxNum=find(idx==1);
if idxNum==length(comp.Names)
    idxNum=idxNum-1;
end
comp.Names=comp.Names(~idx);
comp.NamesInCode=comp.NamesInCode(~idx);
comp.Subvars=comp.Subvars(~idx);
% comp.IsHardCoded=comp.IsHardCoded(~idx);

[~,idx]=sort(upper(VariableNamesList.GUINames));
setappdata(fig,'structComp',comp);


newNodeIdx=find(ismember(handles.selVarsListbox.Children,selVarNode));
if newNodeIdx==length(handles.selVarsListbox.Children)
    newNodeIdx=newNodeIdx-1;
end
delete(selVarNode);
if newNodeIdx>0
    handles.selVarsListbox.SelectedNodes=handles.selVarsListbox.Children(newNodeIdx);
    handles.varNameInCodeEditField.Value=comp.NamesInCode{idxNum};
    handles.subvarsTextArea.Value=comp.Subvars(idxNum);
else
    handles.varNameInCodeEditField.Value='';
    handles.subvarsTextArea.Value='';
end
% uitreenode(handles.selVarsListbox,'Text',[selVarName ' (' splitCode ')']);
% VariableNamesList.SaveNames{varNameIdx};
% handles.subVarsTextArea.Value={''};


% makeVarNodesPlotArgsPopup(fig,idx,VariableNamesList,comp);