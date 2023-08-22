function []=allPlotsUITreeSelectionChanged(src,event)

%% PURPOSE: CHANGE THE CURRENTLY SELECTED PLOT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');