function []=subVarEditFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE SUBVARIABLES FOR THE SELECTED VARIABLE FOR THE CURRENT DIMENSION.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
dim=handles.dimDropDown.Value;

if isempty(handles.selVarsUITree.SelectedNodes)
    handles.subVarEditField.Value='';
    return;
end

subVarName=handles.subVarEditField.Value;

selNode=handles.selVarsUITree.SelectedNodes;

idx=ismember(handles.selVarsUITree.Children,selNode);

axLims.(dim).SubvarNames{idx}=subVarName;

setappdata(fig,'axLims',axLims);