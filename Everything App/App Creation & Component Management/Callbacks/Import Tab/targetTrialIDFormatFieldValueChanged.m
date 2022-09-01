function []=targetTrialIDFormatFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE TARGET TRIAL ID COLUMN HEADER NAME FROM THE LOGSHEET   

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.targetTrialIDColHeaderField.Value;

if isempty(headerName)
    return;
end

% Save the target trial ID column header to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

macAddress=getComputerID();

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath;

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.TargetTrialIDColHeader=headerName;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

logsheetPathFieldValueChanged(fig);