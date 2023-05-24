function []=variablesSearchFieldValueChanging(src,event)

%% PURPOSE: FILTER THE VARIABLES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

