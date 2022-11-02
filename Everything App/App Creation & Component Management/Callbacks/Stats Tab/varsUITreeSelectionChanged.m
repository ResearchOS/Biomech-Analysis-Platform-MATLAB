function []=varsUITreeSelectionChanged(src,event)

%% PURPOSE: SELECT THE FIRST SPLIT WHEN SELECTING A NEW VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');