function []=groupsSearchFieldValueChanging(src,event)

%% PURPOSE: FILTER THE LIST OF PROCESSING GROUPS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');