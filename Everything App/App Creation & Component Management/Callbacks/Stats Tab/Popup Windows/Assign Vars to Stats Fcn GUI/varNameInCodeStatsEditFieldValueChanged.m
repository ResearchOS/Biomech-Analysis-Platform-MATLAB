function []=varNameInCodeStatsEditFieldValueChanged(src)

%% PURPOSE: STORE CHANGES TO THE VARIABLE NAME IN CODE TO THE PLOTTING VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% comp=getappdata(fig,'structComp');
currNode=getappdata(fig,'currNode');

name=handles.selVarsListbox.SelectedNodes.Text;

nameInCode=handles.varNameInCodeEditField.Value;

idx=ismember(currNode.GUINames,name);

currNode.NamesInCode{idx}=nameInCode;

setappdata(fig,'currNode',currNode);