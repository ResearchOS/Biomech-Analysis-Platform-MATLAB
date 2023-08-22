function []=sortVariablesDropDownValueChanged(src,event)

%% PURPOSE: SORT THE VARIABLES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

