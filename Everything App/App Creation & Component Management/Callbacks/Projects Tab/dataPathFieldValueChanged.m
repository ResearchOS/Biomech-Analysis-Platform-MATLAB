function []=dataPathFieldValueChanged(src,event)

%% PURPOSE: SETS THE FOLDER LOCATION WHERE ALL OF THE DATA FOR THIS PROJECT IS LOCATED.
% NOTE: CURRENTLY ASSUMES THAT ALL DATA IS IN SUBFOLDERS OF THIS DIRECTORY

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

dataPath=handles.Import.dataPathField.Value;

if isempty(dataPath) || isequal(dataPath,'Data Path (contains ''Subject Data'' folder)')
    setappdata(fig,'dataPath','');
    return;
end

if exist(dataPath,'dir')~=7
    warning(['Incorrect data folder path: ' dataPath]);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

if ~isequal(dataPath(end),slash)
    dataPath=[dataPath slash];
    handles.Import.dataPathField.Value=dataPath;
end

if ~isempty(getappdata(fig,'dataPath'))
    warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
    rmpath(genpath(getappdata(fig,'dataPath')));
    warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
end

setappdata(fig,'dataPath',dataPath); % Store the data path name to the figure variable.

addpath(genpath(getappdata(fig,'dataPath')));

% Save the data path to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

[~,macAddress]=system('ifconfig en0 | grep ether'); % Get the name of the current computer
macAddress=genvarname(macAddress); % Generate a valid MATLAB variable name from the computer host name.

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath;

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.Paths.(macAddress).DataPath=dataPath;

% eval([projectName '=NonFcnSettingsStruct;']); % Rename the NonFcnSettingsStruct to the projectName

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');