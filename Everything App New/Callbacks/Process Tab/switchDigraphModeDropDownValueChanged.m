function []=switchDigraphModeDropDownValueChanged(src,event)

%% PURPOSE: SWITCH HOW THE DIGRAPH IS REPRESENTED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% val = handles.Process.switchDigraphModeDropDown.Value;

toggleDigraphCheckboxValueChanged(fig);