function []=fcnArgsVersionDropDownValueChanged(src,event)

%% PURPOSE: CHANGE THE ARG NAMES DISPLAYED WHEN SELECTING BETWEEN DIFFERENT LETTERS OF THE FUNCTION'S ARGS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

setappdata(fig,'argsNameInCode','');
setappdata(fig,'argsDesc','');

% Get the current function name, group name, version letter, and guiTab.
fcnName=getappdata(fig,'fcnName');
groupName=getappdata(fig,'groupName');
letter=handles.fcnArgsVersionDropDown.Value;
guiTab=getappdata(fig,'guiTab');
projectName=getappdata(fig,'projectName');

% Read through the txt file to find the args in the current function, group, and guiTab combo.
[text,~]=readAllArgsTextFile(getappdata(fig,'everythingPath'),projectName,guiTab);
[argNames,argsNameInCode,argsDesc]=getAllArgNames(text,projectName,guiTab,groupName,fcnName);

% Put those args into the fcn list box.
handles.fcnListBox.Items=argNames;
setappdata(fig,'argsNameInCode',argsNameInCode);
setappdata(fig,'argsDesc',argsDesc);
setappdata(fig,'argNames',argNames);

% Populate the text boxes and check box with the appropriate metadata.
if isempty(handles.fcnListBox.Items)
    handles.fcnListBox.Items={'No Args'};
end
handles.fcnListBox.Value=handles.fcnListBox.Items(1); % Set the selection to be the first in the list.
fcnListBoxValueChanged(fig);

% Modify the pgui to reflect the proper args letter!!
