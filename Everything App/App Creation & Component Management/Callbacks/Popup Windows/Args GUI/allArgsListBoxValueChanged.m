function []=allArgsListBoxValueChanged(src,event)

%% PURPOSE: POPULATE THE METADATA FOR THE CURRENTLY SELECTED ARGUMENT IN THE ALL ARGS BOX (IF MULTIPLE, DON'T SHOW METADATA)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currVals=handles.allArgsListBox.Value;

guiTab=getappdata(fig,'guiTab');

% argsNameInCode=getappdata(fig,'argsNameInCode'); % Don't show name in code when selecting an arg from the all args list box
% argsDesc=getappdata(fig,'argsDesc');

if length(currVals)>1 % Multiple items selected, clear the edit fields
    handles.fullNicknameEditField.Value='Mult';
    handles.nameInCodeEditField.Value='Mult';
    handles.descriptionTextArea.Value='Mult';
else

%     idx=ismember(handles.fcnListBox.Items,currVals);
    handles.fullNicknameEditField.Value=currVals{1};
    if isequal(currVals{1},'No Args')
        return;
    end

    % Get the description for this variable from the text file.
    text=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),guiTab);
    [argNames,~,argsDesc]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,'Unassigned',['Unassigned_' guiTab '1A']);

    currArgIdx=ismember(argNames,currVals);
    currArgsDesc=argsDesc(currArgIdx);

    handles.descriptionTextArea.Value=currArgsDesc;
    handles.nameInCodeEditField.Value='';

end