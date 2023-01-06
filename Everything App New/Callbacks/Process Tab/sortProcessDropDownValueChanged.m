function []=sortProcessDropDownValueChanged(src,event)

%% PURPOSE: SORT THE LIST OF PROCESSING FUNCTIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

