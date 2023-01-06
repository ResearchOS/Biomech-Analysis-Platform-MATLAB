function []=plotSearchFieldValueChanging(src,event)

%% PURPOSE: FILTER THE LIST OF PLOTS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');