function []=dimDropDownValueChanged(src,event)

%% PURPOSE: CHANGE WHICH DIMENSION IS SELECTED FOR AXES LIMITS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

dim=handles.dimDropDown.Value;

axLims=getappdata(fig,'axLims');

currDim=axLims.(dim);

handles.levelDropDown.Value=currDim.Level;
handles.isHardCodedCheckbox.Value=currDim.IsHardCoded;
handles.hardCodedTextArea.Value=currDim.VariableValue;

% Modify subvars UI tree and the subvariable field.

setappdata(fig,'axLims',axLims);
hardCodedCheckboxValueChanged(fig);