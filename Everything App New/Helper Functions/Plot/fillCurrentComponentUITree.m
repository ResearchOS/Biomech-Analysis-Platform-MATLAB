function []=fillCurrentComponentUITree(src,event)

%% PURPOSE: FILL THE CURRENT COMPONENT UI TREE WITH THE COMPONENTS ASSIGNED TO THE CURRENT PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

