function []=switchProjectsDropDownValueChanged(src,event)

tic;
%% PURPOSE: WHEN CHANGING PROJECTS (ADDING NEW OR SWITCHING) PROPAGATE PROJECT SETTINGS TO THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=handles.Import.switchProjectsDropDown.Value;
setappdata(fig,'projectName',projectName);

% 1. Load the project-specific settings MAT file (if it exists)
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
projectNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=projectNames(~ismember(projectNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file

if ismember(projectName,projectNames)
    settingsStruct=load(settingsMATPath,projectName);
    settingsStruct=settingsStruct.(projectName);

    [~,hostname]=system('hostname'); % Get the name of the current computer
    hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

    if isfield(settingsStruct,hostVarName)
        projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

        if exist(projectSettingsMATPath,'file')==2
            projectSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
            projectSettingsStruct=projectSettingsStruct.NonFcnSettingsStruct;
            codePath=projectSettingsStruct.Import.Paths.(hostVarName).CodePath;
        else
            codePath='';
        end

    else
        codePath='';
    end    

else
    codePath='';
end

% 2. Check if the project already exists. If not, need to make all the components invisible.
if ~ismember(projectName,projectNames) || (ismember(projectName,projectNames) && exist(codePath,'dir')~=7)
    % Turn off visibility for everything except new project & code path components
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~(isequal(tabNames{tabNum},'Import') && ismember(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,{'ProjectNameLabel','AddProjectButton','SwitchProjectsDropDown','CodePathButton','CodePathField'}))
                if ~isequal(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,'TabGroup')
                    handles.(tabNames{tabNum}).(compNames{compNum}).Visible=0;
                end
            end
        end
    end
    handles.Import.codePathField.Value='Path to Project Processing Code Folder';
    return;
else
    % Turn all component visibility on.
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~isequal(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,'TabGroup')
                handles.(tabNames{tabNum}).(compNames{compNum}).Visible=1;
            end
        end
    end
end

% 3. Change the GUI fields unrelated to functions & arguments
handles.Import.codePathField.Value=codePath;
handles.Import.dataPathField.Value=projectSettingsStruct.Import.Paths.(hostVarName).DataPath;
handles.Import.logsheetPathField.Value=projectSettingsStruct.Import.Paths.(hostVarName).LogsheetPath;
handles.Import.numHeaderRowsField.Value=projectSettingsStruct.Import.NumHeaderRows;
handles.Import.subjIDColHeaderField.Value=projectSettingsStruct.Import.SubjectIDColHeader;
handles.Import.targetTrialIDColHeaderField.Value=projectSettingsStruct.Import.TargetTrialIDColHeader;
handles.Plot.rootSavePathEditField.Value=projectSettingsStruct.Plot.RootSavePath;

if exist(handles.Import.dataPathField.Value,'dir')==7
    setappdata(fig,'dataPath',handles.Import.dataPathField.Value);
else
    setappdata(fig,'dataPath','');
end

if exist(handles.Import.logsheetPathField.Value,'file')==2
    setappdata(fig,'logsheetPath',handles.Import.logsheetPathField.Value);
else
    setappdata(fig,'logsheetPath','');
end

% 4. Change the GUI fields related to functions & arguments
% Import tab: If no data types have been entered yet, then regardless of whether there are functions in the processing folder, make invisible the
% buttons on the left side of the screen besides "D+"
    % If there is at least one data type, ensure that all of the buttons are visible.

% 5. Set the most recent project to the current project name.
mostRecentProjectName=projectName;
save(getappdata(fig,'settingsMATPath'),'mostRecentProjectName','-append');

% 6. Tell the user that the project has successfully switched
drawnow;
a=toc;
disp(['Success! Switched to project ' projectName ' in ' num2str(a) ' seconds']);