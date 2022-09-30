function []=isSyncedCheckboxValueChanged(src, event)

%% PURPOSE: TOGGLE BETWEEN THE GROUP-SYNCED VALUE AND THE FUNCTION-SPECIFIC VALUE OF "NAME IN CODE" FOR THE SELECTED ARG

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

nameInCodeVal=handles.nameInCodeEditField.Value;

currVals=handles.fcnListBox.Value;

argsNameInCode=getappdata(fig,'argsNameInCode');
argsDesc=getappdata(fig,'argsDesc');
argNames=getappdata(fig,'argNames');

fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
guiTab=getappdata(fig,'guiTab');

projectName=getappdata(fig,'projectName');

if length(currVals)>1
    % Need to revert to previous state.
    return;
end

idx=ismember(handles.fcnListBox.Items,currVals);
description=argsDesc{idx};
argName=argNames{idx};
currArgsNameInCode=argsNameInCode{idx};