function []=editPropertyTextAreaValueChanged(src,event)

%% PURPOSE: MODIFY THE SELECTED PROPERTY'S VALUE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');