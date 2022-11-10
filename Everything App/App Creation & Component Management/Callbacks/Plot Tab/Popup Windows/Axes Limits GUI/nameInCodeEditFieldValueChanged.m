function []=nameInCodeEditFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE NAME IN CODE FOR THE SELECTED VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');