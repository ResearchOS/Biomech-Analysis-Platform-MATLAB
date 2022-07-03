function []=codePathFieldValueChanged(src,event)

%% PURPOSE: PROPAGATE CHANGES TO THE CODE PATH EDIT FIELD TO THE SAVED SETTINGS AND THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

codePath=handles.Projects.codePathField.Value;

if isempty(codePath) || isequal(codePath,'Path to Project Processing Code Folder')
    setappdata(fig,'codePath','');
    return;
end

if exist(codePath,'dir')~=7
    warning(['Selected code folder path does not exist: ' codePath]);
    resetProjectAccess_Visibility(fig,1);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

if ~isequal(codePath(end),slash)
    codePath=[codePath slash];    
end

handles.Projects.codePathField.Value=codePath;

if ~isempty(getappdata(fig,'codePath'))
    warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
    rmpath(genpath(getappdata(fig,'codePath'))); % Remove the old code path (if any) from the matlab path
    warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
end

setappdata(fig,'codePath',codePath);

macAddress=getComputerID();
projectSettingsMATPath=[codePath 'Settings_' projectName '.mat']; % The project-specific settings MAT file in the project's code folder

% 1. Load the project settings structure MAT file, if it exists.
if exist(projectSettingsMATPath,'file')==2
    NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
    NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;
end

% 3. If the project settings structure MAT file does not exist, initialize the project-specific settings with default values for all GUI components.
if exist(projectSettingsMATPath,'file')~=2
    % Just missing the data type-specific trial ID column header, and of course the UI trees and description text areas
    NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath='Data Path (contains ''Subject Data'' folder)';
    NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath='Logsheet Path (ends in .xlsx)';
    NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT='';
    NonFcnSettingsStruct.Import.NumHeaderRows=-1;
    NonFcnSettingsStruct.Import.SubjectIDColHeader='Subject ID Column Header';
    NonFcnSettingsStruct.Import.TargetTrialIDColHeader='Target Trial ID Column Header';
    NonFcnSettingsStruct.Plot.RootSavePath='Root Save Path';
    NonFcnSettingsStruct.ProjectName=projectName;

    % Function-specific settings struct
    % Cell arrays contain all names of that type, whether being used/displayed or not (helpful for listing all functions/args at the bottom of the UI tree)
    
    % Import
%     FcnSettingsStruct.Import.DataTypes={''};
%     FcnSettingsStruct.Import.FcnNames={''};
%     FcnSettingsStruct.Import.Arguments={''};
    FcnSettingsStruct.Import.FcnUITree.All={''};
    FcnSettingsStruct.Import.ArgsUITree.All={''};

    % Process
    FcnSettingsStruct.Process.Groups={''};
%     FcnSettingsStruct.Process.FcnNames={''};
%     FcnSettingsStruct.Process.Arguments={''};
    FcnSettingsStruct.Process.FcnUITree.All={''};
    FcnSettingsStruct.Process.ArgsUITree.All={''};

    % Plot
    FcnSettingsStruct.Plot.PlotTypes={''};
%     FcnSettingsStruct.Plot.FcnNames={''};
%     FcnSettingsStruct.Plot.Arguments={''};
    FcnSettingsStruct.Plot.FcnUITree.All={''};
    FcnSettingsStruct.Plot.ArgsUITree.All={''};
end

NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath=codePath;

% eval([projectName '=NonFcnSettingsStruct;']); % Rename the NonFcnSettingsStruct to the projectName
if exist(projectSettingsMATPath,'file')==2    
    varNames=who('-file',projectSettingsMATPath);
    if ~ismember('FcnSettingsStruct',varNames)
        save(projectSettingsMATPath,'NonFcnSettingsStruct','FcnSettingsStruct','-append');
    else
        save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % FcnSettingsStruct not changed here, so it's not loaded here.
    end
else
    save(projectSettingsMATPath,'NonFcnSettingsStruct','FcnSettingsStruct','-mat','-v6');
end

% Add the projectSettingsMATPath to the project-independent settings MAT path
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

settingsStruct.(macAddress).projectSettingsMATPath=projectSettingsMATPath; % Store the project's settings MAT file path to the project-independent settings structure.

eval([projectName '=settingsStruct;']); % Rename the settingsStruct to the projectName

save(settingsMATPath,projectName,'-append'); % Save the project-independent settings MAT file.

addpath(genpath(getappdata(fig,'codePath'))); % Add the new code path to the matlab path

% Turn data path components visibility on, if not already visible.
if handles.Projects.dataPathField.Visible==0
    resetProjectAccess_Visibility(fig,2);
elseif exist(handles.Projects.dataPathField.Value,'file')==2
    resetProjectAccess_Visibility(fig,3);
end

% Propagate changes to the rest of the GUI.
% switchProjectsDropDownValueChanged(fig);