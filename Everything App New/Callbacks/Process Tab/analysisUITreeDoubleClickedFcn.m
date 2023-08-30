function []=analysisUITreeDoubleClickedFcn(src)

%% PURPOSE: AFTER DOUBLE CLICK, NAVIGATE TO THE SELECTED NODE'S UI TREE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentFunctionTab;