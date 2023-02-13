function []=propertiesUITreeSelectionChanged(src,event)

%% PURPOSE: MODIFY THE EDIT PROPERTY TEXT BOX WITH THE CURRENT VALUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');