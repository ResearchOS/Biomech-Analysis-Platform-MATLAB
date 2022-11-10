function []=subVarEditFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE SUBVARIABLES FOR THE SELECTED VARIABLE FOR THE CURRENT DIMENSION.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');
dim=handles.dimDropDown.Value;

subVarName=handles.subVarEditField.Value;

axesLims.(dim).SubvarName=subVarName;

setappdata(fig,'axLims',axesLims);