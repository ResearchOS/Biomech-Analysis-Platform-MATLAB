function []=pgui()

%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED AT THE COMMAND LINE TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
% THIS FUNCTION CREATES ALL COMPONENTS, AND CONTAINS THE CALLBACKS FOR ALL COMPONENTS IN THE GUI.

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR OF DOUGLAS ERIC TILLMAN, 10/29/1961-07/05/2021

addpath(genpath(fileparts(mfilename('fullpath')))); % Add all subfolders to the path so that app creation & management is unencumbered.

%% Create figure & store its attributes
fig=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@appResize); % Create the figure window for the app
fig.Name='pgui'; % Name the window
defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',defaultPos); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)

%% Initialize app data
setappdata(fig,'projectName',''); % projectName always begins empty.
setappdata(fig,'logsheetPath',''); % logsheetPath always begins empty.
setappdata(fig,'dataPath',''); % dataPath always begins empty.
setappdata(fig,'codePath',''); % codePath always begins empty.
setappdata(fig,'rootSavePlotPath',''); % rootSavePlotPath always begins empty.

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
importTab=uitab(tabGroup1,'Title','Import','AutoResizeChildren','off','SizeChangedFcn',@(importTab,event) importResize(importTab)); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','AutoResizeChildren','off'); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','AutoResizeChildren','off'); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats','AutoResizeChildren','off'); % Create the stats tab
settingsTab=uitab(tabGroup1,'Title','Settings','AutoResizeChildren','off'); % Create the settings tab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
projectNameLabel=uilabel(importTab);
projectNameLabel.Text='Project Name';
logsheetPathLabel=uilabel(importTab);
logsheetPathLabel.Text='Logsheet Path';
dataPathLabel=uilabel(importTab);
dataPathLabel.Text='Data Path';
codePathLabel=uilabel(importTab);
codePathLabel.Text='Code Path';
projectNameField=uieditfield(importTab,'text','Value','Project Name','ValueChangedFcn',@(projectNameField,event) projectNameFieldValueChanged(projectNameField)); % Project name edit field
logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));
% logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField)); % Logsheet path name edit field (ends with .xlsx or .xls)
dataPathField=uieditfield(importTab,'text','Value','Data Path (contains ''Subject Data'' folder)'); % Data path name edit field (to the folder containing 'Subject Data' folder)
codePathField=uieditfield(importTab,'text','Value','Path to Project Processing Code Folder'); % Code path name edit field (to the folder containing all code for this project).
% Button to open the project's importSettings file.
openImportSettingsButton=uibutton(importTab,'push','Text','Open importSettings.m','ButtonPushedFcn',@(openImportSettingsButton,event) openImportSettingsButtonPushed(openImportSettingsButton,projectNameField.Value));
% Button to open the project's specifyTrials to select which trials to load/import
openSpecifyTrialsButton=uibutton(importTab,'push','Text','Open specifyTrials.m','ButtonPushedFcn',@(openSpecifyTrialsButton,event) openSpecifyTrialsButtonPushed(openSpecifyTrialsButton,projectNameField.Value));
% Button to open the project's specifyVars to select which data from those trials to load.
openSpecifyVarsButton=uibutton(importTab,'push','Text','Open specifyVars.m','ButtonPushedFcn',@(openSpecifyVarsButton,event) openSpecifyVarsButtonPushed(openSpecifyVarsButton,projectNameField.Value));
% Drop down to switch between active projects.
switchProjectsDropDown=uidropdown(importTab,'Items',{'New Project'},'Editable','off','ValueChangedFcn',@(switchProjectsDropDown,event) switchProjectsDropDownValueChanged(switchProjectsDropDown));
% Checkbox to redo import (overwrites all existing data files)
redoImportCheckbox=uicheckbox(importTab,'Text','Redo (Overwrite) Import','Value',0,'ValueChangedFcn',@(redoImportCheckbox,event) redoImportCheckboxValueChanged(redoImportCheckbox));
% Checkbox to add new data types to existing files
addDataTypesCheckbox=uicheckbox(importTab,'Text','Add Data Types','Value',0,'ValueChangedFcn',@(addDataTypesCheckbox,event) addDataTypesCheckboxValueChanged(addDataTypesCheckbox));
% Checkbox to update metadata only in existing files
updateMetadataCheckbox=uicheckbox(importTab,'Text','Update Metadata Only','Value',0','ValueChangedFcn',@(updateMetadataCheckbox,event) updateMetadataCheckboxValueChanged(updateMetadataCheckbox));
% Button to run the import/load procedure
runImportButton=uibutton(importTab,'push','Text','Run Import/Load','ButtonPushedFcn',@(runImportButton,event) runImportButtonPushed(runImportButton));

importTab.UserData=struct('ProjectNameLabel',projectNameLabel,'LogsheetNameLabel',logsheetPathLabel,'DataPathLabel',dataPathLabel,'CodePathLabel',codePathLabel,...
    'ProjectNameField',projectNameField,'LogsheetPathField',logsheetPathField,'DataPathField',dataPathField,'CodePathField',codePathField,...
    'OpenImportSettingsButton',openImportSettingsButton,'OpenSpecifyTrialsButton',openSpecifyTrialsButton,'OpenSpecifyVarsButton',openSpecifyVarsButton,...
    'SwitchProjectsDropDown',switchProjectsDropDown,'RedoImportCheckBox',redoImportCheckbox,'AddDataTypesCheckBox',addDataTypesCheckbox,'UpdateMetadataCheckBox',updateMetadataCheckbox,'RunImportButton',runImportButton);

importResize(importTab); % Run the importResize to set all components' positions to their correct positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
% a=uilabel(processTab);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AFTER COMPONENT INITIALIZATION
%% Read any existing projects' info (path names, etc.), store them, and display them.
[A,allProjectsTxt]=readAllProjects(); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
setappdata(fig,'allProjectsTxtPath',allProjectsTxt); % Store the address of the 'allProjects_ProjectNamesPaths.txt' file
if iscell(A) % The file exists and has a pre-existing project in it.
    allProjectsList=getAllProjectNames(A);
else
    allProjectsList='';
end
setappdata(fig,'allProjectsList',allProjectsList);
if ~isempty(allProjectsList) % Ensure that there are project names present.
    numLines=length(A);
    mostRecentProjPrefix='Most Recent Project Name:';
    for i=numLines:-1:1 % Go backwards because this is always at the end of the file.
        if contains(A{i},mostRecentProjPrefix) % This is the line with the last used project name.
            mostRecentProjectName=A{i}(length(mostRecentProjPrefix)+2:length(A{i}));
        end
        break;
    end
    setappdata(fig,'projectName',mostRecentProjectName); % projectName always begins empty.
    projectNameField.Value=getappdata(fig,'projectName');
    projectNamePaths=isolateProjectNamesPaths(A,mostRecentProjectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data.
    if isfield(projectNamePaths,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNamePaths.LogsheetPath);
        logsheetPathField.Value=getappdata(fig,'logsheetPath');
    end
    if isfield(projectNamePaths,'DataPath')
        setappdata(fig,'dataPath',projectNamePaths.DataPath);
        dataPathField.Value=getappdata(fig,'dataPath');
    end
    if isfield(projectNamePaths,'CodePath')
        setappdata(fig,'codePath',projectNamePaths.CodePath);
        codePathField.Value=getappdata(fig,'codePath');
    end
    if isfield(projectNamePaths,'RootSavePlotPath')
        setappdata(fig,'rootSavePlotPath',projectNamePaths.RootSavePlotPath);
        %     rootSavePlotPathField.Value=getappdata(fig,'rootSavePlotPath');
    end
    
    % Display the project info in the text edit fields.
    switchProjectsDropDown.Items=allProjectsList;
    switchProjectsDropDown.Value=getappdata(fig,'projectName');
else % The file does not exist, or exists and has nothing in it.
    
end

assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected