function []=levelDropDownValueChanged(src,event)

%% PURPOSE: CHANGE THE LEVEL FOR SETTING THE AXES LIMITS FOR THE CURRENT DIMENSION.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');

level=handles.levelDropDown.Value;
dim=handles.dimDropDown.Value;

axLims.(dim).Level=level;

setappdata(fig,'axLims',axLims);