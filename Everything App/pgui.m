function []=pgui(isRunLog)

tic;
%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED IN THE COMMAND WINDOW TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
% THIS FUNCTION CREATES ALL COMPONENTS, AND CONTAINS THE CALLBACKS FOR ALL COMPONENTS IN THE GUI.

% WRITTEN BY: MITCHELL TILLMAN, 11/06/2021
% IN HONOR AND LOVING MEMORY OF MY FATHER DOUGLAS ERIC TILLMAN, 10/29/1963-07/05/2021

version='3.0'; % Current version of the pgui package.

% Assumes that the app is being run from within the 'Everything App' folder and that the rest of the files & folders within it are untouched.
pguiPath=mfilename('fullpath'); % The path where the pgui function is stored.
addpath(genpath(fileparts(pguiPath))); % Add all subfolders to the path so that app creation & management is unencumbered.

slash=filesep; % File separator

%% Delete the run code figure
runCodeFig=findall(0,'Name','runCodeHiddenGUI');
close(runCodeFig);

%% Create figure
fig=uifigure('Visible','on','Resize','On','AutoResizeChildren','off','SizeChangedFcn',@appResize,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig),'DeleteFcn',@(fig,event) saveGUIState(fig),'KeyPressFcn',@(fig,event) keyPressFcn(fig,event)); % Create the figure window for the app
fig.Name='pgui'; % Name the window
defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',[defaultPos(1:2) defaultPos(3)*2 defaultPos(4)]); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)
setappdata(fig,'version',version);

%% Initialize app data
if exist('isRunLog','var')
    isRunLog=true;
else
    isRunLog=false;
end
setappdata(fig,'isRunLog',isRunLog); % Indicates if this is a run log-generated session, or a user-controlled session. Changes settings path depending, just in case.
setappdata(fig,'logEverCreated',false); % Initialize that the logsheet has ever been created.
setappdata(fig,'everythingPath',[fileparts(mfilename('fullpath')) slash]); % Path to the 'Everything App' folder.
warning off MATLAB:rmpath:DirNotFound; % Remove the 'path not found' warning, because it's not really important here.
rmpath(genpath([getappdata(fig,'everythingPath') slash 'm File Library'])); % Ensure that the function library files are not on the path, because I don't want to run those files, I want to copy them to my local project.
warning on MATLAB:rmpath:DirNotFound; % Turn the warning back on.
setappdata(fig,'projectName',''); % The current project name in the dropdown on the Import tab.
setappdata(fig,'settingsMATPath',''); % The project-independent settings MAT file full path.
setappdata(fig,'projectSettingsMATPath',''); % The project-specific settings MAT file full path.
setappdata(fig,'codePath',''); % The current project's code path on the Import tab.
setappdata(fig,'logsheetPath',''); % The current project's logsheet path on the Import tab.
setappdata(fig,'logsheetPathMAT',''); % The logsheet MAT file path
setappdata(fig,'dataPath',''); % The current project's data path on the Import tab.
setappdata(fig,'NonFcnSettingsStruct',''); % The non-function related settings for the current project
setappdata(fig,'FcnSettingsStruct',''); % The function related settings for the current project
setappdata(fig,'allowAllTabs',0); % Initialize that only the Projects tab can be selected.
setappdata(fig,'rootSavePlotPath',''); % The root folder to save plots to.
setappdata(fig,'currentPointDown',[0 0]); % The location of the mouse on the figure when the mouse is clicked down
setappdata(fig,'currentPointUp',[0 0]); % The location of the mouse on the figure when the mouse is released up
setappdata(fig,'selectedNodeNumbers',0); % The node ID numbers of the selected nodes
setappdata(fig,'splitName',''); % The name of the current processing split
setappdata(fig,'splitCode',''); % The code to append to variables for the current processing split
setappdata(fig,'runLogPath',''); % The path for the running log of all actions taken for a project.

%% Create the uimenus at the top of the figure
% File menu
uiFileMenu=uimenu(fig,'Text','File');
uimenu(uiFileMenu,'Text','Archive Project','Accelerator','S','MenuSelectedFcn',@archiveButtonPushed);
% Map menu
uiMapMenu=uimenu(fig,'Text','Map');
uimenu(uiMapMenu,'Text','Axis Equal','MenuSelectedFcn',@mapFigureAxisEqual);
% Plot menu
uiPlotMenu=uimenu(fig,'Text','Plot');
uimenu(uiPlotMenu,'Text','Axes Limits','Accelerator','L','MenuSelectedFcn',@axLimsButtonPushed);
uimenu(uiPlotMenu,'Text','Fig Size','Accelerator','F','MenuSelectedFcn',@figSizeButtonPushed);
uimenu(uiPlotMenu,'Text','Save Ex Fig','Accelerator','E','MenuSelectedFcn',@saveExFigButtonPushed);
uimenu(uiPlotMenu,'Text','Set Ex Trial','Accelerator','T','MenuSelectedFcn',@exTrialButtonPushed);
uimenu(uiPlotMenu,'Text','Change View','MenuSelectedFcn',@changeViewButtonPushed);
uimenu(uiPlotMenu,'Text','Data Cursor Mode','Accelerator','D','MenuSelectedFcn',@dcmButtonPushed);

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
handles.Projects.dataPathField=uieditfield(projectsTab,'text','Value','Data Path (contains ''Raw Data Files'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 7. The text edit field for the code path
handles.Projects.codePathField=uieditfield(projectsTab,'text','Value','Path to Project Processing Code Folder','Tag','CodePathField','ValueChangedFcn',@(codePathField,event) codePathFieldValueChanged(codePathField)); % Code path name edit field (to the folder containing all code for this project).

% 8. Archive project button
handles.Projects.removeProjectButton=uibutton(projectsTab,'push','Text','P-','Tag','ArchiveProjectButton','Tooltip','Archive current project','ButtonPushedFcn',@(removeProjectButton,event) removeProjectButtonPushed(removeProjectButton));

% 9. Open data path button
handles.Projects.openDataPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));

% 10. Open code path button
handles.Projects.openCodePathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenCodePathButton','Tooltip','Open code folder','ButtonPushedFcn',@(openCodePathButton,event) openCodePathButtonPushed(openCodePathButton));

% 11. Show project-independent settings file
handles.Projects.openPISettingsPathButton=uibutton(projectsTab,'push','Text','Open P-I Settings','Tag','OpenPISettingsPathButton','Tooltip','Open project-independent settings folder','ButtonPushedFcn',@(openPISettingsPathButton,event) openPISettingsPathButtonPushed(openPISettingsPathButton));

% 12. Dropdown to select between VariableNamesList, Digraph, and
% NonFcnSettingsStruct
handles.Projects.showVarDropDown=uidropdown(projectsTab,'Items',{'VariableNamesList','Digraph','NonFcnSettingsStruct','Plotting'},'Value','VariableNamesList','Tooltip','Select a Variable to Display','Editable','off','Tag','ShowVarDropDown','ValueChangedFcn',@(showVarDropDown,event) showVarDropDownValueChanged(showVarDropDown));

% 13. Show variable button
handles.Projects.showVarButton=uibutton(projectsTab,'push','Text','Show Var','Tag','ShowVarButton','Tooltip','Show selected variable','ButtonPushedFcn',@(showVarButton,event) showVarButtonPushed(showVarButton));

% 14. Update GUI button
handles.Projects.saveVarButton=uibutton(projectsTab,'Text','Save','Tag','SaveVarButton','ButtonPushedFcn',@(saveVarButton,event) saveVarButtonPushed(saveVarButton));

% 15. Archive button
handles.Projects.archiveButton=uibutton(projectsTab,'Text','Archive','Tag','ArchiveButton','ButtonPushedFcn',@(archiveButton,event) archiveButtonPushed(archiveButton));

% 16. Archive data checkbox
handles.Projects.archiveDataCheckbox=uicheckbox(projectsTab,'Text','Archive Data','Value',0,'Tag','ArchiveDataCheckbox','Tooltip','If checked, will archive the project data along with the code. If unchecked, archives code only.','ValueChangedFcn',@(archiveDataCheckbox,event) archiveDataCheckboxValueChanged(archiveDataCheckbox),'Visible','on');

% 17. Load previous archive button
handles.Projects.loadArchiveButton=uibutton(projectsTab,'Text','Load Archive','Tag','LoadArchiveButton','ButtonPushedFcn',@(loadArchiveButton,event) loadArchiveButtonPushed(loadArchiveButton));

projectsTab.UserData=struct('ProjectNameLabel',handles.Projects.projectNameLabel,'DataPathButton',handles.Projects.dataPathButton,'CodePathButton',handles.Projects.codePathButton,...
    'AddProjectButton',handles.Projects.addProjectButton,'SwitchProjectsDropDown',handles.Projects.switchProjectsDropDown,'OpenDataPathButton',handles.Projects.openDataPathButton','OpenCodePathButton',handles.Projects.openCodePathButton,...
    'RemoveProjectButton',handles.Projects.removeProjectButton,'DataPathField',handles.Projects.dataPathField,'CodePathField',handles.Projects.codePathField,'OpenPISettingsPathButton',handles.Projects.openPISettingsPathButton,...
    'ShowVarDropDown',handles.Projects.showVarDropDown,'ShowVarButton',handles.Projects.showVarButton,'SaveVarButton',handles.Projects.saveVarButton,'ArchiveButton',handles.Projects.archiveButton,'ArchiveDataCheckbox',handles.Projects.archiveDataCheckbox,...
    'LoadArchiveButton',handles.Projects.loadArchiveButton);

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

% 20. Variable search field
handles.Import.varSearchField=uieditfield(importTab,'text','Value','Search','Tag','VarSearchField','ValueChangedFcn',@(varSearchField,event) varSearchFieldValueChanged(varSearchField));

% 21. Import data from the logsheet button
handles.Import.runLogImportButton=uibutton(importTab,'push','Text','Run Logsheet Import','Tag','RunLogImportButton','Tooltip','Import logsheet data','ButtonPushedFcn',@(runLogImportButton,event) runLogImportButtonPushed(runLogImportButton));

% 26. Import function drop down (for data type-specific column headers)
handles.Import.importFcnDropDown=uidropdown(importTab,'Items',{'New Import Fcn'},'Editable','off','Tag','ImportFcnDropDown','ValueChangedFcn',@(importFcnDropDown,event) importFcnDropDownValueChanged(importFcnDropDown));

% 27. Check all in log headers UI tree button
handles.Import.checkAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Check all','Tag','CheckAllLogVarsUITreeButton','Tooltip','Check all columns','ButtonPushedFcn',@(checkAllLogVarsUITreeButton,event) checkAllLogVarsUITreeButtonPushed(checkAllLogVarsUITreeButton));

% 28. Uncheck all in log headers UI tree button
handles.Import.uncheckAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Uncheck all','Tag','UncheckAllLogVarsUITreeButton','Tooltip','Uncheck all columns','ButtonPushedFcn',@(uncheckAllLogVarsUITreeButton,event) uncheckAllLogVarsUITreeButtonPushed(uncheckAllLogVarsUITreeButton));

% 29. Edit specify trials
% handles.Import.editSpecifyTrialsButton=uibutton(importTab,'push','Text','ST Edit','Tag','EditSpecifyTrialsButton','Tooltip','Edit specify trials condition','ButtonPushedFcn',@(editSpecifyTrialsButton,event) editSpecifyTrialsButtonPushed(editSpecifyTrialsButton));

% 29. Specify trials button
handles.Import.specifyTrialsButton=uibutton(importTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Create or Modify Specify Trials','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));

importTab.UserData=struct('LogsheetPathButton',handles.Import.logsheetPathButton,'LogsheetPathField',handles.Import.logsheetPathField,'LogsheetLabel',handles.Import.logsheetLabel,...
    'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,...
    'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,...
    'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,'OpenLogsheetButton',handles.Import.openLogsheetButton,'LogVarsUITree',handles.Import.logVarsUITree,...
    'DataTypeLabel',handles.Import.dataTypeLabel,'DataTypeDropDown',handles.Import.dataTypeDropDown,'TrialSubjectDropDown',handles.Import.trialSubjectDropDown,...
    'VarSearchField',handles.Import.varSearchField,'RunLogImportButton',handles.Import.runLogImportButton,...
    'ImportFcnDropDown',handles.Import.importFcnDropDown,'CheckAllLogVarsUITreeButton',handles.Import.checkAllLogVarsUITreeButton,'UncheckAllLogVarsUITreeButton',handles.Import.uncheckAllLogVarsUITreeButton,...
    'SpecifyTrialsButton',handles.Import.specifyTrialsButton);

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

% 33. Specify trials label
handles.Process.specifyTrialsLabel=uilabel(processTab,'Text','SpecifyTrials','Tag','SpecifyTrialsLabel','FontWeight','bold');

% 22. Specify trials button/panel/checkboxes/etc.
% handles.Process.specifyTrialsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeSelectionChanged(specifyTrialsUITree),'CheckedNodesChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeCheckedNodesChanged(specifyTrialsUITree),'Tag','SpecifyTrialsUITree');

% 22. Specify trials button
handles.Process.specifyTrialsButton=uibutton(processTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Create or Modify Specify Trials','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));

% 23. Assign input arg from existing list
handles.Process.assignExistingArg2InputButton=uibutton(processTab,'push','Text','-> I','Tag','AssignExistingArg2InputButton','Tooltip','Assign Existing Variable as Input to Selected Function','ButtonPushedFcn',@(assignExistingArg2InputButton,event) assignExistingArg2InputButtonPushed(assignExistingArg2InputButton));

% 24. Assign output arg from existing list
handles.Process.assignExistingArg2OutputButton=uibutton(processTab,'push','Text','-> O','Tag','AssignExistingArg2OutputButton','Tooltip','Assign Existing Variable as Output of Selected Function','ButtonPushedFcn',@(assignExistingArg2OutputButton,event) assignExistingArg2OutputButtonPushed(assignExistingArg2OutputButton));

% 25. Splits label
handles.Process.splitsLabel=uilabel(processTab,'Text','Processing Splits','Tag','SplitsLabel','FontWeight','bold');

% 26. Splits UI Tree
handles.Process.splitsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(splitsUITree,event) splitsUITreeSelectionChanged(splitsUITree),'CheckedNodesChangedFcn',@(splitsUITree,event) splitsUITreeCheckedNodesChanged(splitsUITree),'Tag','SplitsUITree');

% 29. Fcn search field
handles.Process.fcnsArgsSearchField=uieditfield(processTab,'text','Value','Search','Tag','FcnsArgsSearchField','ValueChangingFcn',@(fcnsArgsSearchField,event) fcnsArgsSearchFieldValueChanged(fcnsArgsSearchField,event)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 32. Convert variable between hard-coded and dynamic
handles.Process.convertVarHardDynamicButton=uibutton(processTab,'state','Text','Var Dynamic <=> Hard-coded','Tag','ConvertVarHardDynamicButton','Tooltip','Convert Selected Var Between Hard-Coded and Dynamic','ValueChangedFcn',@(convertVarHardDynamicButton,event) convertVarHardDynamicValueChanged(convertVarHardDynamicButton));

% 34. Mark function as an Import function checkbox
handles.Process.markImportFcnCheckbox=uicheckbox(processTab,'Text','Mark Import Fcn','Value',0,'Tag','MarkImportFcnCheckbox','Tooltip','Check this box to mark a function as importing from raw data files','ValueChangedFcn',@(markImportFcnCheckbox,event) markImportFcnCheckboxValueChanged(markImportFcnCheckbox));

% 36. New processing split button
handles.Process.newSplitButton=uibutton(processTab,'push','Text','PS+','Tag','NewSplitButton','Tooltip','New Split','ButtonPushedFcn',@(newSplitButton,event) newSplitButtonPushed(newSplitButton));

% 37. Remove processing split button
handles.Process.removeSplitButton=uibutton(processTab,'push','Text','PS-','Tag','RemoveSplitButton','Tooltip','Remove Split','ButtonPushedFcn',@(removeSplitButton,event) removeSplitButtonPushed(removeSplitButton));

% 39. Variables UItree (previously a listbox)
handles.Process.varsListbox=uitree(processTab,'Tag','VarsUITree','SelectionChangedFcn',@(varsListbox,event) varsListboxSelectionChanged(varsListbox));

% 40. Unassign variable from function button
handles.Process.unassignVarsButton=uibutton(processTab,'push','Text','<-','Tag','UnassignVarsButton','Tooltip','Unassign Var From Function','ButtonPushedFcn',@(unassignVarsButton,event) unassignVarsButtonPushed(unassignVarsButton));

% 41. Edit subvariables button
handles.Process.editSubvarsButton=uibutton(processTab,'push','Text','Subvars','Tag','EditSubvarsButton','Tooltip','Edit subvariables','ButtonPushedFcn',@(editSubvarsButton,event) editSubvarsButtonPushed(editSubvarsButton));

% 42. Processing splits description button
handles.Process.splitsDescButton=uibutton(processTab,'push','Text','Splits Desc','Tag','SplitsDescButton','Tooltip','Description of selected split','ButtonPushedFcn',@(splitsDescButton,event) splitsDescButtonPushed(splitsDescButton));

% 43. Place function button
handles.Process.placeFcnButton=uibutton(processTab,'push','Text','Place Fcn','Tag','PlaceFcnButton','Tooltip','Place a function from the processing functions folder into the processing map figure','ButtonPushedFcn',@(placeFcnButton,event) placeFcnButtonPushed(placeFcnButton));

% 44. Connect nodes button
handles.Process.connectNodesButton=uibutton(processTab,'push','Text','Connect Fcns','Tag','ConnectNodesButton','Tooltip','Connect two function nodes. Select the origin node, then the end node','ButtonPushedFcn',@(connectNodesButton,event) connectNodesButtonPushed(connectNodesButton));

% 45. Remove processing split from node button
handles.Process.disconnectNodesButton=uibutton(processTab,'push','Text','Rem PS','Tag','DisconnectNodesButton','Tooltip','Remove a specific split connection from a node','ButtonPushedFcn',@(disconnectNodesButton,event) disconnectNodesButtonPushed(disconnectNodesButton));

% 46. Function order edit field
handles.Process.fcnsRunOrderField=uieditfield(processTab,'numeric','Value',0,'Tag','FcnsRunOrderField','ValueChangedFcn',@(fcnsRunOrderField,event) fcnsRunOrderFieldValueChanged(fcnsRunOrderField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 47. Collapse all variables context menu
handles.Process.collapseAllContextMenu=uicontextmenu(fig);
handles.Process.collapseAllContextMenuItem1=uimenu(handles.Process.collapseAllContextMenu,'Text','Collapse All','MenuSelectedFcn',{@collapseAllContextMenuClicked});
% handles.Process.collapseAllContextMenuItem2=uimenu(handles.Process.collapseAllContextMenu,'Text','Test2');

% 48. Open function context menu
handles.Process.openFcnContextMenu=uicontextmenu(fig);
handles.Process.openFcnContextMenuItem1=uimenu(handles.Process.openFcnContextMenu,'Text','Open Fcn','MenuSelectedFcn',{@openMFile});

% 49. Copy variables context menu
% handles.Process.copyVarsContextMenu=uicontextmenu(fig);
handles.Process.openFcnContextMenuItem2=uimenu(handles.Process.openFcnContextMenu,'Text','Copy Vars','MenuSelectedFcn',{@copyFcnVars});
handles.Process.openFcnContextMenuItem3=uimenu(handles.Process.openFcnContextMenu,'Text','Paste Vars','MenuSelectedFcn',{@pasteFcnVars});
handles.Process.openFcnContextMenuItem4=uimenu(handles.Process.openFcnContextMenu,'Text','Expand Vars','MenuSelectedFcn',{@expandFcnVars});

processTab.UserData=struct('MapFigure',handles.Process.mapFigure,'AddFcnButton',handles.Process.addFcnButton,'RemoveFcnButton',handles.Process.removeFcnButton,...
    'MoveFcnButton',handles.Process.moveFcnButton,'PropagateChangesButton',handles.Process.propagateChangesButton,'PropagateChangesCheckbox',handles.Process.propagateChangesCheckbox,'RunSelectedFcnsButton',handles.Process.runSelectedFcnsButton,...
    'CreateArgButton',handles.Process.createArgButton,'RemoveArgButton',handles.Process.removeArgButton,'FcnNameLabel',handles.Process.fcnNameLabel,'FcnArgsUITree',handles.Process.fcnArgsUITree,'ArgNameInCodeLabel',handles.Process.argNameInCodeLabel,...
    'ArgNameInCodeField',handles.Process.argNameInCodeField,'FcnDescriptionLabel',handles.Process.fcnDescriptionLabel,'FcnDescriptionTextArea',handles.Process.fcnDescriptionTextArea,'ArgDescriptionLabel',handles.Process.argDescriptionLabel,...
    'ArgDescriptionTextArea',handles.Process.argDescriptionTextArea,'AssignExistingArg2InputButton',handles.Process.assignExistingArg2InputButton,...
    'AssignExistingArg2OutputButton',handles.Process.assignExistingArg2OutputButton,'SplitsLabel',handles.Process.splitsLabel,'SplitsListbox',handles.Process.splitsUITree,...
    'FcnsArgsSearchField',handles.Process.fcnsArgsSearchField,'ConvertVarHardDynamicButton',handles.Process.convertVarHardDynamicButton,...
    'SpecifyTrialsButton',handles.Process.specifyTrialsButton,'MarkImportFcnCheckbox',handles.Process.markImportFcnCheckbox,...
    'SpecifyTrialsLabel',handles.Process.specifyTrialsLabel,'NewSplitButton',handles.Process.newSplitButton,'RemoveSplitButton',handles.Process.removeSplitButton,'UnassignVarsButton',handles.Process.unassignVarsButton,...
    'EditSubvarsButton',handles.Process.editSubvarsButton,'SplitsDescButton',handles.Process.splitsDescButton,'VarsListbox',handles.Process.varsListbox,'PlaceFcnButton',handles.Process.placeFcnButton,...
    'ConnectNodesButton',handles.Process.connectNodesButton,'DisconnectNodesButton',handles.Process.disconnectNodesButton,'FcnsRunOrderField',handles.Process.fcnsRunOrderField);

@processResize;
% drawnow; % Show the properly placed Process tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
% 1. Search bar for all components browser
handles.Plot.allComponentsSearchField=uieditfield(plotTab,'text','Value','Search','Tag','AllComponentsSearchField','ValueChangingFcn',@(allComponentsSearchField,event) allComponentsSearchFieldValueChanged(allComponentsSearchField));

% 2. All components UI tree
handles.Plot.allComponentsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(allComponentsUITree,event) allComponentsUITreeSelectionChanged(allComponentsUITree),'CheckedNodesChangedFcn',@(allComponentsUITree,event) allComponentsUITreeCheckedNodesChanged(allComponentsUITree),'Tag','AllComponentsUITree');

% 3. Plot function selector
handles.Plot.plotFcnSearchField=uieditfield(plotTab,'text','Value','Search','Tag','PlotFcnSearchField','ValueChangingFcn',@(plotFcnSearchField,event) plotFcnSearchFieldValueChanged(plotFcnSearchField));

% 4. Plot function UI tree
handles.Plot.plotFcnUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(plotFcnUITree,event) plotFcnUITreeSelectionChanged(plotFcnUITree),'CheckedNodesChangedFcn',@(plotFcnUITree,event) plotFcnUITreeCheckedNodesChanged(plotFcnUITree),'Tag','PlotFcnUITree');

% 5. Assign variables button
handles.Plot.assignVarsButton=uibutton(plotTab,'push','Text','Assign Vars','Tag','AssignVarsButton','Tooltip','Assign variables to the currently selected graphics object','ButtonPushedFcn',@(assignVarsButton,event) assignVarsButtonPushed(assignVarsButton));

% 6. Assign component button
handles.Plot.assignComponentButton=uibutton(plotTab,'push','Text','->','Tag','AssignComponentButton','Tooltip','Assign graphics object to the currently selected function version','ButtonPushedFcn',@(assignComponentButton,event) assignComponentButtonPushed(assignComponentButton));

% 7. Unassign component button
handles.Plot.unassignComponentButton=uibutton(plotTab,'push','Text','<-','Tag','UnassignComponentButton','Tooltip','Unassign graphics object from the currently selected function version','ButtonPushedFcn',@(unassignComponentButton,event) unassignComponentButtonPushed(unassignComponentButton));

% 8. Create new function button
handles.Plot.createPlotButton=uibutton(plotTab,'push','Text','P+','Tag','CreateFcnButton','Tooltip','Create a new plot (collection of graphics objects)','ButtonPushedFcn',@(createPlotButton,event) createFcnButtonPushed(createPlotButton));

% 9. Set axis limits button
% handles.Plot.axLimsButton=uibutton(plotTab,'push','Text','Ax Lims','Tag','AxLimsButton','Tooltip','Set axes limits','ButtonPushedFcn',@(axLimsButton,event) axLimsButtonPushed(axLimsButton));

% 10. Figure size button
% handles.Plot.figSizeButton=uibutton(plotTab,'push','Text','Fig Size','Tag','FigSizeButton','Tooltip','Set figure size','ButtonPushedFcn',@(figSizeButton,event) figSizeButtonPushed(figSizeButton));

% 11. Object properties button
% handles.Plot.saveExFigButton=uibutton(plotTab,'push','Text','Save Ex Fig','Tag','SaveExFigButton','Tooltip','Save current state of example figure','ButtonPushedFcn',@(objectPropsButton,event) saveExFigButtonPushed(objectPropsButton));

% 12. Example trial button
% handles.Plot.exTrialButton=uibutton(plotTab,'push','Text','Ex Trial','Tag','ExTrialButton','Tooltip','Set example trial being plotted in app','ButtonPushedFcn',@(exTrialButton,event) exTrialButtonPushed(exTrialButton));

% 13. Example plot figure
% handles.Plot.exTrialFigure=uiaxes(plotTab,'Tag','ExTrialFigure','HandleVisibility','on','Visible','on');

% 14. Current component UI tree
handles.Plot.currCompUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(currCompUITree,event) currCompUITreeSelectionChanged(currCompUITree),'CheckedNodesChangedFcn',@(currCompUITree,event) currCompUITreeCheckedNodesChanged(currCompUITree),'Tag','CurrComponentsUITree');

% 15. Current component description label
handles.Plot.componentDescLabel=uilabel(plotTab,'Text','Component Desc','Tag','ComponentDescLabel','FontWeight','bold');

% 16. Current component description text area
handles.Plot.componentDescTextArea=uitextarea(plotTab,'Value','Enter Component Description Here','Tag','ComponentDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(componentDescTextArea,event) componentDescTextAreaValueChanged(componentDescTextArea));

% 17. Function version description label
handles.Plot.fcnVerDescLabel=uilabel(plotTab,'Text','Fcn Ver Desc','Tag','FcnVerDescLabel','FontWeight','bold');

% 18. Function version description text area
handles.Plot.fcnVerDescTextArea=uitextarea(plotTab,'Value','Enter Fcn Version Description Here','Tag','FcnVerDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(fcnVerDescTextArea,event) fcnVerDescTextAreaValueChanged(fcnVerDescTextArea));

% 19. Specify trials button
handles.Plot.specifyTrialsButton=uibutton(plotTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Set the trials to plot','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));

% 20. Run plot button
handles.Plot.runPlotButton=uibutton(plotTab,'push','Text','Run Plot','Tag','RunPlotButton','Tooltip','Run the plot on the specified trials','ButtonPushedFcn',@(runPlotButton,event) runPlotButtonPushed(runPlotButton));

% 21. Plot level dropdown
handles.Plot.plotLevelDropDown=uidropdown(plotTab,'Items',{'P','C','S','SC','T'},'Tooltip','Specify the level to run this at','Editable','off','Tag','PlotLevelDropDown','ValueChangedFcn',@(plotLevelDropDown,event) plotLevelDropDownValueChanged(plotLevelDropDown));

% 22. All components label
handles.Plot.allComponentsLabel=uilabel(plotTab,'Text','All Components','Tag','AllComponentsLabel','FontWeight','bold');

% 23. All functions label
handles.Plot.allPlotsLabel=uilabel(plotTab,'Text','Plots','Tag','AllFunctionsLabel','FontWeight','bold');

% 24. Current components label
handles.Plot.currComponentsLabel=uilabel(plotTab,'Text','Current Components','Tag','CurrComponentsLabel','FontWeight','bold');

% 25. Create new component button
handles.Plot.createCompButton=uibutton(plotTab,'push','Text','C+','Tag','CreateCompButton','Tooltip','Create a new component','ButtonPushedFcn',@(createCompButton,event) createCompButtonPushed(createCompButton));

% 26. Delete component button
handles.Plot.deleteCompButton=uibutton(plotTab,'push','Text','C-','Tag','DeleteCompButton','Tooltip','Delete a component','ButtonPushedFcn',@(deleteCompButton,event) deleteCompButtonPushed(deleteCompButton));

% 27. Delete plot button
handles.Plot.deletePlotButton=uibutton(plotTab,'push','Text','P-','Tag','DeletePlotButton','Tooltip','Delete a plot','ButtonPushedFcn',@(deletePlotButton,event) deletePlotButtonPushed(deletePlotButton));

% 28. Edit component button
handles.Plot.editCompButton=uibutton(plotTab,'push','Text','Edit Props','Tag','EditCompButton','Tooltip','Edit component','ButtonPushedFcn',@(editCompButton,event) editCompButtonPushed(editCompButton));

% 29. Plot panel
handles.Plot.plotPanel=uipanel(plotTab);

% 30. Movie checkbox
handles.Plot.isMovieCheckbox=uicheckbox(plotTab,'Text','Movie','Value',0,'Tag','IsMovieCheckbox','Tooltip','Plots a movie one frame at a time','ValueChangedFcn',@(isMovieCheckbox,event) isMovieCheckboxButtonPushed(isMovieCheckbox));

% 31. Movie increment edit field
handles.Plot.incEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','IncEditField','ValueChangedFcn',@(incEditField,event) incEditFieldValueChanged(incEditField));

% 32. Increment frame number up by inc
handles.Plot.incFrameUpButton=uibutton(plotTab,'push','Text','->','Tag','IncFrameUpButton','Tooltip','Increment frame up','ButtonPushedFcn',@(incFrameUpButton,event) incFrameUpButtonPushed(incFrameUpButton));

% 33. Increment frame number down by inc
handles.Plot.incFrameDownButton=uibutton(plotTab,'push','Text','<-','Tag','IncFrameDownButton','Tooltip','Increment frame down','ButtonPushedFcn',@(incFrameDownButton,event) incFrameDownButtonPushed(incFrameDownButton));

% 34. Button to set the start frame as a variable
handles.Plot.startFrameButton=uibutton(plotTab,'push','Text','Start Frame','Tag','StartFrameButton','Tooltip','Set start frame based on a variable','ButtonPushedFcn',@(startFrameButton,event) startFrameButtonPushed(startFrameButton));

% 35. Button to set the end frame as a variable
handles.Plot.endFrameButton=uibutton(plotTab,'push','Text','End Frame','Tag','EndFrameButton','Tooltip','Set end frame based on a variable','ButtonPushedFcn',@(endFrameButton,event) endFrameButtonPushed(endFrameButton));

% 35. Edit field to set the start frame hard-coded
handles.Plot.startFrameEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','StartFrameEditField','ValueChangedFcn',@(startFrameEditField,event) startFrameEditFieldValueChanged(startFrameEditField));

% 36. Edit field to set the end frame hard-coded
handles.Plot.endFrameEditField=uieditfield(plotTab,'numeric','Value',2,'Tag','EndFrameEditField','ValueChangedFcn',@(endFrameEditField,event) endFrameEditFieldValueChanged(endFrameEditField));

% 37. Edit field to set the current frame number
handles.Plot.currFrameEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','CurrFrameEditField','ValueChangedFcn',@(currFrameEditField,event) currFrameEditFieldValueChanged(currFrameEditField));

handles.Plot.openPlotFcnContextMenu=uicontextmenu(fig);
handles.Plot.openPlotFcnContextMenuItem1=uimenu(handles.Plot.openPlotFcnContextMenu,'Text','Open Fcn','MenuSelectedFcn',{@openMFilePlot});

handles.Plot.refreshComponentContextMenu=uicontextmenu(fig);
handles.Plot.refreshComponentContextMenuItem1=uimenu(handles.Plot.refreshComponentContextMenu,'Text','Refresh Component','MenuSelectedFcn',{@refreshPlotComp});

plotTab.UserData=struct('AllComponentsSearchField',handles.Plot.allComponentsSearchField,'AllComponentsUITree',handles.Plot.allComponentsUITree,'PlotFcnSearchField',handles.Plot.plotFcnSearchField,...
    'PlotFcnUITree',handles.Plot.plotFcnUITree,'AssignVarsButton',handles.Plot.assignVarsButton,'AssignComponentButton',handles.Plot.assignComponentButton,'UnassignComponentButton',handles.Plot.unassignComponentButton,'CreateFcnButton',handles.Plot.createPlotButton,...
    'CurrComponentsUITree',handles.Plot.currCompUITree,'ComponentDescLabel',handles.Plot.componentDescLabel,'ComponentDescTextArea',handles.Plot.componentDescTextArea,'FcnVerDescLabel',handles.Plot.fcnVerDescLabel,...
    'FcnVerDescTextArea',handles.Plot.fcnVerDescTextArea,'SpecifyTrialsButton',handles.Plot.specifyTrialsButton,'RunPlotButton',handles.Plot.runPlotButton,'PlotLevelDropDown',handles.Plot.plotLevelDropDown,...
    'AllComponentsLabel',handles.Plot.allComponentsLabel,'AllFunctionsLabel',handles.Plot.allPlotsLabel,'CurrComponentsLabel',handles.Plot.currComponentsLabel,'CreateCompButton',handles.Plot.createCompButton,...
    'DeleteCompButton',handles.Plot.deleteCompButton,'DeletePlotButton',handles.Plot.deletePlotButton,'EditCompButton',handles.Plot.editCompButton,'PlotPanel',handles.Plot.plotPanel,...
    'IsMovieCheckbox',handles.Plot.isMovieCheckbox,'IncEditField',handles.Plot.incEditField,'IncFrameUpButton',handles.Plot.incFrameUpButton,'IncFrameDownButton',handles.Plot.incFrameDownButton,...
    'StartFrameButton',handles.Plot.startFrameButton,'EndFrameButton',handles.Plot.endFrameButton,'StartFrameEditField',handles.Plot.startFrameEditField,'EndFrameEditField',handles.Plot.endFrameEditField,'CurrFrameEditField',handles.Plot.currFrameEditField);

@plotResize;

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

% 11. Finish pgui creation. Assign component handles to GUI and send GUI variable to base workspace
drawnow;
assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected
a=toc;
disp(['pgui startup time is ' num2str(a) ' seconds']);
