function []=varsUITreeSelectionChanged(src,event)

%% PURPOSE: 
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');