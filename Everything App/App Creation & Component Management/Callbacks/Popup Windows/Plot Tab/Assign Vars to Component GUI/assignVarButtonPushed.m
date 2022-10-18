function []=assignVarButtonPushed(src)

%% PURPOSE: ASSIGN A DYNAMIC VARIABLE TO THE COMPONENT'S VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

selVarNode=handles.varsListbox.SelectedNodes;
if isempty(selVarNode)
    disp('Must select a variable!');
    return;
end

if isequal(selVarNode.Parent,handles.varsListbox)
    disp('Must select the split, not the variable itself!');
    return;
end

selVarName=selVarNode.Parent.Text;
selVarSplit=selVarNode.Text;
spaceIdx=strfind(selVarSplit,' ');
splitCode=selVarSplit(spaceIdx(end)+2:end-1);

if ismember([selVarName ' (' splitCode ')'],comp.Names)
    disp('Nothing added,selected variable already in this component!');
    return;
end

pgui=findall(0,'Name','pgui');
VariableNamesList=getappdata(pgui,'VariableNamesList');

comp.Names=[comp.Names; {[selVarName ' (' splitCode ')']}]; % Append the GUI name
varNameIdx=ismember(VariableNamesList.GUINames,selVarName);
comp.NamesInCode=[comp.NamesInCode; VariableNamesList.SaveNames(varNameIdx)]; % Append the default name in code
comp.IsHardCoded=[comp.IsHardCoded; 0];
comp.Subvars=[comp.Subvars; {''}];

[~,idx]=sort(upper(VariableNamesList.GUINames));
setappdata(fig,'structComp',comp);

a=uitreenode(handles.selVarsListbox,'Text',[selVarName ' (' splitCode ')']);
handles.selVarsListbox.SelectedNodes=a;
handles.varNameInCodeEditField.Value=VariableNamesList.SaveNames{varNameIdx};
handles.subvarsTextArea.Value={''};
% makeVarNodesPlotArgsPopup(fig,idx,VariableNamesList,comp);