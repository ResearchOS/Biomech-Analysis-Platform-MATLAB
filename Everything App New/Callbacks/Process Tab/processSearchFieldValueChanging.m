function []=processSearchFieldValueChanging(src,event)

%% PURPOSE: FILTER THE PROCESSING FUNCTIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

