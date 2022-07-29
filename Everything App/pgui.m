function []=pgui()

tic;
%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED IN THE COMMAND WINDOW TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
% THIS FUNCTION CREATES ALL COMPONENTS, AND CONTAINS THE CALLBACKS FOR ALL COMPONENTS IN THE GUI.

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR AND LOVING MEMORY OF MY FATHER DOUGLAS ERIC TILLMAN, 10/29/1961-07/05/2021

version='3.0'; % Current version of the pgui package.

% Assumes that the app is being run from within the 'Everything App' folder and that the rest of the files & folders within it are untouched.
pguiPath=mfilename('fullpath'); % The path where the pgui function is stored.
addpath(genpath(fileparts(pguiPath))); % Add all subfolders to the path so that app creation & management is unencumbered.

% Check if Mac or PC
if ispc==1
    slash='\';
elseif ismac==1
    slash='/';
end

%% Create figure
fig=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@appResize); % Create the figure window for the app
fig.Name='pgui'; % Name the window
defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',[defaultPos(1:2) defaultPos(3)*2 defaultPos(4)]); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)
setappdata(fig,'version',version);

%% Initialize app data
setappdata(fig,'everythingPath',[fileparts(mfilename('fullpath')) slash]); % Path to the 'Everything App' folder.
warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
rmpath(genpath([getappdata(fig,'everythingPath') slash 'm File Library'])); % Ensure that the function library files are not on the path, because I don't want to run those files, I want to copy them to my local project.
warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
setappdata(fig,'projectName',''); % The current project name in the dropdown on the Import tab.
setappdata(fig,'settingsMATPath',''); % The project-independent settings MAT file full path.
setappdata(fig,'projectSettingsMATPath',''); % The project-specific settings MAT file full path.
setappdata(fig,'codePath',''); % The current project's code path on the Import tab.
setappdata(fig,'logsheetPath',''); % The current project's logsheet path on the Import tab.
setappdata(fig,'dataPath',''); % The current project's data path on the Import tab.
setappdata(fig,'NonFcnSettingsStruct',''); % The non-function related settings for the current project
setappdata(fig,'FcnSettingsStruct',''); % The function related settings for the current project
setappdata(fig,'allowAllTabs',0); % Initialize that only the Projects tab can be selected.
setappdata(fig,'rootSavePlotPath',''); % The root folder to save plots to.

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off','SelectionChangedFcn',@(tabGroup1,event) tabGroup1SelectionChanged(tabGroup1),'Tag','TabGroup'); % Create the tab group for the four stages of data processing
% tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off','Tag','TabGroup'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
projectsTab=uitab(tabGroup1,'Title','Projects','Tag','Projects','AutoResizeChildren','off','SizeChangedFcn',@projectsResize); % Create the projects tab
importTab=uitab(tabGroup1,'Title','Import','Tag','Import','AutoResizeChildren','off','SizeChangedFcn',@importResize); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','Tag','Process','AutoResizeChildren','off','SizeChangedFcn',@processResize); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','Tag','Plot','AutoResizeChildren','off','SizeChangedFcn',@plotResize); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats','Tag','Stats','AutoResizeChildren','off'); % Create the stats tab
settingsTab=uitab(tabGroup1,'Title','Settings','Tag','Settings','AutoResizeChildren','off'); % Create the settings tab
handles.Tabs.tabGroup1=tabGroup1;

% Store handles to individual tabs.
handles.Projects.Tab=projectsTab;
handles.Import.Tab=importTab;
handles.Process.Tab=processTab;
handles.Plot.Tab=plotTab;
handles.Stats.Tab=statsTab;
handles.Settings.Tab=settingsTab;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the projects tab.
% 1. The project name label
handles.Projects.projectNameLabel=uilabel(projectsTab,'Text','Project Name','Tag','ProjectNameLabel','FontWeight','bold');

% 2. Drop down to switch between active projects.
handles.Projects.switchProjectsDropDown=uidropdown(projectsTab,'Items',{'New Project'},'Tooltip','Select Project','Editable','off','Tag','SwitchProjectsDropDown','ValueChangedFcn',@(switchProjectsDropDown,event) switchProjectsDropDownValueChanged(switchProjectsDropDown));

% 3. Add new project button
handles.Projects.addProjectButton=uibutton(projectsTab,'push','Text','P+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));

% 3. The button to open the data path file picker
handles.Projects.dataPathButton=uibutton(projectsTab,'push','Tooltip','Select Data Path','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',@(dataPathButton,event) dataPathButtonPushed(dataPathButton));

% 4. The button to open the code path file picker
handles.Projects.codePathButton=uibutton(projectsTab,'push','Tooltip','Select Code Path','Text','Code Path','Tag','CodePathButton','ButtonPushedFcn',@(codePathButton,event) codePathButtonPushed(codePathButton));

% 6. The text edit field for the data path
handles.Projects.dataPathField=uieditfield(projectsTab,'text','Value','Data Path (contains ''Subject Data'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 7. The text edit field for the code path
handles.Projects.codePathField=uieditfield(projectsTab,'text','Value','Path to Project Processing Code Folder','Tag','CodePathField','ValueChangedFcn',@(codePathField,event) codePathFieldValueChanged(codePathField)); % Code path name edit field (to the folder containing all code for this project).

% 8. Archive project button
handles.Projects.archiveProjectButton=uibutton(projectsTab,'push','Text','P-','Tag','ArchiveProjectButton','Tooltip','Archive current project','ButtonPushedFcn',@(archiveProjectButton,event) archiveProjectButtonPushed(archiveProjectButton));

% 9. Open data path button
handles.Projects.openDataPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));

% 10. Open code path button
handles.Projects.openCodePathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenCodePathButton','Tooltip','Open code folder','ButtonPushedFcn',@(openCodePathButton,event) openCodePathButtonPushed(openCodePathButton));

% 11. Show project-independent settings file
handles.Projects.openPISettingsPathButton=uibutton(projectsTab,'push','Text','Open P-I Settings','Tag','OpenPISettingsPathButton','Tooltip','Open project-independent settings folder','ButtonPushedFcn',@(openPISettingsPathButton,event) openPISettingsPathButtonPushed(openPISettingsPathButton));

projectsTab.UserData=struct('ProjectNameLabel',handles.Projects.projectNameLabel,'DataPathButton',handles.Projects.dataPathButton,'CodePathButton',handles.Projects.codePathButton,...
    'AddProjectButton',handles.Projects.addProjectButton,'SwitchProjectsDropDown',handles.Projects.switchProjectsDropDown,'OpenDataPathButton',handles.Projects.openDataPathButton','OpenCodePathButton',handles.Projects.openCodePathButton,...
    'ArchiveProjectButton',handles.Projects.archiveProjectButton,'DataPathField',handles.Projects.dataPathField,'CodePathField',handles.Projects.codePathField,'OpenPISettingsPathButton',handles.Projects.openPISettingsPathButton);

@projectsResize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
% 1. The button to open the logsheet path file picker
handles.Import.logsheetPathButton=uibutton(importTab,'push','Tooltip','Select Logsheet Path','Text','Path','Tag','LogsheetPathButton','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));

% 2. The text edit field for the logsheet path
handles.Import.logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','Tag','LogsheetPathField','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));

% 3. Logsheet label
handles.Import.logsheetLabel=uilabel(importTab,'Text','Logsheet:','FontWeight','bold','Tag','LogsheetLabel');

% 4. Number of header rows label
handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# of Header Rows','Tag','NumHeaderRowsLabel','Tooltip','Number of Header Rows in Logsheet');

% 5. Number of header rows text box
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Tooltip','Number of Header Rows in Logsheet','Value',-1,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));

% 6. Subject ID column header label
handles.Import.subjIDColHeaderLabel=uilabel(importTab,'Text','Subject ID Column Header','Tag','SubjectIDColumnHeaderLabel','Tooltip','Logsheet Column Header for Subject Codenames');

% 7. Subject ID column header text box
handles.Import.subjIDColHeaderField=uieditfield(importTab,'text','Value','Subject ID Column Header','Tooltip','Logsheet Column Header for Subject Codenames','Tag','SubjIDColumnHeaderField','ValueChangedFcn',@(subjIDColHeaderField,event) subjIDColHeaderFieldValueChanged(subjIDColHeaderField));

% 8. Trial ID column header label
handles.Import.trialIDColHeaderDataTypeLabel=uilabel(importTab,'Text','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','TrialIDColHeaderDataTypeLabel');

% 9. Trial ID column header text box
handles.Import.trialIDColHeaderDataTypeField=uieditfield(importTab,'text','Value','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','DataTypeTrialIDColumnHeaderField','ValueChangedFcn',@(trialIDColHeaderField,event) trialIDColHeaderDataTypeFieldValueChanged(trialIDColHeaderField));

% 10. Target Trial ID column header label
handles.Import.targetTrialIDColHeaderLabel=uilabel(importTab,'Text','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderLabel','Tooltip','Logsheet Column Header for projectStruct Trial Names');

% 11. Target Trial ID column header field
handles.Import.targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderField','Tooltip','Logsheet Column Header for projectStruct Trial Names','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));

% 12. Open logsheet button
handles.Import.openLogsheetButton=uibutton(importTab,'push','Text','O','Tag','OpenLogsheetButton','Tooltip','Open logsheet','ButtonPushedFcn',@(openLogsheetButton,event) openLogsheetButtonPushed(openLogsheetButton));

% 13.  Logsheet variables UI tree
handles.Import.logVarsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(logVarsUITree,event) logVarsUITreeSelectionChanged(logVarsUITree),'CheckedNodesChangedFcn',@(logVarsUITree,event) logVarsUITreeCheckedNodesChanged(logVarsUITree),'Tag','LogVarsUITree');

% 14. Data type label
handles.Import.dataTypeLabel=uilabel(importTab,'Text','Data Type','Tag','DataTypeLabel');

% 15. Data type dropdown
handles.Import.dataTypeDropDown=uidropdown(importTab,'Items',{'','char','double'},'Tooltip','Data Type of Logsheet Variable','Editable','off','Tag','DataTypeDropDown','ValueChangedFcn',@(dataTypeDropDown,event) dataTypeDropDownValueChanged(dataTypeDropDown));

% 16. Trial/subject dropdown
handles.Import.trialSubjectDropDown=uidropdown(importTab,'Items',{'','Trial','Subject'},'Tooltip','Variable is Trial or Subject Level','Editable','off','Tag','TrialSubjectDropDown','ValueChangedFcn',@(trialSubjectDropDown,event) trialSubjectDropDownValueChanged(trialSubjectDropDown));

% 17. Variable name in code button
% handles.Import.assignVariableButton=uibutton(importTab,'push','Text','Assign var','Tag','AssignVariableButton','Tooltip','Assign logsheet data to variable','ButtonPushedFcn',@(assignVariableButton,event) assignVariableButtonPushed(assignVariableButton));

% 18. Variable name field
% handles.Import.logVarNameField=uieditfield(importTab,'text','Value','','Tag','LogVarNameField','Editable','off','Tooltip','Name of the Variable for this Logsheet Data','ValueChangedFcn',@(logVarNameField,event) logVarNameFieldValueChanged(logVarNameField));

% 19. Variable names list box
% handles.Import.variableNamesListbox=uilistbox(importTab,'Multiselect','off','Tag','VariableNamesListbox','Items',{'No Vars'});

% 20. Variable search field
handles.Import.varSearchField=uieditfield(importTab,'text','Value','Search','Tag','VarSearchField','ValueChangedFcn',@(varSearchField,event) varSearchFieldValueChanged(varSearchField));

% 21. Import data from the logsheet button
handles.Import.runLogImportButton=uibutton(importTab,'push','Text','Run Logsheet Import','Tag','RunLogImportButton','Tooltip','Import logsheet data','ButtonPushedFcn',@(runLogImportButton,event) runLogImportButtonPushed(runLogImportButton));

% 22. Create argument button
% handles.Import.createArgButton=uibutton(importTab,'push','Text','Create Arg','Tag','CreateArgButton','Tooltip','Create new variable','ButtonPushedFcn',@(createArgButton,event) createArgButtonPushed(createArgButton));

% 23. Specify trials UI tree
handles.Import.specifyTrialsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeSelectionChanged(specifyTrialsUITree),'CheckedNodesChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeCheckedNodesChanged(specifyTrialsUITree),'Tag','SpecifyTrialsUITree');

% 24. New specify trials button
handles.Import.newSpecifyTrialsButton=uibutton(importTab,'push','Text','ST+','Tag','NewSpecifyTrialsButton','Tooltip','Create new specify trials condition','ButtonPushedFcn',@(newSpecifyTrialsButton,event) newSpecifyTrialsButtonPushed(newSpecifyTrialsButton));

% 25. Remove specify trials option
handles.Import.removeSpecifyTrialsButton=uibutton(importTab,'push','Text','ST-','Tag','RemoveSpecifyTrialsButton','Tooltip','Remove specify trials condition','ButtonPushedFcn',@(removeSpecifyTrialsButton,event) removeSpecifyTrialsButtonPushed(removeSpecifyTrialsButton));

% 26. Import function drop down (for data type-specific column headers)
handles.Import.importFcnDropDown=uidropdown(importTab,'Items',{'New Import Fcn'},'Editable','off','Tag','ImportFcnDropDown','ValueChangedFcn',@(importFcnDropDown,event) importFcnDropDownValueChanged(importFcnDropDown));

% 27. Check all in log headers UI tree button
handles.Import.checkAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Check all','Tag','CheckAllLogVarsUITreeButton','Tooltip','Check all columns','ButtonPushedFcn',@(checkAllLogVarsUITreeButton,event) checkAllLogVarsUITreeButtonPushed(checkAllLogVarsUITreeButton));

% 28. Uncheck all in log headers UI tree button
handles.Import.uncheckAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Uncheck all','Tag','UncheckAllLogVarsUITreeButton','Tooltip','Uncheck all columns','ButtonPushedFcn',@(uncheckAllLogVarsUITreeButton,event) uncheckAllLogVarsUITreeButtonPushed(uncheckAllLogVarsUITreeButton));

% 29. Edit specify trials
handles.Import.editSpecifyTrialsButton=uibutton(importTab,'push','Text','ST Edit','Tag','EditSpecifyTrialsButton','Tooltip','Edit specify trials condition','ButtonPushedFcn',@(editSpecifyTrialsButton,event) editSpecifyTrialsButtonPushed(editSpecifyTrialsButton));

importTab.UserData=struct('LogsheetPathButton',handles.Import.logsheetPathButton,'LogsheetPathField',handles.Import.logsheetPathField,'LogsheetLabel',handles.Import.logsheetLabel,...
    'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,...
    'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,...
    'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,'OpenLogsheetButton',handles.Import.openLogsheetButton,'LogVarsUITree',handles.Import.logVarsUITree,...
    'DataTypeLabel',handles.Import.dataTypeLabel,'DataTypeDropDown',handles.Import.dataTypeDropDown,'TrialSubjectDropDown',handles.Import.trialSubjectDropDown,...
    'VarSearchField',handles.Import.varSearchField,'RunLogImportButton',handles.Import.runLogImportButton,...
    'SpecifyTrialsUITree',handles.Import.specifyTrialsUITree,'NewSpecifyTrialsButton',handles.Import.newSpecifyTrialsButton,...
    'RemoveSpecifyTrialsButton',handles.Import.removeSpecifyTrialsButton,'ImportFcnDropDown',handles.Import.importFcnDropDown,'CheckAllLogVarsUITreeButton',handles.Import.checkAllLogVarsUITreeButton,'UncheckAllLogVarsUITreeButton',handles.Import.uncheckAllLogVarsUITreeButton,...
    'EditSpecifyTrialsButton',handles.Import.editSpecifyTrialsButton);

@importResize; % Run the importResize to set all components' positions to their correct positions

% drawnow; % Show the properly placed import tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
% 1. The figure object for the processing map
handles.Process.mapFigure=uiaxes(processTab,'Tag','MapFigure','HandleVisibility','on','Visible','on');

% 2. Add fcn button (works with #4)
handles.Process.addFcnButton=uibutton(processTab,'push','Text','F+','Tag','AddFcnButton','Tooltip','Add New Function','ButtonPushedFcn',@(addFcnButton,event) addFunctionButtonPushed(addFcnButton));

% 3. Remove fcn button
handles.Process.removeFcnButton=uibutton(processTab,'push','Text','F-','Tag','RemoveFcnButton','Tooltip','Remove Function','ButtonPushedFcn',@(removeFcnButton,event) removeFunctionButtonPushed(removeFcnButton));

% 4. Add fcn type dropdown (same branch before selected, same branch after selected, new branch after selected)
handles.Process.addFcnTypeDropDown=uidropdown(processTab,'Items',{'Same Branch Before Selected','Same Branch After Selected','New Branch Offshoot','Start New Branch'},'Tooltip','Specify Where the New Function Will Be Placed','Editable','off','Tag','AddFcnTypeDropDown','ValueChangedFcn',@(addFcnTypeDropDown,event) addFcnTypeDropDownValueChanged(addFcnTypeDropDown));

% 5. Move fcn button (works with #4)
handles.Process.moveFcnButton=uibutton(processTab,'push','Text','Move Fcn','Tag','MoveFcnButton','Tooltip','Move Function to New Place in Plot','ButtonPushedFcn',@(moveFcnButton,event) moveFunctionButtonPushed(moveFcnButton));

% 6. Propagate changes button
handles.Process.propagateChangesButton=uibutton(processTab,'state','Text','Propagate Changes','Tag','PropagateChangesButton','Tooltip','Propagate Changes to All Affected Variables','ValueChangedFcn',@(propagateChangesButton,event) propagateChangesValueChanged(propagateChangesButton));

% 7. Propagate changes checkbox
handles.Process.propagateChangesCheckbox=uicheckbox(processTab,'Text','','Value',0,'Tag','PropagateChangesCheckbox','Tooltip','If checked, un-propagated changes to args have occurred. If a function code was edited (cannot be auto detected), manually check this box to propagate changes.');

% 8. Run selected fcn's button
handles.Process.runSelectedFcnsButton=uibutton(processTab,'push','Text','Run Selected Fcns','Tag','RunSelectedFcnsButton','Tooltip','Run Selected Fcns','ButtonPushedFcn',@(runSelectedFcnsButton,event) runSelectedFcnsButtonPushed(runSelectedFcnsButton));

% 9. New arg button
handles.Process.createArgButton=uibutton(processTab,'push','Text','Var+','Tag','CreateArgButton','Tooltip','Create New Argument','ButtonPushedFcn',@(createArgButton,event) createArgButtonPushed(createArgButton));

% 11. Remove argument button
handles.Process.removeArgButton=uibutton(processTab,'push','Text','Var-','Tag','RemoveArgButton','Tooltip','Remove Arg From Fcn','ButtonPushedFcn',@(removeArgButton,event) removeArgButtonPushed(removeArgButton));

% 12. Fcn name label
handles.Process.fcnNameLabel=uilabel(processTab,'Text','Fcn Name','Tag','FcnNameLabel','FontWeight','bold');

% 13. Fcn & args UI Tree
handles.Process.fcnArgsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');

% 14. Arg name in code label
handles.Process.argNameInCodeLabel=uilabel(processTab,'Text','Arg Name In Code','Tag','ArgNameInCodeLabel','FontWeight','bold');

% 15. Arg name in code field
handles.Process.argNameInCodeField=uieditfield(processTab,'text','Value','Arg Name In Code','Tag','ArgNameInCodeField','ValueChangedFcn',@(argNameInCodeField,event) argNameInCodeFieldValueChanged(argNameInCodeField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 16. Fcn description label
handles.Process.fcnDescriptionLabel=uilabel(processTab,'Text','Fcn Description','Tag','FcnDescriptionLabel','FontWeight','bold');

% 17. Fcn description text area
handles.Process.fcnDescriptionTextArea=uitextarea(processTab,'Value','Enter Fcn Description Here','Tag','FcnDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(fcnDescriptionTextArea,event) fcnDescriptionTextAreaValueChanged(fcnDescriptionTextArea));

% 18. Arg description label
handles.Process.argDescriptionLabel=uilabel(processTab,'Text','Arg Description','Tag','ArgDescriptionLabel','FontWeight','bold');

% 19. Arg description text area
handles.Process.argDescriptionTextArea=uitextarea(processTab,'Value','Enter Arg Description Here','Tag','ArgDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argDescriptionTextArea,event) argDescriptionTextAreaValueChanged(argDescriptionTextArea));

% 20. Show input vars button
handles.Process.showInputVarsButton=uibutton(processTab,'push','Text','Show I','Tag','ShowInputVarsButton','Tooltip','Show Input Vars to Current Function','ButtonPushedFcn',@(showInputVarsButton,event) showInputVarsButtonPushed(showInputVarsButton));

% 21. Show output vars button
handles.Process.showOutputVarsButton=uibutton(processTab,'push','Text','Show O','Tag','ShowOutputVarsButton','Tooltip','Show Output Vars of Current Function','ButtonPushedFcn',@(showOutputVarsButton,event) showOutputVarsButtonPushed(showOutputVarsButton));

% 33. Specify trials label
handles.Process.specifyTrialsLabel=uilabel(processTab,'Text','SpecifyTrials','Tag','SpecifyTrialsLabel','FontWeight','bold');

% 22. Specify trials button/panel/checkboxes/etc.
handles.Process.specifyTrialsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeSelectionChanged(specifyTrialsUITree),'CheckedNodesChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeCheckedNodesChanged(specifyTrialsUITree),'Tag','SpecifyTrialsUITree');

% 23. Assign input arg from existing list
handles.Process.assignExistingArg2InputButton=uibutton(processTab,'push','Text','-> I','Tag','AssignExistingArg2InputButton','Tooltip','Assign Existing Variable as Input to Selected Function','ButtonPushedFcn',@(assignExistingArg2InputButton,event) assignExistingArg2InputButtonPushed(assignExistingArg2InputButton));

% 24. Assign output arg from existing list
handles.Process.assignExistingArg2OutputButton=uibutton(processTab,'push','Text','-> O','Tag','AssignExistingArg2OutputButton','Tooltip','Assign Existing Variable as Output of Selected Function','ButtonPushedFcn',@(assignExistingArg2OutputButton,event) assignExistingArg2OutputButtonPushed(assignExistingArg2OutputButton));

% 25. Splits label
handles.Process.splitsLabel=uilabel(processTab,'Text','Processing Splits','Tag','SplitsLabel','FontWeight','bold');

% 26. Splits UI Tree
handles.Process.splitsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(splitsUITree,event) splitsUITreeSelectionChanged(splitsUITree),'CheckedNodesChangedFcn',@(splitsUITree,event) splitsUITreeCheckedNodesChanged(splitsUITree),'Tag','FunctionsUITree');

% 27. Splits description label
% handles.Process.splitsDescriptionLabel=uilabel(processTab,'Text','Split Description','Tag','SplitsDescriptionLabel','FontWeight','bold');

% 28. Splits text area
% handles.Process.splitsTextArea=uitextarea(processTab,'Value','Enter Split Description Here','Tag','SplitsDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(splitsDescriptionTextArea,event) splitsDescriptionTextAreaValueChanged(splitsDescriptionTextArea));

% 29. Fcn search field
handles.Process.fcnsArgsSearchField=uieditfield(processTab,'text','Value','Search','Tag','FcnsArgsSearchField','ValueChangedFcn',@(fcnsArgsSearchField,event) fcnsArgsSearchFieldValueChanged(fcnsArgsSearchField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 30. Subvariable label
% handles.Process.subVarLabel=uilabel(processTab,'Text','Subvariable(s)','Tag','SubVarLabel');

% 31. Subvariable UI Tree
% handles.Process.subVarUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');

% 32. Convert variable between hard-coded and dynamic
handles.Process.convertVarHardDynamicButton=uibutton(processTab,'push','Text','Var Dynamic <=> Hard-coded','Tag','ConvertVarHardDynamicButton','Tooltip','Convert Selected Var Between Hard-Coded and Dynamic','ButtonPushedFcn',@(convertVarHardDynamicButton,event) convertVarHardDynamicButtonPushed(convertVarHardDynamicButton));

% 33. Remove specify trials button
handles.Process.removeSpecifyTrialsButton=uibutton(processTab,'push','Text','ST-','Tag','RemoveSpecifyTrialsButton','Tooltip','Remove Specify Trials Condition','ButtonPushedFcn',@(removeSpecifyTrialsButton,event) removeSpecifyTrialsButtonPushed(removeSpecifyTrialsButton));

% 34. Mark function as an Import function checkbox
handles.Process.markImportFcnCheckbox=uicheckbox(processTab,'Text','Mark Import Fcn','Value',0,'Tag','MarkImportFcnCheckbox','Tooltip','Check this box to mark a function as importing from raw data files','ValueChangedFcn',@(markImportFcnCheckbox,event) markImportFcnCheckboxValueChanged(markImportFcnCheckbox));

% 35. New specify trials button
handles.Process.newSpecifyTrialsButton=uibutton(processTab,'push','Text','ST+','Tag','NewSpecifyTrialsButton','Tooltip','New Specify Trials Condition','ButtonPushedFcn',@(newSpecifyTrialsButton,event) newSpecifyTrialsButtonPushed(newSpecifyTrialsButton));

% 36. New processing split button
handles.Process.newSplitButton=uibutton(processTab,'push','Text','PS+','Tag','NewSplitButton','Tooltip','New Split','ButtonPushedFcn',@(newSplitButton,event) newSplitButtonPushed(newSplitButton));

% 37. Remove processing split button
handles.Process.removeSplitButton=uibutton(processTab,'push','Text','PS-','Tag','RemoveSplitButton','Tooltip','Remove Split','ButtonPushedFcn',@(removeSplitButton,event) removeSplitButtonPushed(removeSplitButton));

% 38. Search variables field
% handles.Process.searchVarsField=uieditfield(processTab,'text','Value','Search','Tag','SearchVarsField','ValueChangedFcn',@(searchVarsField,event) searchVarsFieldValueChanged(searchVarsField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 39. Variables listbox
handles.Process.varsListbox=uilistbox(processTab,'Multiselect','on','Tag','VarsListbox','Items',{'No Vars'},'ValueChangedFcn',@(varsListBox,event) varsListBoxValueChanged(varsListBox));

% 40. Unassign variable from function button
handles.Process.unassignVarsButton=uibutton(processTab,'push','Text','<-','Tag','UnassignVarsButton','Tooltip','Unassign Var From Function','ButtonPushedFcn',@(unassignVarsButton,event) unassignVarsButtonPushed(unassignVarsButton));

% 41. Edit subvariables button
handles.Process.editSubvarsButton=uibutton(processTab,'push','Text','Subvars','Tag','EditSubvarsButton','Tooltip','Edit subvariables','ButtonPushedFcn',@(editSubvarsButton,event) editSubvarsButtonPushed(editSubvarsButton));

% 42. Processing splits description button
handles.Process.splitsDescButton=uibutton(processTab,'push','Text','Splits Desc','Tag','SplitsDescButton','Tooltip','Description of selected split','ButtonPushedFcn',@(splitsDescButton,event) splitsDescButtonPushed(splitsDescButton));

% 43. Place function button
handles.Process.placeFcnButton=uibutton(processTab,'push','Text','Place Fcn','Tag','PlaceFcnButton','Tooltip','Place a function from the processing functions folder into the processing map figure','ButtonPushedFcn',@(placeFcnButton,event) placeFcnButtonPushed(placeFcnButton));

processTab.UserData=struct('MapFigure',handles.Process.mapFigure,'AddFcnButton',handles.Process.addFcnButton,'RemoveFcnButton',handles.Process.removeFcnButton,'AddFcnTypeDropDown',handles.Process.addFcnTypeDropDown,...
    'MoveFcnButton',handles.Process.moveFcnButton,'PropagateChangesButton',handles.Process.propagateChangesButton,'PropagateChangesCheckbox',handles.Process.propagateChangesCheckbox,'RunSelectedFcnsButton',handles.Process.runSelectedFcnsButton,...
    'CreateArgButton',handles.Process.createArgButton,'RemoveArgButton',handles.Process.removeArgButton,'FcnNameLabel',handles.Process.fcnNameLabel,'FcnArgsUITree',handles.Process.fcnArgsUITree,'ArgNameInCodeLabel',handles.Process.argNameInCodeLabel,...
    'ArgNameInCodeField',handles.Process.argNameInCodeField,'FcnDescriptionLabel',handles.Process.fcnDescriptionLabel,'FcnDescriptionTextArea',handles.Process.fcnDescriptionTextArea,'ArgDescriptionLabel',handles.Process.argDescriptionLabel,...
    'ArgDescriptionTextArea',handles.Process.argDescriptionTextArea,'ShowInputVarsButton',handles.Process.showInputVarsButton,'ShowOutputVarsButton',handles.Process.showOutputVarsButton,'AssignExistingArg2InputButton',handles.Process.assignExistingArg2InputButton,...
    'AssignExistingArg2OutputButton',handles.Process.assignExistingArg2OutputButton,'SplitsLabel',handles.Process.splitsLabel,'SplitsListbox',handles.Process.splitsUITree,...
    'FcnsArgsSearchField',handles.Process.fcnsArgsSearchField,'ConvertVarHardDynamicButton',handles.Process.convertVarHardDynamicButton,...
    'SpecifyTrialsUITree',handles.Process.specifyTrialsUITree,'RemoveSpecifyTrialsButton',handles.Process.removeSpecifyTrialsButton,'MarkImportFcnCheckbox',handles.Process.markImportFcnCheckbox,'NewSpecifyTrialsButton',handles.Process.newSpecifyTrialsButton,...
    'SpecifyTrialsLabel',handles.Process.specifyTrialsLabel,'NewSplitButton',handles.Process.newSplitButton,'RemoveSplitButton',handles.Process.removeSplitButton,'UnassignVarsButton',handles.Process.unassignVarsButton,...
    'EditSubvarsButton',handles.Process.editSubvarsButton,'SplitsDescButton',handles.Process.splitsDescButton,'VarsListbox',handles.Process.varsListbox,'PlaceFcnButton',handles.Process.placeFcnButton);

@processResize;
% drawnow; % Show the properly placed Process tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
% % 1. Add function button
% handles.Plot.addFunctionButton=uibutton(plotTab,'push','Text','F+','Tag','AddFunctionButton','Tooltip','Create New Function','ButtonPushedFcn',@(addFunctionButton,event) addFunctionButtonPushed(addFunctionButton));
% 
% % 2. Add function from template button
% handles.Plot.templatesDropDown=uidropdown(plotTab,'Items',{'No Templates'},'Tooltip','Plotting Function Templates','Editable','off','Tag','TemplatesDropDown','ValueChangedFcn',@(templatesDropDown,event) templatesDropDownValueChanged(templatesDropDown));
% 
% % 3. Archive function button
% handles.Plot.archiveFunctionButton=uibutton(plotTab,'push','Text','F-','Tag','ArchiveFunctionButton','Tooltip','Archive Function','ButtonPushedFcn',@(archiveFunctionButton,event) archiveFunctionButtonPushed(archiveFunctionButton));
% 
% % 4. Restore function from archive button
% % handles.Plot.restoreFunctionButton=uibutton(plotTab,'push','Text','F--','Tag','FunctionFromTemplateButton','Tooltip','Create New Function From Template','ButtonPushedFcn',@(createFunctionFromTemplateButton,event) createFunctionFromTemplateButtonPushed(createFunctionFromTemplateButton));
% 
% % 6. Add plotting function template button
% handles.Plot.addPlotTemplateButton=uibutton(plotTab,'push','Text','Template+','Tag','AddPlotTemplateButton','Tooltip','Create New Plot Template','ButtonPushedFcn',@(addPlotTemplateButton,event) addPlotTemplateButtonPushed(addPlotTemplateButton));
% 
% % 7. Archive plotting function type button
% handles.Plot.archivePlotTemplateButton=uibutton(plotTab,'push','Text','Template-','Tag','ArchivePlotTemplateButton','Tooltip','Archive Plot Template','ButtonPushedFcn',@(archivePlotTemplateButton,event) archivePlotTemplateButtonPushed(archivePlotTemplateButton));
% 
% % 8. Restore plotting function type from archive button
% % handles.Plot.restorePlotTemplateButton=uibutton(plotTab,'push','Text','Template--','Tag','RestorePlotTemplateButton','Tooltip','Restore Plot Template','ButtonPushedFcn',@(restorePlotTemplateButton,event) restorePlotTemplateButtonPushed(restorePlotTemplateButton));
% 
% % 9. Save plot label
% handles.Plot.saveFormatLabel=uilabel(plotTab,'Text','Save','Tag','SaveFormatLabel');
% 
% % 10. Save as fig checkbox
% handles.Plot.figCheckbox=uicheckbox(plotTab,'Text','Fig','Value',0,'Tag','FigCheckbox','Tooltip','Save plot as .fig (static only)');
% 
% % 11. Save as png checkbox
% handles.Plot.pngCheckbox=uicheckbox(plotTab,'Text','PNG','Value',0,'Tag','PNGCheckbox','Tooltip','Save plot as .png (static only)');
% 
% % 12. Save as svg checkbox
% handles.Plot.svgCheckbox=uicheckbox(plotTab,'Text','SVG','Value',0,'Tag','SVGCheckbox','Tooltip','Save plot as .svg (static only)');
% 
% % 13. Save as mp4 checkbox
% handles.Plot.mp4Checkbox=uicheckbox(plotTab,'Text','MP4','Value',0,'Tag','MP4Checkbox','Tooltip','Save plot as .mp4 (movies only)');
% 
% % 14. % real speed numeric text field
% handles.Plot.percSpeedEditField=uieditfield(plotTab,'numeric','Tooltip','% Playback Speed (1-100)','Value',0,'Tag','PercSpeedEditField','ValueChangedFcn',@(percSpeedEditField,event) percSpeedEditFieldValueChanged(percSpeedEditField));
% 
% % 15. Interval numeric text field
% handles.Plot.intervalEditField=uieditfield(plotTab,'numeric','Tooltip','Integer >= 1','Value',1,'Tag','IntervalEditField','ValueChangedFcn',@(intervalEditField,event) intervalEditFieldValueChanged(intervalEditField));
% 
% % 16. Functions label
% handles.Plot.functionsLabel=uilabel(plotTab,'Text','Functions','Tag','FunctionsLabel');
% 
% % 17. Functions search edit field
% handles.Plot.functionsSearchEditField=uieditfield(plotTab,'text','Value','','Tooltip','Functions Search','Tag','FunctionsSearchEditField','ValueChangedFcn',@(functionsSearchEditField,event) functionsSearchEditFieldValueChanged(functionsSearchEditField));
% 
% % 18. Functions UI tree
% handles.Plot.functionsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');
% 
% % 19. Arguments label
% handles.Plot.argumentsLabel=uilabel(plotTab,'Text','Arguments','Tag','ArgumentsLabel');
% 
% % 20. Arguments search edit field
% handles.Plot.argumentsSearchEditField=uieditfield(plotTab,'text','Value','','Tooltip','Arguments Search','Tag','ArgumentsSearchEditField','ValueChangedFcn',@(argumentsSearchEditField,event) argumentsSearchEditFieldValueChanged(argumentsSearchEditField));
% 
% % 21. Arguments UI tree
% handles.Plot.argumentsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(argumentsUITree,event) argumentsUITreeSelectionChanged(argumentsUITree),'CheckedNodesChangedFcn',@(argumentsUITree,event) argumentsUITreeCheckedNodesChanged(argumentsUITree),'Tag','ArgumentsUITree');
% 
% % 22. Root save path button
% handles.Plot.rootSavePathButton=uibutton(plotTab,'push','Text','Root Save Path','Tag','RootSavePathButton','Tooltip','Root Folder to Save Plots','ButtonPushedFcn',@(rootSavePathButton) rootSavePathButtonPushed(rootSavePathButton));
% 
% % 23. Root save path edit field
% handles.Plot.rootSavePathEditField=uieditfield(plotTab,'text','Value','Root Save Path','Tooltip','Root Save Path','Tag','RootSavePathEditField','ValueChangedFcn',@(rootSavePathEditField,event) rootSavePathEditFieldValueChanged(rootSavePathEditField));
% 
% % 24. Example plot sneak peek button
% handles.Plot.sneakPeekButton=uibutton(plotTab,'push','Text','Sneak Peek','Tag','SneakPeekButton','Tooltip','Quick Look at Sample Plot of Current Function','ButtonPushedFcn',@(sneakPeekButton) sneakPeekButtonPushed(sneakPeekButton));
% 
% % 25. Analysis label
% handles.Plot.analysisLabel=uilabel(plotTab,'Text','Analysis','Tag','AnalysisLabel');
% 
% % 26. Analysis dropdown
% handles.Plot.analysisDropDown=uidropdown(plotTab,'Items',{'No Analyses'},'Tooltip','The analysis for the current variable','Editable','off','Tag','AnalysisDropDown','ValueChangedFcn',@(analysisDropDown,event) analysisDropDownValueChanged(analysisDropDown));
% 
% % 27. Subvariables label
% handles.Plot.subvariablesLabel=uilabel(plotTab,'Text','Subvariables','Tag','SubvariablesLabel');
% 
% % 28. Subvariables UI tree
% handles.Plot.subvariablesUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(subvariablesUITree,event) subvariablesUITreeSelectionChanged(subvariablesUITree),'CheckedNodesChangedFcn',@(subvariablesUITree,event) subvariablesUITreeCheckedNodesChanged(subvariablesUITree),'Tag','SubvariablesUITree');
% 
% % 29. Subvariable index edit field
% 
% 
% % 30. Modify subvariables button
% handles.Plot.modifySubvariablesButton=uibutton(plotTab,'push','Text','Modify Subvariables','Tag','ModifySubvariablesButton','Tooltip','Modify Subvariables List','ButtonPushedFcn',@(modifySubvariablesButton) modifySubvariablesButtonPushed(modifySubvariablesButton));
% 
% % 31. Group/fcn description label
% handles.Plot.groupFcnDescriptionLabel=uilabel(plotTab,'Text','Group/Fcn Description','Tag','GroupFcnDescriptionLabel');
% 
% % 32. Group/fcn description text area
% handles.Plot.groupFcnDescriptionTextArea=uitextarea(plotTab,'Value','Enter Description Here','Tag','GroupFunctionDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(groupFunctionDescriptionTextArea,event) groupFunctionDescriptionTextAreaValueChanged(groupFunctionDescriptionTextArea));
% 
% % 33. Argument name label (dynamic)
% handles.Plot.argNameLabel=uilabel(plotTab,'Text','Argument','Tag','ArgNameLabel');
% 
% % 34. Argument name in code edit field
% handles.Plot.argNameInCodeEditField=uieditfield(plotTab,'text','Value','','Tooltip','Argument Name in Code','Tag','ArgNameInCodeEditField','ValueChangedFcn',@(argNameInCodeEditField,event) argNameInCodeEditFieldValueChanged(argNameInCodeEditField));
% 
% % 35. Argument description text area
% handles.Plot.argDescriptionTextArea=uitextarea(plotTab,'Value','Enter Argument Description Here','Tag','ArgDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argDescriptionTextArea,event) argDescriptionTextAreaValueChanged(argDescriptionTextArea));
% 
% % 36. Save subfolder label
% handles.Plot.saveSubfolderLabel=uilabel(plotTab,'Text','Subfolder','Tag','SaveSubfolderLabel');
% 
% % 37. Save subfolder edit field
% handles.Plot.saveSubfolderEditField=uieditfield(plotTab,'text','Value','','Tooltip','Save Subfolder','Tag','SaveSubfolderEditField','ValueChangedFcn',@(saveSubfolderEditField,event) saveSubfolderEditFieldValueChanged(saveSubfolderEditField));
% 
% % 38. Plot button
% handles.Plot.plotButton=uibutton(plotTab,'push','Text','Plot','Tag','PlotButton','Tooltip','Run Plotting Function','ButtonPushedFcn',@(plotButton) plotButtonPushed(plotButton));
% 
% % 39. Specify trials button (dynamic label)
% handles.Plot.specifyTrialsButton=uibutton(plotTab,'push','Text','Plot','Tag','SpecifyTrialsButton','Tooltip','Select Specify Trials','ButtonPushedFcn',@(specifyTrialsButton) specifyTrialsButtonPushed(specifyTrialsButton));
% 
% % 40. By condition checkbox
% handles.Plot.byConditionCheckbox=uicheckbox(plotTab,'Text','By Condition','Value',0,'Tag','ByConditionCheckbox','Tooltip','Specify Trials Grouped By Condition');
% 
% % 41. Generate run code button
% handles.Plot.generateRunCodeButton=uibutton(plotTab,'push','Text','Generate Run Code','Tag','GenerateRunCodeButton','Tooltip','Generate Run Code Independent of GUI','ButtonPushedFcn',@(generateRunCodeButton) generateRunCodeButtonPushed(generateRunCodeButton));
% 
% % Comments contain temporarily removed components
% % 'RestoreFunctionButton',handles.Plot.restoreFunctionButton,'RestorePlotTemplateButton',handles.Plot.restorePlotTemplateButton,
% plotTab.UserData=struct('AddFunctionButton',handles.Plot.addFunctionButton,'TemplatesDropDown',handles.Plot.templatesDropDown,'ArchiveFunctionButton',handles.Plot.archiveFunctionButton,...
%     'AddPlotTemplateButton',handles.Plot.addPlotTemplateButton,'ArchivePlotTemplateButton',handles.Plot.archivePlotTemplateButton,...
%     'SaveFormatLabel',handles.Plot.saveFormatLabel,'FigCheckbox',handles.Plot.figCheckbox,'SVGCheckbox',handles.Plot.svgCheckbox,...
%     'PNGCheckbox',handles.Plot.pngCheckbox,'MP4Checkbox',handles.Plot.mp4Checkbox,'PercSpeedEditField',handles.Plot.percSpeedEditField,'IntervalEditField',handles.Plot.intervalEditField,...
%     'FunctionsLabel',handles.Plot.functionsLabel,'FunctionsSearchEditField',handles.Plot.functionsSearchEditField,'FunctionsUITree',handles.Plot.functionsUITree,'ArgumentsLabel',handles.Plot.argumentsLabel,...
%     'ArgumentsSearchEditField',handles.Plot.argumentsSearchEditField,'ArgumentsUITree',handles.Plot.argumentsUITree,'RootSavePathButton',handles.Plot.rootSavePathButton,'RootSavePathEditField',handles.Plot.rootSavePathEditField,...
%     'SneakPeekButton',handles.Plot.sneakPeekButton,'AnalysisLabel',handles.Plot.analysisLabel,'AnalysisDropDown',handles.Plot.analysisDropDown,'SubvariablesLabel',handles.Plot.subvariablesLabel,...
%     'SubvariablesUITree',handles.Plot.subvariablesUITree,'ModifySubvariablesButton',handles.Plot.modifySubvariablesButton,'GroupFcnDescriptionLabel',handles.Plot.groupFcnDescriptionLabel,...
%     'GroupFcnDescriptionTextArea',handles.Plot.groupFcnDescriptionTextArea,'ArgNameLabel',handles.Plot.argNameLabel,'ArgNameInCodeEditField',handles.Plot.argNameInCodeEditField,'ArgDescriptionTextArea',handles.Plot.argDescriptionTextArea,...
%     'SaveSubfolder',handles.Plot.saveSubfolderLabel,'SaveSubfolderEditField',handles.Plot.saveSubfolderEditField,'PlotButton',handles.Plot.plotButton,'SpecifyTrialsButton',handles.Plot.specifyTrialsButton,...
%     'ByConditionCheckbox',handles.Plot.byConditionCheckbox,'GenerateRunCodeButton',handles.Plot.generateRunCodeButton);
% 
% @plotResize;

% drawnow; % Show the properly placed Process tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the stats tab


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the settings tab
% 1. Create gui workspace variable checkbox
% handles.Settings.guiVarCheckbox=uicheckbox(settingsTab,'Text','GUI workspace variable','Value',1,'Tag','GUIVarCheckbox','Tooltip','Check to store GUI variable to workspace. Useful for debugging GUI.','ValueChangedFcn',@(guiVarCheckbox) guiVarCheckboxValueChanged(guiVarCheckbox,event));
% 
% 
% 
% settingsTab.UserData=struct('GUIVarCheckbox',handles.Settings.guiVarCheckbox);
% 
% drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% AFTER COMPONENT INITIALIZATION, READ PROJECT SETTINGS FROM MAT FILE
setappdata(fig,'handles',handles); % Needed for resetProjectAccess_Visibility

% 0. Turn off visibility to everything on the Projects tab except for the
% add project button, the drop down, and the label.
resetProjectAccess_Visibility(fig,0);

% 1. Get the location where the pgui file is currently stored.
[pguiFolderPath,~]=fileparts(pguiPath);

% 2. Find/create the project-independent settings folder
settingsFolderPath=[pguiFolderPath slash 'Project-Independent Settings'];

if exist(settingsFolderPath,'dir')~=7
    mkdir(settingsFolderPath);
end

settingsMATPath=[settingsFolderPath slash 'projectIndependentSettings.mat']; % Get the path to the project-independent settings file.
setappdata(fig,'settingsMATPath',settingsMATPath); % Store the project-independent settings MAT file path to the GUI.

% 3. If the project-independent settings MAT File does not exist, make all components on all tabs invisible except for the add project
% button, project dropdown list, and Project Name label on the Import tab.
if exist(settingsMATPath,'file')~=2    
    % Play the fun audio file.
    [y, Fs]=audioread([pguiFolderPath slash 'App Creation & Component Management' slash 'Fun Audio File' slash 'Lets get ready to rumble Sound Effect.mp3']);
    sound(y,Fs);
    return;
end

% 4. Here, the project-independent settings MAT file exists, so read it.
% mostRecentProjectName is guaranteed to exist.
settingsVarNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
if ~ismember(settingsVarNames,'mostRecentProjectName')    
    return;
end

load(settingsMATPath,'mostRecentProjectName'); % Load the name of the most recently worked on project.

% The most recent project's settings is NOT guaranteed to exist (if the user exited immediately after creating the project without entering the Code Path)
projectNames=settingsVarNames(~ismember(settingsVarNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file

% 5. Set the projects drop down list
[~,idx]=sort(upper(projectNames));
handles.Projects.switchProjectsDropDown.Items=projectNames(idx);
handles.Projects.switchProjectsDropDown.Value=mostRecentProjectName;
% setappdata(fig,'projectName',mostRecentProjectName);

set(handles.Process.mapFigure,'XTick',[]);
set(handles.Process.mapFigure,'YTick',[]);
box(handles.Process.mapFigure,'on');

% 9. Whether the project name was found in the file or not, run the callback to set up the app properly.
switchProjectsDropDownValueChanged(fig); % Run the projectNameFieldValueChanged callback function to recall all of the project-specific metadata from the associated files.

% 10. Set components according to the project-independent settings from the
% settings tab (not done yet)

% 11. Finish pgui creation
% 0. Assign component handles to GUI and send GUI variable to base workspace
drawnow;
assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected
a=toc;
disp(['pgui startup time is ' num2str(a) ' seconds']);