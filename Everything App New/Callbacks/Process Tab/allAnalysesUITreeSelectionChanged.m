function []=allAnalysesUITreeSelectionChanged(src)

%% PURPOSE: WHEN THE CURRENTLY SELECTED ANALYSIS NODE IS CHANGED,

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');