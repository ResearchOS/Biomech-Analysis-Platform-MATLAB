function []=sortPlotDropDownValueChanged(src,event)

%% PURPOSE: SORT THE LIST OF PLOTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');