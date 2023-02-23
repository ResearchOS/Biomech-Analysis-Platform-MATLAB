function []=plotUITreeSelectionChanged(src,event)

%% PURPOSE: CHANGE THE COMPONENT UI TREE FOR THE CORRESPONDING COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fillCurrentComponentUITree(fig);