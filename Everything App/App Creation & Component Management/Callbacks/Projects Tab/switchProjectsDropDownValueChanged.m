function []=switchProjectsDropDownValueChanged(src,event)

tic;
%% PURPOSE: WHEN CHANGING PROJECTS (ADDING NEW OR SWITCHING) PROPAGATE PROJECT SETTINGS TO THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=handles.Projects.switchProjectsDropDown.Value;
setappdata(fig,'projectName',projectName);

% 1. Load the project-specific settings MAT file (if it exists)
% Get the path to that file from the project-independent settings MAT file.
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
if exist(settingsMATPath,'file')~=2
    resetProjectAccess_Visibility(fig,1);   
    disp(['Project-specific settings file path could not be found in project-independent settings MAT file (project variable missing)']);
    disp(['To resolve, either enter the Code Path for this project, or check the settings MAT files']);
    setappdata(fig,'codePath','');
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    return;
end

varNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=varNames(~ismember(varNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file

if ~ismember(projectName,projectNames)
    disp(['Unknown error: project name ' projectName ' not found in the list of projects. Try restarting the GUI']);
    return;
end

settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);
macAddress=getComputerID();

if ~isfield(settingsStruct,macAddress) % This project has never been accessed on this computer.
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    disp(['Project-specific settings file path for this computer could not be found in project-independent settings MAT file (computer hostname missing in project variable)']);
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    return;
end

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath; % Get the file path of the project-specific settings MAT file

if exist(projectSettingsMATPath,'file')~=2 % If the project-specific settings MAT file does not exist
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    disp(['The path to the project-specific settings file is not valid. To fix, you can:']);
    disp(['(1) Enter a new code folder path,']);
    disp(['(2) Ensure that the project settings MAT file exists in the current code folder,']);
    disp(['(3) Check the accuracy of the project-independent settings MAT file located at: ' settingsMATPath]);
    return;
end

setappdata(fig,'projectSettingsMATPath',projectSettingsMATPath); % Store the project-specific MAT file path to the GUI.

load(projectSettingsMATPath,'NonFcnSettingsStruct');

%% Projects tab
codePath=NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath;
dataPath=NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath;

if exist(codePath,'dir')==7
    setappdata(fig,'codePath',codePath);
    handles.Projects.codePathField.Value=codePath;
else
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    handles.Projects.codePathField.Value='Path to Project Processing Code Folder';
    return;
end

if exist(dataPath,'dir')==7
    setappdata(fig,'dataPath',dataPath);
    handles.Projects.dataPathField.Value=dataPath;
else
    resetProjectAccess_Visibility(fig,2);
    setappdata(fig,'dataPath','');
    handles.Projects.dataPathField.Value='Data Path (contains ''Subject Data'' folder';
    return;
end

if ~ismember('currTab',varNames)
    currTab='Projects';
else
    load(settingsMATPath,'currTab');
end
hTab=findobj(handles.Tabs.tabGroup1,'Title',currTab);
handles.Tabs.tabGroup1.SelectedTab=hTab;
version=getappdata(fig,'version');
save(settingsMATPath,'version','-append');

%% Import tab
delete(handles.Process.mapFigure.Children);
logsheetPath=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath;
handles.Import.numHeaderRowsField.Value=NonFcnSettingsStruct.Import.NumHeaderRows;
handles.Import.subjIDColHeaderField.Value=NonFcnSettingsStruct.Import.SubjectIDColHeader;
handles.Import.targetTrialIDColHeaderField.Value=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;

if exist(logsheetPath,'file')==2
    handles.Import.logsheetPathField.Value=logsheetPath;
    setappdata(fig,'logsheetPath',handles.Import.logsheetPathField.Value);
    resetProjectAccess_Visibility(fig,4); % Allow all tabs to be used.
    logsheetPathFieldValueChanged(fig,0); % 0 indicates to not re-read the logsheet file.
    varName=handles.Import.logVarsUITree.SelectedNodes.Text;
    handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(varName).TrialSubject;
    handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(varName).DataType;
else
    resetProjectAccess_Visibility(fig,3); % Disallow loading info from logsheet.
    setappdata(fig,'logsheetPath','');
end

%% Process tab
% Delete all graphics objects in the plot, and all splits nodes
% delete(handles.Process.splitsUITree.Children);

% Fill in processing map figure
projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

% Fill in metadata
if ismember('VariableNamesList',projectSettingsVarNames)
    load(projectSettingsMATPath,'VariableNamesList');
    [~,alphabetIdx]=sort(upper(VariableNamesList.GUINames));
    handles.Process.varsListbox.Items=VariableNamesList.GUINames(alphabetIdx);
    handles.Process.varsListbox.Value=VariableNamesList.GUINames{alphabetIdx(1)};
    varsListBoxValueChanged(fig);    
else
    handles.Process.varsListbox.Items={'No Vars'};
    handles.Process.varsListbox.Value='No Vars';    
end

%% Plot tab
handles.Plot.rootSavePathEditField.Value=NonFcnSettingsStruct.Plot.RootSavePath;

if exist(handles.Plot.rootSavePathEditField.Value,'dir')==7
    setappdata(fig,'rootSavePlotPath',handles.Plot.rootSavePathEditField.Value);
else
    setappdata(fig,'rootSavePlotPath','');
end

% 5. Set the most recent project to the current project name.
mostRecentProjectName=projectName;
save(getappdata(fig,'settingsMATPath'),'mostRecentProjectName','-append');

% 6. Store all of the project-specific settings to the GUI.
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
% setappdata(fig,'FcnSettingsStruct',FcnSettingsStruct);

% 7. Tell the user that the project has successfully switched
drawnow;
a=toc;
disp(['Success! Switched to project ' projectName ' in ' num2str(a) ' seconds']);