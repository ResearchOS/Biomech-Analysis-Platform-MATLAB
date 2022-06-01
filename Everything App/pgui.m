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

%% Initialize app data
setappdata(fig,'everythingPath',[fileparts(mfilename('fullpath')) slash]); % Path to the 'Everything App' folder.
rmpath(genpath([getappdata(fig,'everythingPath') slash 'm File Library'])); % Ensure that the function library files are not on the path, because I don't want to run those files, I want to copy them to my local project.
setappdata(fig,'projectName',''); % The current project name in the dropdown on the Import tab.
setappdata(fig,'settingsMATPath',''); % The project-independent settings MAT file full path.
setappdata(fig,'projectSettingsMATPath',''); % The project-specific settings MAT file full path.
setappdata(fig,'codePath',''); % The current project's code path on the Import tab.
setappdata(fig,'logsheetPath',''); % The current project's logsheet path on the Import tab.
setappdata(fig,'dataPath',''); % The current project's data path on the Import tab.
setappdata(fig,'NonFcnSettingsStruct',''); % The non-function related settings for the current project
setappdata(fig,'FcnSettingsStruct',''); % The function related settings for the current project

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off','SelectionChangedFcn',@(tabGroup1,event) tabGroup1SelectionChanged(tabGroup1),'Tag','TabGroup'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
importTab=uitab(tabGroup1,'Title','Import','Tag','Import','AutoResizeChildren','off','SizeChangedFcn',@importResize); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','Tag','Process','AutoResizeChildren','off','SizeChangedFcn',@processResize); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','Tag','Plot','AutoResizeChildren','off','SizeChangedFcn',@plotResize); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats','Tag','Stats','AutoResizeChildren','off'); % Create the stats tab
settingsTab=uitab(tabGroup1,'Title','Settings','Tag','Settings','AutoResizeChildren','off'); % Create the settings tab
handles.Tabs.tabGroup1=tabGroup1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
% 1. The project name label
handles.Import.projectNameLabel=uilabel(importTab,'Text','Project Name','Tag','ProjectNameLabel','FontWeight','bold');

% 2. The button to open the logsheet path file picker
handles.Import.logsheetPathButton=uibutton(importTab,'push','Tooltip','Select Logsheet Path','Text','Logsheet Path','Tag','LogsheetPathButton','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));

% 3. The button to open the data path file picker
handles.Import.dataPathButton=uibutton(importTab,'push','Tooltip','Select Data Path','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',@(dataPathButton,event) dataPathButtonPushed(dataPathButton));

% 4. The button to open the code path file picker
handles.Import.codePathButton=uibutton(importTab,'push','Tooltip','Select Code Path','Text','Code Path','Tag','CodePathButton','ButtonPushedFcn',@(codePathButton,event) codePathButtonPushed(codePathButton));

% 5. The text edit field for the logsheet path
handles.Import.logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','Tag','LogsheetPathField','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));

% 6. The text edit field for the data path
handles.Import.dataPathField=uieditfield(importTab,'text','Value','Data Path (contains ''Subject Data'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 7. The text edit field for the code path
handles.Import.codePathField=uieditfield(importTab,'text','Value','Path to Project Processing Code Folder','Tag','CodePathField','ValueChangedFcn',@(codePathField,event) codePathFieldValueChanged(codePathField)); % Code path name edit field (to the folder containing all code for this project).

% 8. Button to open the project's specifyTrials to select which trials to load/import
handles.Import.openSpecifyTrialsButton=uibutton(importTab,'push','Tooltip','Open Import Specify Trials','Text','Create specifyTrials.m','Tag','OpenSpecifyTrialsButton','ButtonPushedFcn',@(openSpecifyTrialsButton,event) openSpecifyTrialsButtonPushed(openSpecifyTrialsButton));

% 9. Button to run the import/load procedure
handles.Import.runImportButton=uibutton(importTab,'push','Tooltip','Run Import','Text','Run Import/Load','Tag','RunImportButton','ButtonPushedFcn',@(runImportButton,event) runImportButtonPushed(runImportButton));

% 10. Drop down to switch between active projects.
handles.Import.switchProjectsDropDown=uidropdown(importTab,'Items',{'New Project'},'Tooltip','Select Project','Editable','off','Tag','SwitchProjectsDropDown','ValueChangedFcn',@(switchProjectsDropDown,event) switchProjectsDropDownValueChanged(switchProjectsDropDown));

% 11. Logsheet label
handles.Import.logsheetLabel=uilabel(importTab,'Text','Logsheet:','FontWeight','bold');

% 12. Number of header rows label
handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# of Header Rows','Tag','NumHeaderRowsLabel','Tooltip','Number of Header Rows in Logsheet');

% 13. Number of header rows text box
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Tooltip','Number of Header Rows in Logsheet','Value',-1,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));

% 14. Subject ID column header label
handles.Import.subjIDColHeaderLabel=uilabel(importTab,'Text','Subject ID Column Header','Tag','SubjectIDColumnHeaderLabel','Tooltip','Logsheet Column Header for Subject Codenames');

% 15. Subject ID column header text box
handles.Import.subjIDColHeaderField=uieditfield(importTab,'text','Value','Subject ID Column Header','Tooltip','Logsheet Column Header for Subject Codenames','Tag','SubjIDColumnHeaderField','ValueChangedFcn',@(subjIDColHeaderField,event) subjIDColHeaderFieldValueChanged(subjIDColHeaderField));

% 16. Trial ID column header label
handles.Import.trialIDColHeaderDataTypeLabel=uilabel(importTab,'Text','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names');

% 17. Trial ID column header text box
handles.Import.trialIDColHeaderDataTypeField=uieditfield(importTab,'text','Value','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','DataTypeTrialIDColumnHeaderField','ValueChangedFcn',@(trialIDColHeaderField,event) trialIDColHeaderDataTypeFieldValueChanged(trialIDColHeaderField));

% 18. Target Trial ID column header label
handles.Import.targetTrialIDColHeaderLabel=uilabel(importTab,'Text','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderLabel','Tooltip','Logsheet Column Header for projectStruct Trial Names');

% 19. Target Trial ID column header field
handles.Import.targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderField','Tooltip','Logsheet Column Header for projectStruct Trial Names','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));

% 21. Create new import function
handles.Import.newImportFcnButton=uibutton(importTab,'push','Text','F+','Tag','OpenImportFcnButton','Tooltip','Create new import function','ButtonPushedFcn',@(newImportFcnButton,event) addImportFcnButtonPushed(newImportFcnButton));

% 22. Archive import function
handles.Import.archiveImportFcnButton=uibutton(importTab,'push','Text','F-','Tag','ArchiveImportFcnButton','Tooltip','Archive selected import function','ButtonPushedFcn',@(archiveImportFcnButton,event) archiveImportFcnButtonPushed(archiveImportFcnButton));

% 23. Add new project button
handles.Import.addProjectButton=uibutton(importTab,'push','Text','P+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));

% 24. Archive project button
handles.Import.archiveProjectButton=uibutton(importTab,'push','Text','P-','Tag','ArchiveProjectButton','Tooltip','Archive current project','ButtonPushedFcn',@(archiveProjectButton,event) archiveProjectButtonPushed(archiveProjectButton));

% 25. Open logsheet button
handles.Import.openLogsheetButton=uibutton(importTab,'push','Text','O','Tag','OpenLogsheetButton','Tooltip','Open logsheet','ButtonPushedFcn',@(openLogsheetButton,event) openLogsheetButtonPushed(openLogsheetButton));

% 26. Open data path button
handles.Import.openDataPathButton=uibutton(importTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));

% 27. Open code path button
handles.Import.openCodePathButton=uibutton(importTab,'push','Text','O','Tag','OpenCodePathButton','Tooltip','Open code folder','ButtonPushedFcn',@(openCodePathButton,event) openCodePathButtonPushed(openCodePathButton));

% 28. All functions UI tree label
handles.Import.functionsUITreeLabel=uilabel(importTab,'Text','Functions','Tag','FunctionsUITreeLabel','FontWeight','bold');

% 29. All arguments UI tree label
handles.Import.argumentsUITreeLabel=uilabel(importTab,'Text','Arguments','Tag','ArgumentsUITreeLabel','FontWeight','bold');

% 30. All functions search bar text box
handles.Import.functionsSearchBarEditField=uieditfield(importTab,'text','Value','','Tooltip','Functions Search By Name','Tag','FunctionsSearchBarEditField','ValueChangedFcn',@(functionsSearchBarEditField,event) functionsSearchBarEditFieldValueChanged(functionsSearchBarEditField));

% 31. All arguments search bar text box
handles.Import.argumentsSearchBarEditField=uieditfield(importTab,'text','Value','','Tooltip','Arguments Search By Name','Tag','ArgumentsSearchBarEditField','ValueChangedFcn',@(argumentsSearchBarEditField,event) argumentsSearchBarEditFieldValueChanged(argumentsSearchBarEditField));

% 32. All functions UI tree
handles.Import.functionsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');

% 33. All arguments UI tree
handles.Import.argumentsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(argumentsUITree,event) argumentsUITreeSelectionChanged(argumentsUITree),'CheckedNodesChangedFcn',@(argumentsUITree,event) argumentsUITreeCheckedNodesChanged(argumentsUITree),'Tag','ArgumentsUITree');

% 34. Group/function description text area (dynamic?) label
handles.Import.groupFunctionDescriptionTextAreaLabel=uilabel(importTab,'Text','Function Description','Tag','GroupFunctionDescriptionTextAreaLabel','FontWeight','bold');

% 35. Group/function description text area
handles.Import.groupFunctionDescriptionTextArea=uitextarea(importTab,'Value','Enter Description Here','Tag','GroupFunctionDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(groupFunctionDescriptionTextArea,event) groupFunctionDescriptionTextAreaValueChanged(groupFunctionDescriptionTextArea));

% 36. Un-archive import function button
% handles.Import.unarchiveImportFcnButton=uibutton(importTab,'push','Text','F--','Tag','UnarchiveImportFcnButton','Tooltip','Unarchive selected import function','ButtonPushedFcn',@(unarchiveImportFcnButton,event) unarchiveImportFcnButtonPushed(unarchiveImportFcnButton));

% 37. Argument description text area label
handles.Import.argumentDescriptionTextAreaLabel=uilabel(importTab,'Text','Argument Description','Tag','ArgumentDescriptionTextAreaLabel','FontWeight','bold');

% 38. Argument description text area
handles.Import.argumentDescriptionTextArea=uitextarea(importTab,'Value','Enter Description Here','Tag','ArgumentDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argumentDescriptionTextArea,event) argumentDescriptionTextAreaValueChanged(argumentDescriptionTextArea));

% 39. Un-archive project button
% handles.Import.unarchiveProjectButton=uibutton(importTab,'push','Text','P--','Tag','UnarchiveProjectButton','Tooltip','Unarchive Current Project','ButtonPushedFcn',@(unarchiveProjectButton,event) unarchiveProjectButtonPushed(unarchiveProjectButton));

% 40. Add argument button
handles.Import.addArgumentButton=uibutton(importTab,'push','Text','A+','Tag','AddArgumentButton','Tooltip','Add New Argument','ButtonPushedFcn',@(addArgumentButton,event) addArgumentButtonPushed(addArgumentButton));

% 41. Archive argument button
handles.Import.archiveArgumentButton=uibutton(importTab,'push','Text','A-','Tag','ArchiveArgumentButton','Tooltip','Archive Selected Argument','ButtonPushedFcn',@(archiveArgumentButton,event) archiveArgumentButtonPushed(archiveArgumentButton));

% 42. Un-archive argument button
% handles.Import.unarchiveArgumentButton=uibutton(importTab,'push','Text','A--','Tag','UnarchiveArgumentButton','Tooltip','Unarchive Selected Argument','ButtonPushedFcn',@(unarchiveArgumentButton,event) unarchiveArgumentButtonPushed(unarchiveArgumentButton));

% 43. Add new data type (group) button
handles.Import.addDataTypeButton=uibutton(importTab,'push','Text','D+','Tag','AddDataTypeButton','Tooltip','Add New Data Type (Groups Import Functions)','ButtonPushedFcn',@(addDataTypeButton,event) addDataTypeButtonPushed(addDataTypeButton));

% 44. Archive data type (group) button
handles.Import.archiveDataTypeButton=uibutton(importTab,'push','Text','D-','Tag','ArchiveDataTypeButton','Tooltip','Archive Data Type','ButtonPushedFcn',@(archiveDataTypeButton,event) archiveDataTypeButtonPushed(archiveDataTypeButton));

% 45. Add argument to function as input variable button
handles.Import.addInputArgumentButton=uibutton(importTab,'push','Text','I+','Tag','AddInputArgumentButton','Tooltip','Add Selected Argument as Input to Selected Function','ButtonPushedFcn',@(addInputArgumentButton,event) addInputArgumentButtonPushed(addInputArgumentButton));

% 46. Add argument to function as output variable button
handles.Import.addOutputArgumentButton=uibutton(importTab,'push','Text','O+','Tag','AddOutputArgumentButton','Tooltip','Add Selected Argument as Output to Selected Function','ButtonPushedFcn',@(addOutputArgumentButton,event) addOutputArgumentButtonPushed(addOutputArgumentButton));

% 47. Remove argument (input or output variable) from function button
handles.Import.removeArgumentButton=uibutton(importTab,'push','Text','IO-','Tag','RemoveArgumentButton','Tooltip','Remove Selected Argument from Selected Function','ButtonPushedFcn',@(removeArgumentButton,event) removeArgumentButtonPushed(removeArgumentButton));

% 48. Add function to data type button
handles.Import.functionToDataTypeButton=uibutton(importTab,'push','Text','F->D','Tag','FunctionToDataTypeButton','Tooltip','Add Selected Function to a Data Type','ButtonPushedFcn',@(functionToDataTypeButton,event) functionToDataTypeButtonPushed(functionToDataTypeButton));

% 49. Remove function from data type button
handles.Import.functionFromDataTypeButton=uibutton(importTab,'push','Text','F<-D','Tag','FunctionFromDataTypeButton','Tooltip','Remove Selected Function from Data Type','ButtonPushedFcn',@(functionFromDataTypeButton,event) functionFromDataTypeButtonPushed(functionFromDataTypeButton));

% Comments contain temporarily removed components
% 'UnarchiveProjectButton',handles.Import.unarchiveProjectButton,'UnarchiveImportFcnButton',handles.Import.unarchiveImportFcnButton,'UnarchiveArgumentButton',handles.Import.unarchiveArgumentButton,
importTab.UserData=struct('ProjectNameLabel',handles.Import.projectNameLabel,'LogsheetPathButton',handles.Import.logsheetPathButton,'DataPathButton',handles.Import.dataPathButton,'CodePathButton',handles.Import.codePathButton,...
    'AddProjectButton',handles.Import.addProjectButton,'LogsheetPathField',handles.Import.logsheetPathField,'DataPathField',handles.Import.dataPathField,'CodePathField',handles.Import.codePathField,...
    'OpenSpecifyTrialsButton',handles.Import.openSpecifyTrialsButton,'SwitchProjectsDropDown',handles.Import.switchProjectsDropDown,'RunImportButton',handles.Import.runImportButton,'LogsheetLabel',handles.Import.logsheetLabel,...
    'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,...
    'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,...
    'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,'ArchiveImportFcnButton',handles.Import.archiveImportFcnButton,...
    'NewImportFcnButton',handles.Import.newImportFcnButton,'OpenLogsheetButton',handles.Import.openLogsheetButton,'OpenDataPathButton',handles.Import.openDataPathButton','OpenCodePathButton',handles.Import.openCodePathButton,...
    'ArchiveProjectButton',handles.Import.archiveProjectButton,'FunctionsUITreeLabel',handles.Import.functionsUITreeLabel,'ArgumentsUITreeLabel',handles.Import.argumentsUITreeLabel,'FunctionsSearchBarEditField',handles.Import.functionsSearchBarEditField,...
    'ArgumentsSearchBarEditField',handles.Import.argumentsSearchBarEditField,'FunctionsUITree',handles.Import.functionsUITree,'ArgumentsUITree',handles.Import.argumentsUITree,'GroupFunctionDescriptionTextAreaLabel',handles.Import.groupFunctionDescriptionTextAreaLabel,...
    'GroupFunctionDescriptionTextArea',handles.Import.groupFunctionDescriptionTextArea,'ArgumentDescriptionTextAreaLabel',handles.Import.argumentDescriptionTextAreaLabel,...
    'ArgumentDescriptionTextArea',handles.Import.argumentDescriptionTextArea,'AddArgumentButton',handles.Import.addArgumentButton,'ArchiveArgumentButton',handles.Import.archiveArgumentButton,...
    'AddDataTypeButton',handles.Import.addDataTypeButton,'ArchiveDataTypeButton',handles.Import.archiveDataTypeButton,'AddInputArgumentButton',handles.Import.addInputArgumentButton,...
    'AddOutputArgumentButton',handles.Import.addOutputArgumentButton,'RemoveArgumentButton',handles.Import.removeArgumentButton,'FunctionToDataTypeButton',handles.Import.functionToDataTypeButton,...
    'FunctionFromDataTypeButton',handles.Import.functionFromDataTypeButton);

@importResize; % Run the importResize to set all components' positions to their correct positions

% drawnow; % Show the properly placed import tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
% 1. Analysis label
handles.Process.analysisLabel=uilabel(processTab,'Text','Analysis','Tag','AnalysisLabel','FontWeight','bold');

% 2. Analysis drop down
handles.Process.analysisDropDown=uidropdown(processTab,'Items',{'New Analysis'},'Tooltip','Select Analysis','Editable','off','Tag','SwitchAnalysisDropDown','ValueChangedFcn',@(switchAnalysisDropDown,event) switchAnalysisDropDownValueChanged(switchAnalysisDropDown));

% 3. New analysis button
handles.Process.newAnalysisButton=uibutton(processTab,'push','Text','An+','Tag','NewAnalysisButton','Tooltip','Create New Analysis','ButtonPushedFcn',@(newAnalysisButton,event) newAnalysisButtonPushed(newAnalysisButton));

% 4. Archive analysis button
handles.Process.archiveAnalysisButton=uibutton(processTab,'push','Text','An-','Tag','ArchiveAnalysisButton','Tooltip','Archive Analysis','ButtonPushedFcn',@(archiveAnalysisButton,event) archiveAnalysisButtonPushed(archiveAnalysisButton));

% 5. All functions UI tree label
handles.Process.functionsUITreeLabel=uilabel(processTab,'Text','Functions','Tag','FunctionsUITreeLabel','FontWeight','bold');

% 6. All arguments UI tree label
handles.Process.argumentsUITreeLabel=uilabel(processTab,'Text','Arguments','Tag','ArgumentsUITreeLabel','FontWeight','bold');

% 7. All functions search bar
handles.Process.functionsSearchBarEditField=uieditfield(processTab,'text','Value','','Tooltip','Functions Search By Name','Tag','FunctionsSearchBarEditField','ValueChangedFcn',@(functionsSearchBarEditField,event) functionsSearchBarEditFieldValueChanged(functionsSearchBarEditField));

% 8. All arguments search bar
handles.Process.argumentsSearchBarEditField=uieditfield(processTab,'text','Value','','Tooltip','Arguments Search By Name','Tag','ArgumentsSearchBarEditField','ValueChangedFcn',@(argumentsSearchBarEditField,event) argumentsSearchBarEditFieldValueChanged(argumentsSearchBarEditField));

% 9. All functions UI tree
handles.Process.functionsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');

% 10. All arguments UI tree
handles.Process.argumentsUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(argumentsUITree,event) argumentsUITreeSelectionChanged(argumentsUITree),'CheckedNodesChangedFcn',@(argumentsUITree,event) argumentsUITreeCheckedNodesChanged(argumentsUITree),'Tag','ArgumentsUITree');

% 11. Create new group button
handles.Process.newGroupButton=uibutton(processTab,'push','Text','G+','Tag','NewGroupButton','Tooltip','New Group','ButtonPushedFcn',@(newGroupButton,event) newGroupButtonPushed(newGroupButton));

% 12. Archive group button
handles.Process.archiveGroupButton=uibutton(processTab,'push','Text','G-','Tag','NewGroupButton','Tooltip','Archive Group','ButtonPushedFcn',@(archiveGroupButton,event) archiveGroupButtonPushed(archiveGroupButton));

% 13. Create new function button
handles.Process.newFunctionButton=uibutton(processTab,'push','Text','F+','Tag','NewFunctionButton','Tooltip','New Function','ButtonPushedFcn',@(newFunctionButton,event) newFunctionButtonPushed(newFunctionButton));

% 14. Archive function button
handles.Process.archiveFunctionButton=uibutton(processTab,'push','Text','F-','Tag','NewFunctionButton','Tooltip','Archive Function','ButtonPushedFcn',@(archiveFunctionButton,event) archiveFunctionButtonPushed(archiveFunctionButton));

% 15. Assign function to group button
handles.Process.functionToGroupButton=uibutton(processTab,'push','Text','F->G','Tag','FunctionToGroupButton','Tooltip','Assign Function to Group','ButtonPushedFcn',@(functionToGroupButton,event) functionToGroupButtonPushed(functionToGroupButton));

% 16. Unassign function from group button
handles.Process.functionFromGroupButton=uibutton(processTab,'push','Text','F<-G','Tag','FunctionFromGroupButton','Tooltip','Remove Function from Group','ButtonPushedFcn',@(functionFromGroupButton,event) functionFromGroupButtonPushed(functionFromGroupButton));

% 17. Reorder groups in this analysis button
handles.Process.reorderGroupsButton=uibutton(processTab,'push','Text','G Reorder','Tag','GroupReorderButton','Tooltip','Reorder Groups','ButtonPushedFcn',@(reorderGroupsButton,event) reorderGroupsButtonPushed(reorderGroupsButton));

% 18. Reorder functions in this group (in this analysis) button
handles.Process.reorderFunctionsButton=uibutton(processTab,'push','Text','F Reorder','Tag','FunctionReorderButton','Tooltip','Reorder Functions in Current Group','ButtonPushedFcn',@(reorderFunctionsButton,event) reorderFunctionsButtonPushed(reorderFunctionsButton));

% 19. Create new argument button
handles.Process.newArgumentButton=uibutton(processTab,'push','Text','A+','Tag','NewArgumentButton','Tooltip','New Argument','ButtonPushedFcn',@(newArgumentButton,event) newArgumentButtonPushed(newArgumentButton));

% 20. Archive argument button
handles.Process.archiveArgumentButton=uibutton(processTab,'push','Text','A-','Tag','ArchiveArgumentButton','Tooltip','Archive Argument','ButtonPushedFcn',@(archiveArgumentButton,event) archiveArgumentButtonPushed(archiveArgumentButton));

% 21. Add argument to function as input button
handles.Process.addInputArgumentButton=uibutton(processTab,'push','Text','I+','Tag','AddInputArgumentButton','Tooltip','Add Input Argument','ButtonPushedFcn',@(addInputArgumentButton,event) addInputArgumentButtonPushed(addInputArgumentButton));

% 22. Add argument to function as output button
handles.Process.addOutputArgumentButton=uibutton(processTab,'push','Text','O+','Tag','AddOutputArgumentButton','Tooltip','Add Output Argument','ButtonPushedFcn',@(addOutputArgumentButton,event) addOutputArgumentButtonPushed(addOutputArgumentButton));

% 23. Unassign argument from function
handles.Process.removeArgumentButton=uibutton(processTab,'push','Text','IO-','Tag','RemoveArgumentButton','Tooltip','Remove Argument','ButtonPushedFcn',@(removeArgumentButton,event) removeArgumentButtonPushed(removeArgumentButton));

% 24. Checkbox to indicate argument (variable) value has been manually edited
handles.Process.manualArgumentCheckbox=uicheckbox(processTab,'Text','Manual','Value',0,'Tag','ManualArgumentCheckbox','Tooltip','If checked, argument was manually edited');

% 25. Edit name label 
handles.Process.editNameLabel=uilabel(processTab,'Text','Edit Name','Tag','EditNameLabel');

% 26. Edit name text field
handles.Process.editNameEditField=uieditfield(processTab,'text','Value','','Tooltip','Manual Edits Name','Tag','ManualEditNameEditField','ValueChangedFcn',@(editNameEditField,event) editNameEditFieldValueChanged(editNameEditField));

% 27. Save argument button
handles.Process.manualSaveArgButton=uibutton(processTab,'push','Text','Manual Save','Tag','ManualSaveArgButton','Tooltip','Manual Argument Save','ButtonPushedFcn',@(manualSaveArgButton,event) manualSaveArgButtonPushed(manualSaveArgButton));

% 28. Dynamic function name label (currently selected function name)
handles.Process.argFcnNameLabel=uilabel(processTab,'Text','ArgFcnNameLabel','Tag','ArgFcnNameLabel');

% 29. Analysis Description Label (dynamic)
% handles.Process.analysisDescriptionLabel=uilabel(processTab,'Text','Current Analysis','Tag','AnalysisDescriptionLabel');

% 30. Analysis Description button
handles.Process.analysisDescriptionButton=uibutton(processTab,'push','Text','An Description','Tag','AnalysisDescriptionButton','Tooltip','Current Analysis Description','ButtonPushedFcn',@(analysisDescriptionButton,event) analysisDescriptionButtonPushed(analysisDescriptionButton));

% 31. Generate analysis Run Code button
handles.Process.genRunCodeButton=uibutton(processTab,'push','Text',{'Generate Run Code'},'Tag','GenRunCodeButton','Tooltip','Generate Run Code for Current Analysis','ButtonPushedFcn',@(genRunCodeButton,event) genRunCodeButtonPushed(genRunCodeButton));

% 32. Selected arg name dynamic label
handles.Process.argNameLabel=uilabel(processTab,'Text','Current Argument','Tag','ArgNameLabel');

% 33. Name in code text field
handles.Process.nameInCodeEditField=uieditfield(processTab,'text','Value','','Tooltip','Argument''s Name in Code','Tag','NameInCodeEditField','ValueChangedFcn',@(nameInCodeEditField,event) nameInCodeEditFieldValueChanged(nameInCodeEditField));

% 34. Level label
handles.Process.argLevelLabel=uilabel(processTab,'Text','Level','Tag','ArgLevelLabel');

% 35. Level dropdown
handles.Process.levelDropDown=uidropdown(processTab,'Items',{'P','S','T'},'Tooltip','Argument Level','Editable','off','Tag','LevelDropDown','ValueChangedFcn',@(levelDropDown,event) levelDropDownValueChanged(levelDropDown));

% 38. Subvariable label
handles.Process.subvariablesLabel=uilabel(processTab,'Text','Subvariables','Tag','SubvariablesLabel');

% 39. Subvariable index edit field
handles.Process.subvariableIndexEditField=uieditfield(processTab,'text','Value','','Tooltip','Subvariable Index','Tag','SubvariableIndexEditField','ValueChangedFcn',@(subvariableIndexEditField,event) subvariableIndexEditFieldValueChanged(subvariableIndexEditField));

% 40. "G" (Group) label
handles.Process.groupSpecifyTrialsLabel=uilabel(processTab,'Text','G','Tag','GroupSpecifyTrialsLabel');

% 41. "G" (Group) Specify Trials button
handles.Process.groupSpecifyTrialsButton=uibutton(processTab,'push','Text','G Specify Trials','Tag','GroupSpecifyTrialsButton','Tooltip','Group Specify Trials','ButtonPushedFcn',@(groupSpecifyTrialsButton,event) groupSpecifyTrialsButtonPushed(groupSpecifyTrialsButton));

% 42. "F" (Function) label
handles.Process.functionSpecifyTrialsLabel=uilabel(processTab,'Text','F','Tag','FunctionSpecifyTrialsLabel');

% 43. "F" (Function) Specify Trials button
handles.Process.functionSpecifyTrialsButton=uibutton(processTab,'push','Text','F Specify Trials','Tag','FunctionSpecifyTrialsButton','Tooltip','Function Specify Trials','ButtonPushedFcn',@(functionSpecifyTrialsButton,event) functionSpecifyTrialsButtonPushed(functionSpecifyTrialsButton));

% 44. Function/group description (dynamic?) label
handles.Process.groupFcnDescriptionLabel=uilabel(processTab,'Text','Group/Fcn Description','Tag','GroupFcnDescriptionLabel');

% 45. Group description text area
handles.Process.groupFcnDescriptionTextArea=uitextarea(processTab,'Value','Enter Group/Function Description Here','Tag','GroupFcnDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(groupFcnDescriptionTextArea,event) groupFcnDescriptionTextAreaValueChanged(groupFcnDescriptionTextArea));

% 47. Argument description text area
handles.Process.argDescriptionTextArea=uitextarea(processTab,'Value','Enter Argument Description Here','Tag','ArgDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argDescriptionTextArea,event) argDescriptionTextAreaValueChanged(argDescriptionTextArea));

% 48. Run Group(s) button
handles.Process.runGroupButton=uibutton(processTab,'push','Text','Run Group(s)','Tag','RunGroupButton','Tooltip','Run Processing Functions','ButtonPushedFcn',@(runGroupButton,event) runGroupButtonPushed(runGroupButton));

% 49. Subvariable UI tree
handles.Process.subvariableUITree=uitree(processTab,'checkbox','SelectionChangedFcn',@(subvariableUITree,event) subvariableUITreeSelectionChanged(subvariableUITree),'CheckedNodesChangedFcn',@(subvariableUITree,event) subvariableUITreeCheckedNodesChanged(subvariableUITree),'Tag','SubvariableUITree');

% 50. Modify subvariables button
handles.Process.modifySubvariablesButton=uibutton(processTab,'push','Text','Modify Subvariables','Tag','ModifySubvariablesButton','Tooltip','Modify Subvariables','ButtonPushedFcn',@(modifySubvariablesButton,event) modifySubvariablesButtonPushed(modifySubvariablesButton));

processTab.UserData=struct('AnalysisLabel',handles.Process.analysisLabel,'SwitchAnalysisDropDown',handles.Process.analysisDropDown,'NewAnalysisButton',handles.Process.newAnalysisButton,'ArchiveAnalysisButton',handles.Process.archiveAnalysisButton,...
    'FunctionsUITreeLabel',handles.Process.functionsUITreeLabel,'ArgumentsUITreeLabel',handles.Process.argumentsUITreeLabel,'FunctionsSearchBarEditField',handles.Process.functionsSearchBarEditField,'ArgumentsSearchBarEditField',handles.Process.argumentsSearchBarEditField,...
    'FunctionsUITree',handles.Process.functionsUITree,'ArgumentsUITree',handles.Process.argumentsUITree,'NewGroupButton',handles.Process.newGroupButton,'ArchiveGroupButton',handles.Process.archiveGroupButton,'NewFunctionButton',handles.Process.newFunctionButton,...
    'ArchiveFunctionButton',handles.Process.archiveFunctionButton,'FunctionToGroupButton',handles.Process.functionToGroupButton,'FunctionFromGroupButton',handles.Process.functionFromGroupButton,'ReorderGroupsButton',handles.Process.reorderGroupsButton,...
    'ReorderFunctionsButton',handles.Process.reorderFunctionsButton,'NewArgumentButton',handles.Process.newArgumentButton,'ArchiveArgumentButton',handles.Process.archiveArgumentButton,'AddInputArgumentButton',handles.Process.addInputArgumentButton,...
    'AddOutputArgumentButton',handles.Process.addOutputArgumentButton,'RemoveArgumentButton',handles.Process.removeArgumentButton,'ManualArgumentCheckbox',handles.Process.manualArgumentCheckbox,'EditNameLabel',handles.Process.editNameLabel,'EditNameEditField',handles.Process.editNameEditField,...
    'ManualSaveArgButton',handles.Process.manualSaveArgButton,'ArgFcnNameLabel',handles.Process.argFcnNameLabel,'AnalysisDescriptionButton',handles.Process.analysisDescriptionButton,...
    'GenRunCodeButton',handles.Process.genRunCodeButton,'ArgNameLabel',handles.Process.argNameLabel,'NameInCodeEditField',handles.Process.nameInCodeEditField,'ArgLevelLabel',handles.Process.argLevelLabel,'LevelDropDown',handles.Process.levelDropDown,...
    'SubvariablesLabel',handles.Process.subvariablesLabel,'SubvariablesIndexEditField',handles.Process.subvariableIndexEditField,'GroupSpecifyTrialsLabel',handles.Process.groupSpecifyTrialsLabel,'GroupSpecifyTrialsButton',handles.Process.groupSpecifyTrialsButton,...
    'FunctionSpecifyTrialsLabel',handles.Process.functionSpecifyTrialsLabel,'FunctionSpecifyTrialsButton',handles.Process.functionSpecifyTrialsButton,'GroupFcnDescriptionLabel',handles.Process.groupFcnDescriptionLabel,'GroupFcnDescriptionTextArea',handles.Process.groupFcnDescriptionTextArea,...
    'ArgDescriptionTextArea',handles.Process.argDescriptionTextArea,'RunGroupButton',handles.Process.runGroupButton,'SubvariableUITree',handles.Process.subvariableUITree,'ModifySubvariablesButton',handles.Process.modifySubvariablesButton);

% Resize all objects in each subtab.
@processResize;

% drawnow; % Show the properly placed Process tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
% 1. Add function button
handles.Plot.addFunctionButton=uibutton(plotTab,'push','Text','F+','Tag','AddFunctionButton','Tooltip','Create New Function','ButtonPushedFcn',@(addFunctionButton,event) addFunctionButtonPushed(addFunctionButton));

% 2. Add function from template button
handles.Plot.templatesDropDown=uidropdown(plotTab,'Items',{'No Templates'},'Tooltip','Plotting Function Templates','Editable','off','Tag','TemplatesDropDown','ValueChangedFcn',@(templatesDropDown,event) templatesDropDownValueChanged(templatesDropDown));

% 3. Archive function button
handles.Plot.archiveFunctionButton=uibutton(plotTab,'push','Text','F-','Tag','ArchiveFunctionButton','Tooltip','Archive Function','ButtonPushedFcn',@(archiveFunctionButton,event) archiveFunctionButtonPushed(archiveFunctionButton));

% 4. Restore function from archive button
% handles.Plot.restoreFunctionButton=uibutton(plotTab,'push','Text','F--','Tag','FunctionFromTemplateButton','Tooltip','Create New Function From Template','ButtonPushedFcn',@(createFunctionFromTemplateButton,event) createFunctionFromTemplateButtonPushed(createFunctionFromTemplateButton));

% 6. Add plotting function template button
handles.Plot.addPlotTemplateButton=uibutton(plotTab,'push','Text','Template+','Tag','AddPlotTemplateButton','Tooltip','Create New Plot Template','ButtonPushedFcn',@(addPlotTemplateButton,event) addPlotTemplateButtonPushed(addPlotTemplateButton));

% 7. Archive plotting function type button
handles.Plot.archivePlotTemplateButton=uibutton(plotTab,'push','Text','Template-','Tag','ArchivePlotTemplateButton','Tooltip','Archive Plot Template','ButtonPushedFcn',@(archivePlotTemplateButton,event) archivePlotTemplateButtonPushed(archivePlotTemplateButton));

% 8. Restore plotting function type from archive button
% handles.Plot.restorePlotTemplateButton=uibutton(plotTab,'push','Text','Template--','Tag','RestorePlotTemplateButton','Tooltip','Restore Plot Template','ButtonPushedFcn',@(restorePlotTemplateButton,event) restorePlotTemplateButtonPushed(restorePlotTemplateButton));

% 9. Save plot label
handles.Plot.saveFormatLabel=uilabel(plotTab,'Text','Save','Tag','SaveFormatLabel');

% 10. Save as fig checkbox
handles.Plot.figCheckbox=uicheckbox(plotTab,'Text','Fig','Value',0,'Tag','FigCheckbox','Tooltip','Save plot as .fig (static only)');

% 11. Save as png checkbox
handles.Plot.pngCheckbox=uicheckbox(plotTab,'Text','PNG','Value',0,'Tag','PNGCheckbox','Tooltip','Save plot as .png (static only)');

% 12. Save as svg checkbox
handles.Plot.svgCheckbox=uicheckbox(plotTab,'Text','SVG','Value',0,'Tag','SVGCheckbox','Tooltip','Save plot as .svg (static only)');

% 13. Save as mp4 checkbox
handles.Plot.mp4Checkbox=uicheckbox(plotTab,'Text','MP4','Value',0,'Tag','MP4Checkbox','Tooltip','Save plot as .mp4 (movies only)');

% 14. % real speed numeric text field
handles.Plot.percSpeedEditField=uieditfield(plotTab,'numeric','Tooltip','% Playback Speed (1-100)','Value',0,'Tag','PercSpeedEditField','ValueChangedFcn',@(percSpeedEditField,event) percSpeedEditFieldValueChanged(percSpeedEditField));

% 15. Interval numeric text field
handles.Plot.intervalEditField=uieditfield(plotTab,'numeric','Tooltip','Integer >= 1','Value',1,'Tag','IntervalEditField','ValueChangedFcn',@(intervalEditField,event) intervalEditFieldValueChanged(intervalEditField));

% 16. Functions label
handles.Plot.functionsLabel=uilabel(plotTab,'Text','Functions','Tag','FunctionsLabel');

% 17. Functions search edit field
handles.Plot.functionsSearchEditField=uieditfield(plotTab,'text','Value','','Tooltip','Functions Search','Tag','FunctionsSearchEditField','ValueChangedFcn',@(functionsSearchEditField,event) functionsSearchEditFieldValueChanged(functionsSearchEditField));

% 18. Functions UI tree
handles.Plot.functionsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(functionsUITree,event) functionsUITreeSelectionChanged(functionsUITree),'CheckedNodesChangedFcn',@(functionsUITree,event) functionsUITreeCheckedNodesChanged(functionsUITree),'Tag','FunctionsUITree');

% 19. Arguments label
handles.Plot.argumentsLabel=uilabel(plotTab,'Text','Arguments','Tag','ArgumentsLabel');

% 20. Arguments search edit field
handles.Plot.argumentsSearchEditField=uieditfield(plotTab,'text','Value','','Tooltip','Arguments Search','Tag','ArgumentsSearchEditField','ValueChangedFcn',@(argumentsSearchEditField,event) argumentsSearchEditFieldValueChanged(argumentsSearchEditField));

% 21. Arguments UI tree
handles.Plot.argumentsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(argumentsUITree,event) argumentsUITreeSelectionChanged(argumentsUITree),'CheckedNodesChangedFcn',@(argumentsUITree,event) argumentsUITreeCheckedNodesChanged(argumentsUITree),'Tag','ArgumentsUITree');

% 22. Root save path button
handles.Plot.rootSavePathButton=uibutton(plotTab,'push','Text','Root Save Path','Tag','RootSavePathButton','Tooltip','Root Folder to Save Plots','ButtonPushedFcn',@(rootSavePathButton) rootSavePathButtonPushed(rootSavePathButton));

% 23. Root save path edit field
handles.Plot.rootSavePathEditField=uieditfield(plotTab,'text','Value','Root Save Path','Tooltip','Root Save Path','Tag','RootSavePathEditField','ValueChangedFcn',@(rootSavePathEditField,event) rootSavePathEditFieldValueChanged(rootSavePathEditField));

% 24. Example plot sneak peek button
handles.Plot.sneakPeekButton=uibutton(plotTab,'push','Text','Sneak Peek','Tag','SneakPeekButton','Tooltip','Quick Look at Sample Plot of Current Function','ButtonPushedFcn',@(sneakPeekButton) sneakPeekButtonPushed(sneakPeekButton));

% 25. Analysis label
handles.Plot.analysisLabel=uilabel(plotTab,'Text','Analysis','Tag','AnalysisLabel');

% 26. Analysis dropdown
handles.Plot.analysisDropDown=uidropdown(plotTab,'Items',{'No Analyses'},'Tooltip','The analysis for the current variable','Editable','off','Tag','AnalysisDropDown','ValueChangedFcn',@(analysisDropDown,event) analysisDropDownValueChanged(analysisDropDown));

% 27. Subvariables label
handles.Plot.subvariablesLabel=uilabel(plotTab,'Text','Subvariables','Tag','SubvariablesLabel');

% 28. Subvariables UI tree
handles.Plot.subvariablesUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(subvariablesUITree,event) subvariablesUITreeSelectionChanged(subvariablesUITree),'CheckedNodesChangedFcn',@(subvariablesUITree,event) subvariablesUITreeCheckedNodesChanged(subvariablesUITree),'Tag','SubvariablesUITree');

% 29. Subvariable index edit field


% 30. Modify subvariables button
handles.Plot.modifySubvariablesButton=uibutton(plotTab,'push','Text','Modify Subvariables','Tag','ModifySubvariablesButton','Tooltip','Modify Subvariables List','ButtonPushedFcn',@(modifySubvariablesButton) modifySubvariablesButtonPushed(modifySubvariablesButton));

% 31. Group/fcn description label
handles.Plot.groupFcnDescriptionLabel=uilabel(plotTab,'Text','Group/Fcn Description','Tag','GroupFcnDescriptionLabel');

% 32. Group/fcn description text area
handles.Plot.groupFcnDescriptionTextArea=uitextarea(plotTab,'Value','Enter Description Here','Tag','GroupFunctionDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(groupFunctionDescriptionTextArea,event) groupFunctionDescriptionTextAreaValueChanged(groupFunctionDescriptionTextArea));

% 33. Argument name label (dynamic)
handles.Plot.argNameLabel=uilabel(plotTab,'Text','Argument','Tag','ArgNameLabel');

% 34. Argument name in code edit field
handles.Plot.argNameInCodeEditField=uieditfield(plotTab,'text','Value','','Tooltip','Argument Name in Code','Tag','ArgNameInCodeEditField','ValueChangedFcn',@(argNameInCodeEditField,event) argNameInCodeEditFieldValueChanged(argNameInCodeEditField));

% 35. Argument description text area
handles.Plot.argDescriptionTextArea=uitextarea(plotTab,'Value','Enter Argument Description Here','Tag','ArgDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argDescriptionTextArea,event) argDescriptionTextAreaValueChanged(argDescriptionTextArea));

% 36. Save subfolder label
handles.Plot.saveSubfolderLabel=uilabel(plotTab,'Text','Subfolder','Tag','SaveSubfolderLabel');

% 37. Save subfolder edit field
handles.Plot.saveSubfolderEditField=uieditfield(plotTab,'text','Value','','Tooltip','Save Subfolder','Tag','SaveSubfolderEditField','ValueChangedFcn',@(saveSubfolderEditField,event) saveSubfolderEditFieldValueChanged(saveSubfolderEditField));

% 38. Plot button
handles.Plot.plotButton=uibutton(plotTab,'push','Text','Plot','Tag','PlotButton','Tooltip','Run Plotting Function','ButtonPushedFcn',@(plotButton) plotButtonPushed(plotButton));

% 39. Specify trials button (dynamic label)
handles.Plot.specifyTrialsButton=uibutton(plotTab,'push','Text','Plot','Tag','SpecifyTrialsButton','Tooltip','Select Specify Trials','ButtonPushedFcn',@(specifyTrialsButton) specifyTrialsButtonPushed(specifyTrialsButton));

% 40. By condition checkbox
handles.Plot.byConditionCheckbox=uicheckbox(plotTab,'Text','By Condition','Value',0,'Tag','ByConditionCheckbox','Tooltip','Specify Trials Grouped By Condition');

% 41. Generate run code button
handles.Plot.generateRunCodeButton=uibutton(plotTab,'push','Text','Generate Run Code','Tag','GenerateRunCodeButton','Tooltip','Generate Run Code Independent of GUI','ButtonPushedFcn',@(generateRunCodeButton) generateRunCodeButtonPushed(generateRunCodeButton));

% Comments contain temporarily removed components
% 'RestoreFunctionButton',handles.Plot.restoreFunctionButton,'RestorePlotTemplateButton',handles.Plot.restorePlotTemplateButton,
plotTab.UserData=struct('AddFunctionButton',handles.Plot.addFunctionButton,'TemplatesDropDown',handles.Plot.templatesDropDown,'ArchiveFunctionButton',handles.Plot.archiveFunctionButton,...
    'AddPlotTemplateButton',handles.Plot.addPlotTemplateButton,'ArchivePlotTemplateButton',handles.Plot.archivePlotTemplateButton,...
    'SaveFormatLabel',handles.Plot.saveFormatLabel,'FigCheckbox',handles.Plot.figCheckbox,'SVGCheckbox',handles.Plot.svgCheckbox,...
    'PNGCheckbox',handles.Plot.pngCheckbox,'MP4Checkbox',handles.Plot.mp4Checkbox,'PercSpeedEditField',handles.Plot.percSpeedEditField,'IntervalEditField',handles.Plot.intervalEditField,...
    'FunctionsLabel',handles.Plot.functionsLabel,'FunctionsSearchEditField',handles.Plot.functionsSearchEditField,'FunctionsUITree',handles.Plot.functionsUITree,'ArgumentsLabel',handles.Plot.argumentsLabel,...
    'ArgumentsSearchEditField',handles.Plot.argumentsSearchEditField,'ArgumentsUITree',handles.Plot.argumentsUITree,'RootSavePathButton',handles.Plot.rootSavePathButton,'RootSavePathEditField',handles.Plot.rootSavePathEditField,...
    'SneakPeekButton',handles.Plot.sneakPeekButton,'AnalysisLabel',handles.Plot.analysisLabel,'AnalysisDropDown',handles.Plot.analysisDropDown,'SubvariablesLabel',handles.Plot.subvariablesLabel,...
    'SubvariablesUITree',handles.Plot.subvariablesUITree,'ModifySubvariablesButton',handles.Plot.modifySubvariablesButton,'GroupFcnDescriptionLabel',handles.Plot.groupFcnDescriptionLabel,...
    'GroupFcnDescriptionTextArea',handles.Plot.groupFcnDescriptionTextArea,'ArgNameLabel',handles.Plot.argNameLabel,'ArgNameInCodeEditField',handles.Plot.argNameInCodeEditField,'ArgDescriptionTextArea',handles.Plot.argDescriptionTextArea,...
    'SaveSubfolder',handles.Plot.saveSubfolderLabel,'SaveSubfolderEditField',handles.Plot.saveSubfolderEditField,'PlotButton',handles.Plot.plotButton,'SpecifyTrialsButton',handles.Plot.specifyTrialsButton,...
    'ByConditionCheckbox',handles.Plot.byConditionCheckbox,'GenerateRunCodeButton',handles.Plot.generateRunCodeButton);

@plotResize;

% drawnow; % Show the properly placed Process tab components.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the stats tab


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the settings tab


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% AFTER COMPONENT INITIALIZATION, READ PROJECT SETTINGS FROM MAT FILE
% 0. Assign component handles to GUI and send GUI variable to base workspace
setappdata(fig,'handles',handles);
assignin('base','gui',fig); % Store the GUI variable to the base workspace so that it can be manipulated/inspected

% 1. Get the location where the pgui file is currently stored.
[pguiFolderPath,~]=fileparts(pguiPath);

% 2. Find/create the project-independent settings folder
settingsFolderPath=[pguiFolderPath slash 'Project-Independent Settings'];

if exist(settingsFolderPath,'dir')~=7
    mkdir(settingsFolderPath);
end

settingsMATPath=[settingsFolderPath slash 'projectIndependentSettings.mat'];
setappdata(fig,'settingsMATPath',settingsMATPath); % Store the project-independent settings MAT file path to the GUI.

% 3. If the project-independent settings MAT File does not exist, make all components on all tabs invisible except for the add project
% button, project dropdown list, and Project Name label on the Import tab.
if exist(settingsMATPath,'file')~=2 % Turn off visibility on everything except new project components
    beep;
    disp(['Settings file not found at: ' settingsMATPath]);
    disp(['Create a new project to begin!']);
    disp(['Be careful in naming your project, as this cannot be changed later!']);
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~(isequal(tabNames{tabNum},'Import') && ismember(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,{'ProjectNameLabel','AddProjectButton','SwitchProjectsDropDown'}))
                handles.(tabNames{tabNum}).(compNames{compNum}).Visible=0;
            end
        end
    end
    % Play the fun audio file.
    [y, Fs]=audioread([pguiFolderPath slash 'App Creation & Component Management' slash 'Fun Audio File' slash 'Lets get ready to rumble Sound Effect.mp3']);
    sound(y,Fs);
    return;
end

% 4. Here, the project-independent settings MAT file exists, so read it.
% mostRecentProjectName is guaranteed to exist.
load(settingsMATPath,'mostRecentProjectName'); % Load the name of the most recently worked on project.

% The most recent project's settings is NOT guaranteed to exist (if the user exited immediately after creating the project without entering the Code Path)
varNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=varNames(~ismember(varNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file
if ~ismember(mostRecentProjectName,projectNames)
    disp(['Project-specific settings file path could not be found in project-independent settings MAT file (project variable missing)']);
    disp(['To resolve, either enter the Code Path for this project, or check the settings MAT files']);
    % Turn off visibility for everything except new project & code path components
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~(isequal(tabNames{tabNum},'Import') && ismember(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,{'ProjectNameLabel','AddProjectButton','SwitchProjectsDropDown','CodePathButton','CodePathField'}))
                handles.(tabNames{tabNum}).(compNames{compNum}).Visible=0;
            end
        end
    end
    return;
end

% 5. Set the projects drop down list
handles.Import.switchProjectsDropDown.Items=projectNames;
handles.Import.switchProjectsDropDown.Value=mostRecentProjectName;
setappdata(fig,'projectName',mostRecentProjectName);

projectSettingsStruct=load(settingsMATPath,mostRecentProjectName); % Load the path to the project-specific settings. Still need to extract computer-specific paths.
projectSettingsStruct=projectSettingsStruct.(mostRecentProjectName);

% 6. In the settingsMATPath (project-independent settings) extract the path to project-specific settings MAT file.
[~,macAddress]=system('ifconfig en0 | grep ether'); % Get the MAC address of the current computer
macAddress=genvarname(macAddress); % Generate a valid MATLAB variable name from the computer host name.
if ~isfield(projectSettingsStruct,macAddress) % If this is the first time running this project on this computer, there won't be a hostname associated with this project.
    disp(['Project-specific settings file path for this computer could not be found in project-independent settings MAT file (computer hostname missing in project variable)']);
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
    return;
end
projectSettingsMATPath=projectSettingsStruct.(macAddress).projectSettingsMATPath; % Extracts the path of the specific project on the current computer.

setappdata(fig,'projectSettingsMATPath',projectSettingsMATPath); % Store the project-specific MAT file path to the GUI.

if exist(projectSettingsMATPath,'file')~=2
    disp(['The path to the project-specific settings file is not valid. Enter a new one, or check the project-independent settings MAT file located at: ' settingsMATPath]);
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
    return;
end

% 7. Set the code path edit field value
projectSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-function related variables
projectSettingsStruct=projectSettingsStruct.NonFcnSettingsStruct;
handles.Import.codePathField.Value=projectSettingsStruct.Import.Paths.(macAddress).CodePath;

assert(isequal(projectSettingsStruct.ProjectName,mostRecentProjectName)); % Ensure that the proper project's settings are being loaded.

% 8. Whether the project name was found in the file or not, run the callback to set up the app properly.
switchProjectsDropDownValueChanged(fig); % Run the projectNameFieldValueChanged callback function to recall all of the project-specific metadata from the associated files.

if ~ismember('currTab',varNames)
    currTab='Import';
else
    load(settingsMATPath,'currTab');
end
hTab=findobj(handles.Tabs.tabGroup1,'Title',currTab);
handles.Tabs.tabGroup1.SelectedTab=hTab;

% 9. Write the current pgui version number to the project-independent settings.
save(settingsMATPath,'version','-append');

% 10. Finish pgui creation
drawnow;
a=toc;
disp(['pgui startup time is ' num2str(a) ' seconds']);