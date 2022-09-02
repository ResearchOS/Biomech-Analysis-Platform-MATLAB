function []=dataPathFieldValueChanged(src,dataPath)

%% PURPOSE: SETS THE FOLDER LOCATION WHERE ALL OF THE DATA FOR THIS PROJECT IS LOCATED.
% NOTE: CURRENTLY ASSUMES THAT ALL DATA IS IN SUBFOLDERS OF THIS DIRECTORY

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('dataPath','var')~=1
    dataPath=handles.Projects.dataPathField.Value;
    runLog=true;
else
    handles.Projects.dataPathField.Value=dataPath;
    runLog=false;
end

if isempty(dataPath) || isequal(dataPath,'Data Path (contains ''Subject Data'' folder)')
    setappdata(fig,'dataPath','');
    return;
end

if exist(dataPath,'dir')~=7
    warning(['Selected data folder path does not exist: ' dataPath]);
    resetProjectAccess_Visibility(fig,2);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

if ~isequal(dataPath(end),slash)
    dataPath=[dataPath slash];    
end

handles.Projects.dataPathField.Value=dataPath;

if ~isempty(getappdata(fig,'dataPath'))
    warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
    rmpath(genpath(getappdata(fig,'dataPath')));
    warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
end

setappdata(fig,'dataPath',dataPath); % Store the data path name to the figure variable.

macAddress=getComputerID();
projectSettingsMATPath=[getappdata(fig,'codePath') 'Settings_' projectName '.mat'];

% 1. Load the project settings structure MAT file. It should always exist
% by this point!
if exist(projectSettingsMATPath,'file')~=2
    beep;
    disp(['Missing the settings MAT file for project: ' projectName]);
    disp(['Should be located at: ' projectSettingsMATPath]);
    resetProjectAccess_Visibility(fig,1);
    return;
end

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath=dataPath;

addpath(genpath(getappdata(fig,'dataPath')));

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

resetProjectAccess_Visibility(fig,3);

if runLog
    desc='Update the data folder path for this project.';
    updateLog(fig,desc,dataPath);
end