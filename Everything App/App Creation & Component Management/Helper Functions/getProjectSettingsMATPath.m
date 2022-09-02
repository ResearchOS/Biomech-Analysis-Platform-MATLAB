function [projectSettingsMATPath]=getProjectSettingsMATPath(fig,projectName)

%% PURPOSE: Return the file path of the project settings MAT file
% Inputs:
% fig: The figure object (graphics object)
% projectName: The project name to get the settings file for (char)

macAddress=getComputerID();

settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path

settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

if ~isfield(settingsStruct,macAddress)
    beep;
    disp(['Missing the settings MAT file path for project: ' projectName]);
    disp(['Check the project-independent settings file located at: ' settingsMATPath]);
    return;
end

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath; % Isolate the path to the project settings MAT file.

if getappdata(fig,'isRunLog')
    projectSettingsMATPath=[projectSettingsMATPath '_RunLog.mat'];
end

if exist(projectSettingsMATPath,'file')~=2
    beep;
    disp(['Missing the settings MAT file for project: ' projectName]);
    disp(['Should be located at: ' projectSettingsMATPath]);
    return;
end