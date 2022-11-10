function []=hardCodedTextAreaValueChanged(src,event)

%% PURPOSE: CHANGE THE HARD CODED VALUE FOR THE AXES LIMITS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

hardCodedValue=handles.hardCodedTextArea.Value;
dim=handles.dimDropDown.Value;

axesLims=getappdata(fig,'axLims');

axesLims.(dim).VariableValue=hardCodedValue;

setappdata(fig,'axLims',axesLims);