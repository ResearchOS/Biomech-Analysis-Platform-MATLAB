function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE NUMBER OF HEADER ROWS IN THIS PROJECT'S LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

num=handles.Import.numHeaderRowsField.Value;

if isempty(num)
    return;
end

if num<0
    warning(['Number of header rows in logsheet cannot be negative']);
    return;
end

% Save the number of header rows to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

[~,hostname]=system('hostname'); % Get the name of the current computer
hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.NumHeaderRows=num;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');