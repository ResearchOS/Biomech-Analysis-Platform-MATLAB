function []=componentSearchFieldValueChanging(src,event)

%% PURPOSE: FILTER THE PLOT COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');