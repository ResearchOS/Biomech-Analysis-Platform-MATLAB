function []=isHardCodedCheckboxValueChanged(src)

%% PURPOSE: INDICATE THAT THIS VARIABLE IS HARD-CODED
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

isHC=handles.isHardCoded.Value;

handles.assignVarButton.Visible=~isHC;
handles.unassignVarButton.Visible=~isHC;
handles.selVarsListbox.Visible=~isHC;
handles.varsListbox.Visible=~isHC;
handles.hardCodedTextArea.Visible=~isHC;
handles.subvarsTextArea.Visible=~isHC;
handles.varNameInCodeEditField.Visible=~isHC;
handles.hardCodedTextArea.Visible=isHC;

structComp=getappdata(fig,'structComp');

structComp.IsHardCoded=isHC;

setappdata(fig,'structComp',structComp);
setappdata(fig,'handles',handles);