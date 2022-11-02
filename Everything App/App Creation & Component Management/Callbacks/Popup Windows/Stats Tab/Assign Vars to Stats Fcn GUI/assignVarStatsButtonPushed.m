function []=assignVarStatsButtonPushed(src)

%% PURPOSE: ASSIGN A DYNAMIC VARIABLE TO THE COMPONENT'S VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currNode=getappdata(fig,'currNode');

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

if ismember([selVarName ' (' splitCode ')'],currNode.GUINames)
    disp('Nothing added,selected variable already in this component!');
    return;
end

pgui=findall(0,'Name','pgui');
VariableNamesList=getappdata(pgui,'VariableNamesList');

currNode.GUINames=[currNode.GUINames; {[selVarName ' (' splitCode ')']}]; % Append the GUI name
varNameIdx=ismember(VariableNamesList.GUINames,selVarName);
currNode.NamesInCode=[currNode.NamesInCode; VariableNamesList.SaveNames(varNameIdx)]; % Append the default name in code
currNode.Subvars=[currNode.Subvars; {''}];
% currNode.IsHardCoded=[currNode.IsHardCoded; 0];

varIdx=ismember(currNode.GUINames,[selVarName ' (' splitCode ')']);

[~,idx]=sort(upper(VariableNamesList.GUINames));
setappdata(fig,'currNode',currNode);

a=uitreenode(handles.selVarsListbox,'Text',[selVarName ' (' splitCode ')']);
handles.selVarsListbox.SelectedNodes=a;

handles.varNameInCodeEditField.Value=VariableNamesList.SaveNames{varNameIdx};
handles.subvarsTextArea.Value=currNode.Subvars(varIdx);
% makeVarNodesStatsArgsPopup(fig,idx,VariableNamesList,currNode);