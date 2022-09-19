function []=isHardCodedCheckboxValueChanged(src)

%% PURPOSE: INDICATE THAT THIS VARIABLE IS HARD-CODED
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');