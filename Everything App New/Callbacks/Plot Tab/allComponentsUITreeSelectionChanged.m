function []=allComponentsUITreeSelectionChanged(src,event)

%% PURPOSE: SELECT A COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');