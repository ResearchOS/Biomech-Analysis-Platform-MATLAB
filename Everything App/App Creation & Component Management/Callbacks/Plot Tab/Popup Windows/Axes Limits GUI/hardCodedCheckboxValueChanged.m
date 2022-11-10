function []=hardCodedCheckboxValueChanged(src,event)

%% PURPOSE: UPDATE THE VALUE OF THE CHECKBOX SPECIFYING IF THE AXES LIMITS SHOULD BE HARD-CODED
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');

dim=handles.dimDropDown.Value;

isHardCoded=handles.isHardCodedCheckbox.Value;

axesLims.(dim).IsHardCoded=isHardCoded;
% axesLims.(dim).Level='P';

% Update visibility.
handles.varsUITree.Visible=~isHardCoded;
handles.selVarsUITree.Visible=~isHardCoded;
handles.assignVarButton.Visible=~isHardCoded;
handles.unassignVarButton.Visible=~isHardCoded;
handles.nameInCodeEditField.Visible=~isHardCoded;
handles.subVarEditField.Visible=~isHardCoded;
handles.hardCodedTextArea.Visible=isHardCoded;
handles.levelDropDown.Visible=~isHardCoded;
handles.searchEditField.Visible=~isHardCoded;

% handles.levelDropDown.Value='P';

setappdata(fig,'axLims',axesLims);