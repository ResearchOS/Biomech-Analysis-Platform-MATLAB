function []=hardCodedValueChanged(src)

%% PURPOSE: CHANGE THE HARD-CODED VALUE OF THE COMPONENT'S VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');