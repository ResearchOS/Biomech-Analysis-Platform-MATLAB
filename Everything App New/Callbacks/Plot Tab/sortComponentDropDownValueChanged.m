function []=sortComponentDropDownValueChanged(src,event)

%% PURPOSE: SORT PLOT COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');