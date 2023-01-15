function []=groupUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE CURRENT FUNCTION'S VARIABLES IN THE FUNCTIONS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fillCurrentFunctionUITree(fig);