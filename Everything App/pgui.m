function []=pgui()

%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED AT THE COMMAND LINE TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
% THIS FUNCTION CREATES ALL COMPONENTS, AND CONTAINS THE CALLBACKS FOR ALL COMPONENTS IN THE GUI.

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR OF DOUGLAS ERIC TILLMAN, 10/29/1961-07/05/2021

% Assumes that the app is being run from within the 'Everything App' folder and that the rest of the files & folders are untouched.
addpath(genpath(fileparts(mfilename('fullpath')))); % Add all subfolders to the path so that app creation & management is unencumbered.

% Check if Mac or PC
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

%% Create figure & store its attributes
fig=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@appResize); % Create the figure window for the app
fig.Name='pgui'; % Name the window
defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',defaultPos); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)

%% Initialize app data
setappdata(fig,'everythingPath',[fileparts(mfilename('fullpath')) slash]); % Path to the 'Everything App' folder.
setappdata(fig,'projectName',''); % projectName always begins empty.
setappdata(fig,'logsheetPath',''); % logsheetPath always begins empty.
setappdata(fig,'dataPath',''); % dataPath always begins empty.
setappdata(fig,'codePath',''); % codePath always begins empty.
setappdata(fig,'rootSavePlotPath',''); % rootSavePlotPath always begins empty.

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
importTab=uitab(tabGroup1,'Title','Import','Tag','Import','AutoResizeChildren','off','SizeChangedFcn',@importResize); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','Tag','Process','AutoResizeChildren','off','SizeChangedFcn',@processResize); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','Tag','Plot','AutoResizeChildren','off'); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats','Tag','Stats','AutoResizeChildren','off'); % Create the stats tab
settingsTab=uitab(tabGroup1,'Title','Settings','Tag','Settings','AutoResizeChildren','off'); % Create the settings tab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
projectNameLabel=uilabel(importTab,'Text','Project Name','Tag','ProjectNameLabel','FontWeight','bold');
logsheetPathButton=uibutton(importTab,'push','Text','Logsheet Path','Tag','LogsheetPathButton','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));
dataPathButton=uibutton(importTab,'push','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',@(dataPathButton,event) dataPathButtonPushed(dataPathButton));
codePathButton=uibutton(importTab,'push','Text','Code Path','Tag','CodePathButton','ButtonPushedFcn',@(codePathButton,event) codePathButtonPushed(codePathButton));
% projectNameField=uieditfield(importTab,'text','Value','Enter Project Name','Tag','ProjectNameField','ValueChangedFcn',@(projectNameField,event) projectNameFieldValueChanged(projectNameField)); % Project name edit field
logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','Tag','LogsheetPathField','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));
dataPathField=uieditfield(importTab,'text','Value','Data Path (contains ''Subject Data'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)
codePathField=uieditfield(importTab,'text','Value','Path to Project Processing Code Folder','Tag','CodePathField','ValueChangedFcn',@(codePathField,event) codePathFieldValueChanged(codePathField)); % Code path name edit field (to the folder containing all code for this project).
% Button to open the project's importSettings file.
openImportMetadataButton=uibutton(importTab,'push','Text','Create importMetadata','Tag','OpenImportMetadataButton','ButtonPushedFcn',@(openImportMetadataButton,event) openImportMetadataButtonPushed(openImportMetadataButton));
% Button to open the project's specifyTrials to select which trials to load/import
openGroupSpecifyTrialsButton=uibutton(importTab,'push','Text','Create specifyTrials.m','Tag','OpenSpecifyTrialsButton','ButtonPushedFcn',@(openSpecifyTrialsButton,event) openSpecifyTrialsButtonPushed(openSpecifyTrialsButton));
% Checkbox to redo import (overwrites all existing data files)
redoImportCheckbox=uicheckbox(importTab,'Text','Redo (Overwrite) Import','Value',0,'Tag','RedoImportCheckbox','ValueChangedFcn',@(redoImportCheckbox,event) redoImportCheckboxValueChanged(redoImportCheckbox));
% Checkbox to update metadata only in existing files
% updateMetadataCheckbox=uicheckbox(importTab,'Text','Update Metadata Only','Value',0','Tag','UpdateMetadataCheckbox','ValueChangedFcn',@(updateMetadataCheckbox,event) updateMetadataCheckboxValueChanged(updateMetadataCheckbox));
% Button to run the import/load procedure
runImportButton=uibutton(importTab,'push','Text','Run Import/Load','Tag','RunImportButton','ButtonPushedFcn',@(runImportButton,event) runImportButtonPushed(runImportButton));
% Drop down to switch between active projects.
switchProjectsDropDown=uidropdown(importTab,'Items',{'New Project'},'Editable','off','Tag','SwitchProjectsDropDown','ValueChangedFcn',@(switchProjectsDropDown,event) switchProjectsDropDownValueChanged(switchProjectsDropDown));
% Drop down to specify & open a new data type's importSettings
dataTypeImportSettingsDropDown=uidropdown(importTab,'Items',{'No Data Types to Import'},'Editable','off','Tag','DataTypeImportSettingsDropDown','ValueChangedFcn',@(dataTypeImportSettingsDropDown,event) dataTypeImportSettingsDropDownValueChanged(dataTypeImportSettingsDropDown));
% Logsheet label
logsheetLabel=uilabel(importTab,'Text','Logsheet:','FontWeight','bold');
% Number of header rows label
numHeaderRowsLabel=uilabel(importTab,'Text','# of Header Rows','Tag','NumHeaderRowsLabel');
% Number of header rows text box
numHeaderRowsField=uieditfield(importTab,'numeric','Value',0,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));
% Subject ID column header label
subjIDColHeaderLabel=uilabel(importTab,'Text','Subject ID Column Header','Tag','SubjectIDColumnHeaderLabel');
% Subject ID column header text box
subjIDColHeaderField=uieditfield(importTab,'text','Value','Subject ID Column Header','Tag','SubjIDColumnHeaderField','ValueChangedFcn',@(subjIDColHeaderField,event) subjIDColHeaderFieldValueChanged(subjIDColHeaderField));
% Trial ID column header label
trialIDColHeaderDataTypeLabel=uilabel(importTab,'Text','Data Type: Trial ID Column Header');
% Trial ID column header text box
trialIDColHeaderDataTypeField=uieditfield(importTab,'text','Value','Data Type: Trial ID Column Header','Tag','DataTypeTrialIDColumnHeaderField','ValueChangedFcn',@(trialIDColHeaderField,event) trialIDColHeaderDataTypeFieldValueChanged(trialIDColHeaderField));
% Trial ID format label
% trialIDFormatLabel=uilabel(importTab,'Text','Trial ID Format','Tag','TrialIDFormatLabel');
% % Trial ID format field
% trialIDFormatField=uieditfield(importTab,'text','Value','S T','Tag','TrialIDFormatField','ValueChangedFcn',@(trialIDFormatField,event) trialIDFormatFieldValueChanged(trialIDFormatField));
% Target Trial ID format label
targetTrialIDColHeaderLabel=uilabel(importTab,'Text','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderLabel');
% Target Trial ID format field
targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','T','Tag','TargetTrialIDColHeaderField','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));
% Save all trials button
saveAllButton=uibutton(importTab,'push','Text','Save All In Struct','Tag','SaveAllButton','ButtonPushedFcn',@(saveAllButton,event) saveAllButtonPushed(saveAllButton));
% Load which data label
selectDataPanel=uipanel(importTab,'Title','Select Groups'' Data to Load','Tag','SelectDataPanel','BackGroundColor',[0.9 0.9 0.9],'BorderType','line','FontWeight','bold','TitlePosition','centertop','AutoResizeChildren','off','SizeChangedFcn',@dataSelectPanelResize);
% Need to read the groups text file to get group names. Create
% corresponding number of checkboxes & their labels.
loadLabel=uilabel(importTab,'Text','Load','Tag','LoadLabel');
offloadLabel=uilabel(importTab,'Text','Offload','Tag','OffloadLabel');
dataLabel=uilabel(importTab,'Text','Data','Tag','DataLabel');

% Data types import method number field
dataTypeImportMethodField=uieditfield(importTab,'text','Value','1A','Tag','DataTypeImportMethodField','ValueChangedFcn',@(dataTypeImportMethodField,event) dataTypeImportMethodFieldValueChanged(dataTypeImportMethodField));
% Add new data type to drop down
addDataTypeButton=uibutton(importTab,'push','Text','New Data Type','Tag','AddDataTypeButton','ButtonPushedFcn',@(addDataTypeButton,event) addDataTypeButtonPushed(addDataTypeButton));
% Create new import function
openImportFcnButton=uibutton(importTab,'push','Text','Create Import Fcn','Tag','OpenImportFcnButton','ButtonPushedFcn',@(openImportFcnButton,event) openImportFcnButtonPushed(openImportFcnButton));
% Add new project button
addProjectButton=uibutton(importTab,'push','Text','+','Tag','AddProjectButton','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));
% Open logsheet button
openLogsheetButton=uibutton(importTab,'push','Text','O','Tag','OpenLogsheetButton','ButtonPushedFcn',@(openLogsheetButton,event) openLogsheetButtonPushed(openLogsheetButton));
% Open data path button
openDataPathButton=uibutton(importTab,'push','Text','O','Tag','OpenDataPathButton','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));
% Open code path button
openCodePathButton=uibutton(importTab,'push','Text','O','Tag','OpenCodePathButton','ButtonPushedFcn',@(openCodePathButton,event) openCodePathButtonPushed(openCodePathButton));
% Open logsheet2Struct button
openLogsheet2StructButton=uibutton(importTab,'push','Text','Create logsheet2Struct','Tag','OpenLogsheet2StructButton','ButtonPushedFcn',@(openLogsheet2StructButton,event) openLogsheet2StructButtonPushed(openLogsheet2StructButton));

importTab.UserData=struct('ProjectNameLabel',projectNameLabel,'LogsheetPathButton',logsheetPathButton,'DataPathButton',dataPathButton,'CodePathButton',codePathButton,...
    'AddProjectButton',addProjectButton,'LogsheetPathField',logsheetPathField,'DataPathField',dataPathField,'CodePathField',codePathField,'DataTypeImportSettingsDropDown',dataTypeImportSettingsDropDown,...
    'OpenImportMetadataButton',openImportMetadataButton,'OpenSpecifyTrialsButton',openGroupSpecifyTrialsButton,'SwitchProjectsDropDown',switchProjectsDropDown,'RedoImportCheckBox',redoImportCheckbox,...
    'RunImportButton',runImportButton,'LogsheetLabel',logsheetLabel,'NumHeaderRowsLabel',numHeaderRowsLabel,'NumHeaderRowsField',numHeaderRowsField,...
    'SubjectIDColHeaderLabel',subjIDColHeaderLabel,'SubjectIDColHeaderField',subjIDColHeaderField,'TrialIDColHeaderDataTypeLabel',trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',trialIDColHeaderDataTypeField,...
    'TargetTrialIDColHeaderLabel',targetTrialIDColHeaderLabel,'TargetTrialIDColHeaderField',targetTrialIDColHeaderField,...
    'SaveAllButton',saveAllButton,'SelectDataPanel',selectDataPanel,'DataTypeImportMethodField',dataTypeImportMethodField,'AddDataTypeButton',addDataTypeButton,'OpenImportFcnButton',openImportFcnButton,...
    'OpenLogsheetButton',openLogsheetButton,'OpenDataPathButton',openDataPathButton','OpenCodePathButton',openCodePathButton,'OpenLogsheet2StructButton',openLogsheet2StructButton,...
    'LoadLabel',loadLabel,'OffloadLabel',offloadLabel,'DataLabel',dataLabel);

@importResize; % Run the importResize to set all components' positions to their correct positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
processTabGroup=uitabgroup(processTab,'Tag','ProcessTabGroup','AutoResizeChildren','off');
processSetupTab=uitab(processTabGroup,'Title','Setup','Tag','Setup','AutoResizeChildren','off'); % Create the process > setup tab
processRunTab=uitab(processTabGroup,'Title','Run','Tag','Run','AutoResizeChildren','off'); % Create the process > run tab

% Create the Process > Setup tab
% Function Group Name Label
setupGroupNameLabel=uilabel(processSetupTab,'Text','Group Name','Tag','SetupGroupNameLabel');
setupGroupNameDropDown=uidropdown(processSetupTab,'Items',{'Create Function Group'},'Editable','Off','Tag','SetupGroupNameDropDown');
setupFunctionNamesLabel=uilabel(processSetupTab,'Text','Function Names','Tag','SetupFunctionNamesLabel');
setupFunctionNamesField=uitextarea(processSetupTab,'Value','Function Names','Tag','SetupFunctionNamesField','Editable','on','Visible','on');
newFunctionPanel=uipanel(processSetupTab,'Title','New Function','Tag','NewFunctionPanel','BackGroundColor',[0.9 0.9 0.9],'BorderType','line','FontWeight','bold','TitlePosition','centertop');
saveGroupButton=uibutton(processSetupTab,'push','Text','Save Group To File','Tag','SaveGroupButton');
inputsLabel=uilabel(processSetupTab,'Text','Inputs','Tag','InputsLabel');
outputsLabel=uilabel(processSetupTab,'Text','Outputs','Tag','OutputsLabel');
inputCheckboxP=uicheckbox(processSetupTab,'Text','Project','Value',0,'Tag','InputCheckboxProject');
inputCheckboxS=uicheckbox(processSetupTab,'Text','Subject','Value',0,'Tag','InputCheckboxSubject');
inputCheckboxT=uicheckbox(processSetupTab,'Text','Trial','Value',0,'Tag','InputCheckboxTrial');
outputCheckboxP=uicheckbox(processSetupTab,'Text','Project','Value',0,'Tag','OutputCheckboxProject');
outputCheckboxS=uicheckbox(processSetupTab,'Text','Subject','Value',0,'Tag','OutputCheckboxSubject');
outputCheckboxT=uicheckbox(processSetupTab,'Text','Trial','Value',0,'Tag','OutputCheckboxTrial');
newFunctionButton=uibutton(processSetupTab,'push','Text','Create New Function','Tag','NewFunctionButton');
addFunctionGroupButton=uibutton(processSetupTab,'push','Text','+','Tag','AddFunctionGroupButton','ButtonPushedFcn',@(addFunctionGroupButton,event) addFunctionGroupButtonPushed(addFunctionGroupButton));

% Create the Process > Run tab
runGroupNameLabel=uilabel(processRunTab,'Text','Group Name','Tag','RunGroupNameLabel');
runGroupNameDropDown=uidropdown(processRunTab,'Items',{'Test1'},'Editable','off','Tag','RunGroupNameDropDown');
runFunctionNamesLabel=uilabel(processRunTab,'Text','Function Names','Tag','RunFunctionNamesLabel');
groupRunCheckboxLabel=uilabel(processRunTab,'Text','Run','Tag','GroupRunCheckboxLabel');
groupArgsCheckboxLabel=uilabel(processRunTab,'Text','Args','Tag','GroupArgsCheckboxLabel');
runGroupButton=uibutton(processRunTab,'push','Text','Run Group','Tag','RunGroupButton');
runAllButton=uibutton(processRunTab,'push','Text','Run All','Tag','RunAllButton');
runFunctionsPanel=uipanel(processRunTab,'Title','','Tag','RunFunctionsPanel','BackGroundColor',[0.92 0.92 0.92]);
% NEED TO: PROGRAMMATICALLY GENERATE FUNCTION NAMES BUTTONS THAT OPEN THE CORRESPONDING FUNCTION FILE (FROM TEXT FILE?)

% NEED TO: PROGRAMMATICALLY GENERATE ARGS BUTTONS THAT OPEN THE CORRESPONDING ARGS FILE (FROM TEXT FILE?)

% NEED TO: PROGRAMMATICALLY GENERATE RUN CHECKBOXES THAT DICTATE WHETHER A FUNCTION WILL BE RUN OR NOT.

% NEED TO: PROGRAMMATICALLY GENERATE ARGS CHECKBOXES THAT INDICATE WHETHER THE GROUP-LEVEL OR FUNCTION-LEVEL ARGS WILL BE USED.


processTab.UserData=struct('SetupGroupNameLabel',setupGroupNameLabel,'SetupGroupNameDropDown',setupGroupNameDropDown,'SetupFunctionNamesLabel',setupFunctionNamesLabel,'SetupFunctionNamesField',setupFunctionNamesField,...
    'NewFunctionPanel',newFunctionPanel,'SaveGroupButton',saveGroupButton,'InputsLabel',inputsLabel,'OutputsLabel',outputsLabel,'InputCheckboxProject',inputCheckboxP,'InputCheckboxSubject',inputCheckboxS,'InputCheckboxTrial',inputCheckboxT,...
    'OutputCheckboxProject',outputCheckboxP,'OutputCheckboxSubject',outputCheckboxS,'OutputCheckboxTrial',outputCheckboxT,'NewFunctionButton',newFunctionButton,'AddFunctionGroupButton',addFunctionGroupButton,...
    'RunGroupNameLabel',runGroupNameLabel,'RunGroupNameDropDown',runGroupNameDropDown,'RunFunctionNamesLabel',runFunctionNamesLabel,'GroupRunCheckboxLabel',groupRunCheckboxLabel,'GroupArgsCheckboxLabel',groupArgsCheckboxLabel,...
    'RunGroupButton',runGroupButton,'RunAllButton',runAllButton,'RunFunctionsPanel',runFunctionsPanel);

% Resize all objects in each subtab.
hProcessRun=findobj(fig,'Tag','Run');
processTabGroup.SelectedTab=hProcessRun;
@processResize;
hProcessSetup=findobj(fig,'Tag','Setup');
processTabGroup.SelectedTab=hProcessSetup;
@processResize;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
rootSavePlotPathField=uieditfield(plotTab,'text','Value','Root Folder to Save Plots','Tag','RootSavePlotPathField');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AFTER COMPONENT INITIALIZATION
%% IMPORT: Initialize the project name from file.
[A,allProjectsTxtPath]=readAllProjects(getappdata(fig,'everythingPath')); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
setappdata(fig,'allProjectsTxtPath',allProjectsTxtPath); % Store the address of the 'allProjects_ProjectNamesPaths.txt' file
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
    switchProjectsDropDown.Items=allProjectsList;       
    switchProjectsDropDown.Value=mostRecentProjectName;    
else
    setappdata(fig,'projectName',''); % If no projects present in file or file doesn't exist yet, make projectName empty.
    [y, Fs]=audioread([getappdata(fig,'everythingPath') slash 'App Creation & Component Management' slash 'Fun Audio File' slash 'Lets get ready to rumble  Sound Effect.mp3']);
    sound(y,Fs);
end

% Whether the project name was found in the file or not, run the callback to set up the app properly.
switchProjectsDropDownValueChanged(fig); % Run the projectNameFieldValueChanged callback function to recall all of the project-specific metadata from the associated files.

assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected