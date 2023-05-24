function []=selVarsUITreeValueChanged(src,event)

%% PURPOSE: UPDATE THE SUBVARS BASED ON THE CURRENTLY SELECTED ASSIGNED VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
dim=handles.dimDropDown.Value;

selNode=handles.selVarsUITree.SelectedNodes;

idx=ismember(handles.selVarsUITree.Children,selNode);

subVar=axLims.(dim).SubvarNames{idx};

handles.subVarEditField.Value=subVar;