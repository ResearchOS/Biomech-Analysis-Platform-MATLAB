function []=guiVarCheckboxValueChanged(src,event)

%% PURPOSE: TOGGLE WHETHER TO SAVE A GUI VARIABLE TO THE BASE WORKSPACE WHEN THE FIGURE IS CREATED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

val=handles.Settings.guiVarCheckbox.Value;

% Get project-independent settings struct

% Store the value to the PI settings struct

% Save the PI settings struct