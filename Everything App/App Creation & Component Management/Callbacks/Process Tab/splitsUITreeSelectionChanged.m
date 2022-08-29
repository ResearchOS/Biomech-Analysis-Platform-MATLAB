function []=splitsUITreeSelectionChanged(src,event)

%% PURPOSE: SWITCH THE DISPLAY BETWEEN SPLITS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

highlightedFcnsChanged(fig,Digraph);