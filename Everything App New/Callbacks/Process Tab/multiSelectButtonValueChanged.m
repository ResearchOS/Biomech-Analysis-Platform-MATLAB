function []=multiSelectButtonValueChanged(src,event)

%% PURPOSE: SELECT WHETHER MULTIPLE NODES CAN BE SELECTED AT ONCE. SELECTING MULTIPLE NODES IS HELPFUL FOR CREATING/MODIFYING VIEWS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value = handles.Process.multiSelectButton.Value;

setappdata(fig,'multiSelect',value);