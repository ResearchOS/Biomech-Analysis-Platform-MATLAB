function []=prettyVarsCheckboxValueChanged(src,event)

%% PURPOSE: CHANGE THE EDGE LABELS TO BE PRETTY OR NOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

toggleDigraphCheckboxValueChanged(fig);