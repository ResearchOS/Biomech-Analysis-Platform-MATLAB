function []=sortGroupsDropDownValueChanged(src,event)

%% PURPOSE: SORT THE PROCESSING GROUPS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');