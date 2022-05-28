function []=subjIDColHeaderFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE SUBJECT ID COLUMN HEADER IN THE LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.subjIDColHeaderField.Value;

if isempty(headerName)
    return;
end

% Save the data path to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

[~,hostname]=system('hostname'); % Get the name of the current computer
hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

projectSettingsStruct=load(projectSettingsMATPath);
projectSettingsStruct=projectSettingsStruct.(projectName);

projectSettingsStruct.Import.SubjectIDColHeader=headerName;

eval([projectName '=projectSettingsStruct;']); % Rename the projectSettingsStruct to the projectName

save(projectSettingsMATPath,projectName,'-append');