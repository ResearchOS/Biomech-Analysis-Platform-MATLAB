function []=selVarsUITreeValueChanged(src,event)

%% PURPOSE: UPDATE THE SUBVARS BASED ON THE CURRENTLY SELECTED ASSIGNED VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');