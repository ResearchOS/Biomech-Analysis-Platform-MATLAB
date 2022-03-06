function []=pgui()

%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED AT THE COMMAND LINE TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
% THIS FUNCTION CREATES ALL COMPONENTS, AND CONTAINS THE CALLBACKS FOR ALL COMPONENTS IN THE GUI.

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR AND LOVING MEMORY OF MY FATHER DOUGLAS ERIC TILLMAN, 10/29/1961-07/05/2021

% Assumes that the app is being run from within the 'Everything App' folder and that the rest of the files & folders within it are untouched.
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
rmpath(genpath([getappdata(fig,'everythingPath') slash 'm File Library'])); % Ensure that the function library files are not on the path, because I don't want to run those files, I want to copy them to my local project.
setappdata(fig,'projectName',''); % projectName always begins empty.
setappdata(fig,'logsheetPath',''); % logsheetPath always begins empty.
setappdata(fig,'dataPath',''); % dataPath always begins empty.
setappdata(fig,'codePath',''); % codePath always begins empty.
setappdata(fig,'rootSavePlotPath',''); % rootSavePlotPath always begins empty.
setappdata(fig,'functionNames',''); % functionNames always begins empty.
setappdata(fig,'fcnNamesFilePath',''); % Function names file path always begins empty
setappdata(fig,'processRunArrowCount',0); % The Process > Run tab arrow count always begins at 0.
setappdata(fig,'dataPanelArrowCount',0); % The Import tab data select panel arrow count always begins at 0.
setappdata(fig,'subjectNames',''); % subjectNames always begins empty.
setappdata(fig,'subjectCodenameColumnNum',0); % The column number in the logsheet for the subject codenames
setappdata(fig,'numHeaderRows',0); % The number of header rows in the logsheet
setappdata(fig,'trialNameColumnNum',0); % The column number in the logsheet for the trial names to be stored in the struct.

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
handles.Import.projectNameLabel=uilabel(importTab,'Text','Project Name','Tag','ProjectNameLabel','FontWeight','bold');
handles.Import.logsheetPathButton=uibutton(importTab,'push','Tooltip','Select Logsheet Path','Text','Logsheet Path','Tag','LogsheetPathButton','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));
handles.Import.dataPathButton=uibutton(importTab,'push','Tooltip','Select Data Path','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',@(dataPathButton,event) dataPathButtonPushed(dataPathButton));
handles.Import.codePathButton=uibutton(importTab,'push','Tooltip','Select Code Path','Text','Code Path','Tag','CodePathButton','ButtonPushedFcn',@(codePathButton,event) codePathButtonPushed(codePathButton));
% projectNameField=uieditfield(importTab,'text','Value','Enter Project Name','Tag','ProjectNameField','ValueChangedFcn',@(projectNameField,event) projectNameFieldValueChanged(projectNameField)); % Project name edit field
handles.Import.logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','Tag','LogsheetPathField','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));
handles.Import.dataPathField=uieditfield(importTab,'text','Value','Data Path (contains ''Subject Data'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)
handles.Import.codePathField=uieditfield(importTab,'text','Value','Path to Project Processing Code Folder','Tag','CodePathField','ValueChangedFcn',@(codePathField,event) codePathFieldValueChanged(codePathField)); % Code path name edit field (to the folder containing all code for this project).
% Button to open the project's importSettings file.
handles.Import.openImportMetadataButton=uibutton(importTab,'push','Text','Create importMetadata','Tooltip','Create or open data type-specific import arguments','Tag','OpenImportMetadataButton','ButtonPushedFcn',@(openImportMetadataButton,event) openImportMetadataButtonPushed(openImportMetadataButton));
% Button to open the project's specifyTrials to select which trials to load/import
handles.Import.openGroupSpecifyTrialsButton=uibutton(importTab,'push','Tooltip','Open Import Specify Trials','Text','Create specifyTrials.m','Tag','OpenSpecifyTrialsButton','ButtonPushedFcn',@(openSpecifyTrialsButton,event) openSpecifyTrialsButtonPushed(openSpecifyTrialsButton));
% Checkbox to redo import (overwrites all existing data files)
handles.Import.redoImportCheckbox=uicheckbox(importTab,'Tooltip','Check to Re-import Existing Data','Text','Redo (Overwrite) Import','Value',0,'Tag','RedoImportCheckbox','ValueChangedFcn',@(redoImportCheckbox,event) redoImportCheckboxValueChanged(redoImportCheckbox));
% Button to run the import/load procedure
handles.Import.runImportButton=uibutton(importTab,'push','Tooltip','Run Import','Text','Run Import/Load','Tag','RunImportButton','ButtonPushedFcn',@(runImportButton,event) runImportButtonPushed(runImportButton));
% Drop down to switch between active projects.
handles.Import.switchProjectsDropDown=uidropdown(importTab,'Items',{'New Project'},'Tooltip','Select Project','Editable','off','Tag','SwitchProjectsDropDown','ValueChangedFcn',@(switchProjectsDropDown,event) switchProjectsDropDownValueChanged(switchProjectsDropDown));
% Drop down to specify & open a new data type's importSettings
handles.Import.dataTypeImportSettingsDropDown=uidropdown(importTab,'Items',{'No Data Types to Import'},'Editable','off','Tag','DataTypeImportSettingsDropDown','ValueChangedFcn',@(dataTypeImportSettingsDropDown,event) dataTypeImportSettingsDropDownValueChanged(dataTypeImportSettingsDropDown));
% Logsheet label
handles.Import.logsheetLabel=uilabel(importTab,'Text','Logsheet:','FontWeight','bold');
% Number of header rows label
handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# of Header Rows','Tag','NumHeaderRowsLabel','Tooltip','Number of Header Rows in Logsheet');
% Number of header rows text box
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Tooltip','Number of Header Rows in Logsheet','Value',0,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));
% Subject ID column header label
handles.Import.subjIDColHeaderLabel=uilabel(importTab,'Text','Subject ID Column Header','Tag','SubjectIDColumnHeaderLabel','Tooltip','Logsheet Column Header for Subject Codenames');
% Subject ID column header text box
handles.Import.subjIDColHeaderField=uieditfield(importTab,'text','Value','Subject ID Column Header','Tooltip','Logsheet Column Header for Subject Codenames','Tag','SubjIDColumnHeaderField','ValueChangedFcn',@(subjIDColHeaderField,event) subjIDColHeaderFieldValueChanged(subjIDColHeaderField));
% Trial ID column header label
handles.Import.trialIDColHeaderDataTypeLabel=uilabel(importTab,'Text','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names');
% Trial ID column header text box
handles.Import.trialIDColHeaderDataTypeField=uieditfield(importTab,'text','Value','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','DataTypeTrialIDColumnHeaderField','ValueChangedFcn',@(trialIDColHeaderField,event) trialIDColHeaderDataTypeFieldValueChanged(trialIDColHeaderField));
% Target Trial ID format label
handles.Import.targetTrialIDColHeaderLabel=uilabel(importTab,'Text','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderLabel','Tooltip','Logsheet Column Header for projectStruct Trial Names');
% Target Trial ID format field
handles.Import.targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','T','Tag','TargetTrialIDColHeaderField','Tooltip','Logsheet Column Header for projectStruct Trial Names','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));
% Save all trials button
% handles.Import.saveAllButton=uibutton(importTab,'push','Text','Save All In Struct','Tag','SaveAllButton','ButtonPushedFcn',@(saveAllButton,event) saveAllButtonPushed(saveAllButton));
% Load which data label
handles.Import.selectDataPanel=uipanel(importTab,'Title','Select Groups'' Data to Load','Tag','SelectDataPanel','BackGroundColor',[0.9 0.9 0.9],'BorderType','line','FontWeight','bold','TitlePosition','centertop','AutoResizeChildren','off','SizeChangedFcn',@dataSelectPanelResize);
% Need to read the groups text file to get group names. Create
% corresponding number of checkboxes & their labels.
handles.Import.loadLabel=uilabel(importTab,'Text','Load','Tag','LoadLabel','Tooltip','Check Boxes to Load Data');
handles.Import.offloadLabel=uilabel(importTab,'Text','Offload','Tag','OffloadLabel','Tooltip','Check Boxes to Offload Data');
handles.Import.dataLabel=uilabel(importTab,'Text','Data','Tag','DataLabel');

% Data types import method number field
handles.Import.dataTypeImportMethodField=uieditfield(importTab,'text','Value','1A','Tag','DataTypeImportMethodField','Tooltip','Data type-specific import method ID','ValueChangedFcn',@(dataTypeImportMethodField,event) dataTypeImportMethodFieldValueChanged(dataTypeImportMethodField));
% Add new data type to drop down
handles.Import.addDataTypeButton=uibutton(importTab,'push','Text','New Data Type','Tag','AddDataTypeButton','Tooltip','Add new data type for import','ButtonPushedFcn',@(addDataTypeButton,event) addDataTypeButtonPushed(addDataTypeButton));
% Create new import function
handles.Import.openImportFcnButton=uibutton(importTab,'push','Text','Create Import Fcn','Tag','OpenImportFcnButton','Tooltip','Create or open data type-specific import function','ButtonPushedFcn',@(openImportFcnButton,event) openImportFcnButtonPushed(openImportFcnButton));
% Add new project button
handles.Import.addProjectButton=uibutton(importTab,'push','Text','+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));
% Open logsheet button
handles.Import.openLogsheetButton=uibutton(importTab,'push','Text','O','Tag','OpenLogsheetButton','Tooltip','Open logsheet','ButtonPushedFcn',@(openLogsheetButton,event) openLogsheetButtonPushed(openLogsheetButton));
% Open data path button
handles.Import.openDataPathButton=uibutton(importTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));
% Open code path button
handles.Import.openCodePathButton=uibutton(importTab,'push','Text','O','Tag','OpenCodePathButton','Tooltip','Open code folder','ButtonPushedFcn',@(openCodePathButton,event) openCodePathButtonPushed(openCodePathButton));
% Data panel up arrow button
handles.Import.dataPanelUpArrowButton=uibutton(importTab,'push','Text',{'/\';'||'},'Tag','DataPanelUpArrowButton','ButtonPushedFcn',@(dataPanelUpArrowButton,event) dataPanelUpArrowButtonPushed(dataPanelUpArrowButton));
% Data panel down arrow button
handles.Import.dataPanelDownArrowButton=uibutton(importTab,'push','Text',{'||';'\/'},'Tag','DataPanelDownArrowButton','ButtonPushedFcn',@(dataPanelDownArrowButton,event) dataPanelDownArrowButtonPushed(dataPanelDownArrowButton));
% Specify trials number field
handles.Import.specifyTrialsNumberField=uieditfield(importTab,'text','Value','1','Tag','SpecifyTrialsNumberField','Tooltip','Specify trials method number','ValueChangedFcn',@(specifyTrialsNumberField,event) specifyTrialsNumberFieldValueChanged(specifyTrialsNumberField));

importTab.UserData=struct('ProjectNameLabel',handles.Import.projectNameLabel,'LogsheetPathButton',handles.Import.logsheetPathButton,'DataPathButton',handles.Import.dataPathButton,'CodePathButton',handles.Import.codePathButton,...
    'AddProjectButton',handles.Import.addProjectButton,'LogsheetPathField',handles.Import.logsheetPathField,'DataPathField',handles.Import.dataPathField,'CodePathField',handles.Import.codePathField,'DataTypeImportSettingsDropDown',handles.Import.dataTypeImportSettingsDropDown,...
    'OpenImportMetadataButton',handles.Import.openImportMetadataButton,'OpenSpecifyTrialsButton',handles.Import.openGroupSpecifyTrialsButton,'SwitchProjectsDropDown',handles.Import.switchProjectsDropDown,'RedoImportCheckBox',handles.Import.redoImportCheckbox,...
    'RunImportButton',handles.Import.runImportButton,'LogsheetLabel',handles.Import.logsheetLabel,'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,...
    'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,...
    'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,...
    'SelectDataPanel',handles.Import.selectDataPanel,'DataTypeImportMethodField',handles.Import.dataTypeImportMethodField,'AddDataTypeButton',handles.Import.addDataTypeButton,'OpenImportFcnButton',handles.Import.openImportFcnButton,...
    'OpenLogsheetButton',handles.Import.openLogsheetButton,'OpenDataPathButton',handles.Import.openDataPathButton','OpenCodePathButton',handles.Import.openCodePathButton,...
    'LoadLabel',handles.Import.loadLabel,'OffloadLabel',handles.Import.offloadLabel,'DataLabel',handles.Import.dataLabel,'DataPanelUpArrowButton',handles.Import.dataPanelUpArrowButton,'DataPanelDownArrowButton',handles.Import.dataPanelDownArrowButton,'SpecifyTrialsNumberField',handles.Import.specifyTrialsNumberField);

@importResize; % Run the importResize to set all components' positions to their correct positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
processTabGroup=uitabgroup(processTab,'Tag','ProcessTabGroup','AutoResizeChildren','off');
processSetupTab=uitab(processTabGroup,'Title','Setup','Tag','Setup','AutoResizeChildren','off'); % Create the process > setup tab
processRunTab=uitab(processTabGroup,'Title','Run','Tag','Run','AutoResizeChildren','off'); % Create the process > run tab

% Create the Process > Setup tab
% Function Group Name Label
handles.ProcessSetup.setupGroupNameLabel=uilabel(processSetupTab,'Text','Group Name','Tag','SetupGroupNameLabel');
handles.ProcessSetup.setupGroupNameDropDown=uidropdown(processSetupTab,'Items',{'Create Function Group'},'Editable','Off','Tooltip','Select processing function group','Tag','SetupGroupNameDropDown','ValueChangedFcn',@(setupGroupNameDropDown,event) setupGroupNamesDropDownValueChanged(setupGroupNameDropDown));
handles.ProcessSetup.setupFunctionNamesLabel=uilabel(processSetupTab,'Text','Function Names','Tag','SetupFunctionNamesLabel');
handles.ProcessSetup.setupFunctionNamesField=uitextarea(processSetupTab,'Value','Function Names','Tag','SetupFunctionNamesField','Editable','on','Visible','on','ValueChangedFcn',@(setupFunctionNamesField,event) setupFunctionNamesFieldValueChanged(setupFunctionNamesField));
handles.ProcessSetup.newFunctionPanel=uipanel(processSetupTab,'Title','New Function','Tag','NewFunctionPanel','BackGroundColor',[0.9 0.9 0.9],'BorderType','line','FontWeight','bold','TitlePosition','centertop');
handles.ProcessSetup.saveGroupButton=uibutton(processSetupTab,'push','Text','Save Group To File','Tag','SaveGroupButton','ButtonPushedFcn',@(saveGroupButton,event) saveGroupButtonPushed(saveGroupButton));
handles.ProcessSetup.inputsLabel=uilabel(processSetupTab,'Text','Function Levels','Tag','InputsLabel');
% outputsLabel=uilabel(processSetupTab,'Text','Output Levels','Tag','OutputsLabel');
handles.ProcessSetup.inputCheckboxP=uicheckbox(processSetupTab,'Text','Project','Value',0,'Tag','InputCheckboxProject','Tooltip','New function contains project-level variables');
handles.ProcessSetup.inputCheckboxS=uicheckbox(processSetupTab,'Text','Subject','Value',0,'Tag','InputCheckboxSubject','Tooltip','New function contains subject-level variables');
handles.ProcessSetup.inputCheckboxT=uicheckbox(processSetupTab,'Text','Trial','Value',0,'Tag','InputCheckboxTrial','Tooltip','New function contains trial-level variables');
% outputCheckboxP=uicheckbox(processSetupTab,'Text','Project','Value',0,'Tag','OutputCheckboxProject');
% outputCheckboxS=uicheckbox(processSetupTab,'Text','Subject','Value',0,'Tag','OutputCheckboxSubject');
% outputCheckboxT=uicheckbox(processSetupTab,'Text','Trial','Value',0,'Tag','OutputCheckboxTrial');
handles.ProcessSetup.newFunctionButton=uibutton(processSetupTab,'push','Text','Create New Function','Tag','NewFunctionButton','ButtonPushedFcn',@(newFunctionButton,event) newFunctionButtonPushed(newFunctionButton));
handles.ProcessSetup.addFunctionGroupButton=uibutton(processSetupTab,'push','Text','+','Tag','AddFunctionGroupButton','Tooltip','Create new processing function group','ButtonPushedFcn',@(addFunctionGroupButton,event) addFunctionGroupButtonPushed(addFunctionGroupButton));

% Create the Process > Run tab
handles.ProcessRun.runGroupNameLabel=uilabel(processRunTab,'Text','Group Name','Tag','RunGroupNameLabel');
handles.ProcessRun.runGroupNameDropDown=uidropdown(processRunTab,'Items',{'Create Function Group'},'Editable','off','Tag','RunGroupNameDropDown','ValueChangedFcn',@(runGroupNameDropDown,event) runGroupNameDropDownValueChanged(runGroupNameDropDown));
handles.ProcessRun.runFunctionNamesLabel=uilabel(processRunTab,'Text','Function Names','Tag','RunFunctionNamesLabel');
handles.ProcessRun.groupRunCheckboxLabel=uilabel(processRunTab,'Text','Run','Tag','GroupRunCheckboxLabel');
handles.ProcessRun.groupArgsCheckboxLabel=uilabel(processRunTab,'Text','Args','Tag','GroupArgsCheckboxLabel');
handles.ProcessRun.runGroupButton=uibutton(processRunTab,'push','Text','Run Group','Tag','RunGroupButton','Tooltip','Run the currently selected processing group functions','ButtonPushedFcn',@(runGroupButton,event) runGroupButtonPushed(runGroupButton));
handles.ProcessRun.runAllButton=uibutton(processRunTab,'push','Text','Run All','Tag','RunAllButton','Tooltip','Run all processing function groups','ButtonPushedFcn',@(runAllButton,event) runAllButtonPushed(runAllButton));
handles.ProcessRun.runFunctionsPanel=uipanel(processRunTab,'Title','','Tag','RunFunctionsPanel','BackGroundColor',[0.92 0.92 0.92],'AutoResizeChildren','off','SizeChangedFcn',@processRunPanelResize);
handles.ProcessRun.specifyTrialsGroupButton=uibutton(processRunTab,'push','Text','Specify Trials','Tag','SpecifyTrialsGroupButton','Tooltip','Open group-level specify trials','ButtonPushedFcn',@(specifyTrialsGroupButton,event) specifyTrialsGroupButtonPushed(specifyTrialsGroupButton));
handles.ProcessRun.specifyTrialsCheckboxLabel=uilabel(processRunTab,'Text','Specify Trials','Tag','SpecifyTrialsCheckboxLabel');
% specifyTrialsGroupCheckbox=uicheckbox(processRunTab,'Text','','Value',0,'Tag','SpecifyTrialsGroupCheckbox');
handles.ProcessRun.processRunUpArrowButton=uibutton(processRunTab,'Text',{'/\';'||'},'Tag','ProcessRunUpArrowButton','ButtonPushedFcn',@(processRunUpArrowButton,event) processRunUpArrowButtonPushed(processRunUpArrowButton));
handles.ProcessRun.processRunDownArrowButton=uibutton(processRunTab,'Text',{'||';'\/'},'Tag','ProcessRunDownArrowButton','ButtonPushedFcn',@(processRunDownArrowButton,event) processRunDownArrowButtonPushed(processRunDownArrowButton));
handles.ProcessRun.runGroupArgsButton=uibutton(processRunTab,'Text','Args','Tag','RunGroupArgsButton','Tooltip','Open group-level arguments','ButtonPushedFcn',@(runGroupArgsButton,event) runGroupArgsButtonPushed(runGroupArgsButton));

processTab.UserData=struct('SetupGroupNameLabel',handles.ProcessSetup.setupGroupNameLabel,'SetupGroupNameDropDown',handles.ProcessSetup.setupGroupNameDropDown,'SetupFunctionNamesLabel',handles.ProcessSetup.setupFunctionNamesLabel,'SetupFunctionNamesField',handles.ProcessSetup.setupFunctionNamesField,...
    'NewFunctionPanel',handles.ProcessSetup.newFunctionPanel,'SaveGroupButton',handles.ProcessSetup.saveGroupButton,'InputsLabel',handles.ProcessSetup.inputsLabel,'InputCheckboxProject',handles.ProcessSetup.inputCheckboxP,'InputCheckboxSubject',handles.ProcessSetup.inputCheckboxS,'InputCheckboxTrial',handles.ProcessSetup.inputCheckboxT,...
    'NewFunctionButton',handles.ProcessSetup.newFunctionButton,'AddFunctionGroupButton',handles.ProcessSetup.addFunctionGroupButton,'RunGroupNameLabel',handles.ProcessRun.runGroupNameLabel,'RunGroupNameDropDown',handles.ProcessRun.runGroupNameDropDown,'RunFunctionNamesLabel',handles.ProcessRun.runFunctionNamesLabel,...
    'GroupRunCheckboxLabel',handles.ProcessRun.groupRunCheckboxLabel,'GroupArgsCheckboxLabel',handles.ProcessRun.groupArgsCheckboxLabel,'RunGroupButton',handles.ProcessRun.runGroupButton,'RunAllButton',handles.ProcessRun.runAllButton,'RunFunctionsPanel',handles.ProcessRun.runFunctionsPanel,...
    'SpecifyTrialsGroupButton',handles.ProcessRun.specifyTrialsGroupButton,'SpecifyTrialsCheckboxLabel',handles.ProcessRun.specifyTrialsCheckboxLabel,'ProcessRunUpArrowButton',handles.ProcessRun.processRunUpArrowButton,'ProcessRunDownArrowButton',handles.ProcessRun.processRunDownArrowButton,...
    'RunGroupArgsButton',handles.ProcessRun.runGroupArgsButton);
%     'OutputsLabel',outputsLabel,'OutputCheckboxProject',outputCheckboxP,'OutputCheckboxSubject',outputCheckboxS,'OutputCheckboxTrial',outputCheckboxT,...

% Resize all objects in each subtab.
hProcessRun=findobj(fig,'Tag','Run');
processTabGroup.SelectedTab=hProcessRun;
@processResize;
hProcessSetup=findobj(fig,'Tag','Setup');
processTabGroup.SelectedTab=hProcessSetup;
@processResize;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
handles.Plot.rootSavePlotPathField=uieditfield(plotTab,'text','Value','Root Folder to Save Plots','Tag','RootSavePlotPathField');

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
    handles.Import.switchProjectsDropDown.Items=allProjectsList;       
    handles.Import.switchProjectsDropDown.Value=mostRecentProjectName;    
else
    setappdata(fig,'projectName',''); % If no projects present in file or file doesn't exist yet, make projectName empty.
    [y, Fs]=audioread([getappdata(fig,'everythingPath') slash 'App Creation & Component Management' slash 'Fun Audio File' slash 'Lets get ready to rumble  Sound Effect.mp3']);
    sound(y,Fs);
end

% Whether the project name was found in the file or not, run the callback to set up the app properly.
setappdata(fig,'handles',handles);
switchProjectsDropDownValueChanged(fig); % Run the projectNameFieldValueChanged callback function to recall all of the project-specific metadata from the associated files.

assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected