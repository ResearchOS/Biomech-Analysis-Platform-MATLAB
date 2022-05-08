function []=pgui()

%% PURPOSE: THIS IS THE FUNCTION THAT IS CALLED IN THE COMMAND WINDOW TO OPEN THE GUI FOR IMPORTING/PROCESSING/PLOTTING DATA
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
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Tooltip','Number of Header Rows in Logsheet','Value',0,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));

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
handles.Import.targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','T','Tag','TargetTrialIDColHeaderField','Tooltip','Logsheet Column Header for projectStruct Trial Names','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));

% 21. Create new import function
handles.Import.newImportFcnButton=uibutton(importTab,'push','Text','F+','Tag','OpenImportFcnButton','Tooltip','Create new import function','ButtonPushedFcn',@(openImportFcnButton,event) openImportFcnButtonPushed(openImportFcnButton));

% 22. Archive import function
handles.Import.archiveImportFcnButton=uibutton(importTab,'push','Text','F->A','Tag','ArchiveImportFcnButton','Tooltip','Archive selected import function','ButtonPushedFcn',@(archiveImportFcnButton,event) archiveImportFcnButtonPushed(archiveImportFcnButton));

% 23. Add new project button
handles.Import.addProjectButton=uibutton(importTab,'push','Text','P+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));

% 24. Archive project button
handles.Import.archiveProjectButton=uibutton(importTab,'push','Text','P->A','Tag','ArchiveProjectButton','Tooltip','Archive current project','ButtonPushedFcn',@(archiveProjectButton,event) archiveProjectButtonPushed(archiveProjectButton));

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
handles.Import.groupFunctionDescriptionTextAreaLabel=uilabel(importTab,'Text','Group/Function Description','Tag','GroupFunctionDescriptionTextAreaLabel','FontWeight','bold');

% 35. Group/function description text area
handles.Import.groupFunctionDescriptionTextArea=uitextarea(importTab,'Value','Enter Description Here','Tag','GroupFunctionDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(groupFunctionDescriptionTextArea,event) groupFunctionDescriptionTextAreaValueChanged(groupFunctionDescriptionTextArea));

% 36. Un-archive import function button
handles.Import.unarchiveImportFcnButton=uibutton(importTab,'push','Text','A->F','Tag','UnarchiveImportFcnButton','Tooltip','Unarchive selected import function','ButtonPushedFcn',@(unarchiveImportFcnButton,event) unarchiveImportFcnButtonPushed(unarchiveImportFcnButton));

% 37. Argument description text area label
handles.Import.argumentDescriptionTextAreaLabel=uilabel(importTab,'Text','Argument Description','Tag','ArgumentDescriptionTextAreaLabel','FontWeight','bold');

% 38. Argument description text area
handles.Import.argumentDescriptionTextArea=uitextarea(importTab,'Value','Enter Description Here','Tag','ArgumentDescriptionTextArea','Editable','on','Visible','on','ValueChangedFcn',@(argumentDescriptionTextArea,event) argumentDescriptionTextAreaValueChanged(argumentDescriptionTextArea));

% 39. Un-archive project button
handles.Import.unarchiveProjectButton=uibutton(importTab,'push','Text','A->P','Tag','UnarchiveProjectButton','Tooltip','Unarchive current project','ButtonPushedFcn',@(unarchiveProjectButton,event) unarchiveProjectButtonPushed(unarchiveProjectButton));

importTab.UserData=struct('ProjectNameLabel',handles.Import.projectNameLabel,'LogsheetPathButton',handles.Import.logsheetPathButton,'DataPathButton',handles.Import.dataPathButton,'CodePathButton',handles.Import.codePathButton,...
    'AddProjectButton',handles.Import.addProjectButton,'LogsheetPathField',handles.Import.logsheetPathField,'DataPathField',handles.Import.dataPathField,'CodePathField',handles.Import.codePathField,...
    'OpenSpecifyTrialsButton',handles.Import.openSpecifyTrialsButton,'SwitchProjectsDropDown',handles.Import.switchProjectsDropDown,'RunImportButton',handles.Import.runImportButton,'LogsheetLabel',handles.Import.logsheetLabel,...
    'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,...
    'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,...
    'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,'ArchiveImportFcnButton',handles.Import.archiveImportFcnButton,...
    'NewImportFcnButton',handles.Import.newImportFcnButton,'OpenLogsheetButton',handles.Import.openLogsheetButton,'OpenDataPathButton',handles.Import.openDataPathButton','OpenCodePathButton',handles.Import.openCodePathButton,...
    'ArchiveProjectButton',handles.Import.archiveProjectButton,'FunctionsUITreeLabel',handles.Import.functionsUITreeLabel,'ArgumentsUITreeLabel',handles.Import.argumentsUITreeLabel,'FunctionsSearchBarEditField',handles.Import.functionsSearchBarEditField,...
    'ArgumentsSearchBarEditField',handles.Import.argumentsSearchBarEditField,'FunctionsUITree',handles.Import.functionsUITree,'ArgumentsUITree',handles.Import.argumentsUITree,'GroupFunctionDescriptionTextAreaLabel',handles.Import.groupFunctionDescriptionTextAreaLabel,...
    'GroupFunctionDescriptionTextArea',handles.Import.groupFunctionDescriptionTextArea,'UnarchiveImportFcnButton',handles.Import.unarchiveImportFcnButton,'ArgumentDescriptionTextAreaLabel',handles.Import.argumentDescriptionTextAreaLabel,...
    'ArgumentDescriptionTextArea',handles.Import.argumentDescriptionTextArea,'UnarchiveProjectButton',handles.Import.unarchiveProjectButton);

@importResize; % Run the importResize to set all components' positions to their correct positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
% 1. Analysis label
handles.Process.analysisLabel=uilabel(processTab,'Text','Analysis','Tag','AnalysisLabel','FontWeight','bold');

% 2. Analysis drop down
handles.Process.analysisDropDown=uidropdown(processTab,'Items',{'New Analysis'},'Tooltip','Select Analysis','Editable','off','Tag','SwitchAnalysisDropDown','ValueChangedFcn',@(switchAnalysisDropDown,event) switchAnalysisDropDownValueChanged(switchAnalysisDropDown));

% 3. New analysis button
handles.Process.newAnalysisButton=uibutton(processTab,'push','Text','+','Tag','NewAnalysisButton','Tooltip','Create New Analysis','ButtonPushedFcn',@(newAnalysisButton,event) newAnalysisButtonPushed(newAnalysisButton));

% 4. Archive analysis button
handles.Process.archiveAnalysisButton=uibutton(processTab,'push','Text','A+','Tag','ArchiveAnalysisButton','Tooltip','Archive Analysis','ButtonPushedFcn',@(archiveAnalysisButton,event) archiveAnalysisButtonPushed(archiveAnalysisButton));

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
handles.Process.archiveGroupButton=uibutton(processTab,'push','Text','AG','Tag','NewGroupButton','Tooltip','Archive Group','ButtonPushedFcn',@(archiveGroupButton,event) archiveGroupButtonPushed(archiveGroupButton));

% 13. Create new function button
handles.Process.newFunctionButton=uibutton(processTab,'push','Text','F+','Tag','NewFunctionButton','Tooltip','New Function','ButtonPushedFcn',@(newFunctionButton,event) newFunctionButtonPushed(newFunctionButton));

% 14. Archive function button
handles.Process.archiveFunctionButton=uibutton(processTab,'push','Text','AF','Tag','NewFunctionButton','Tooltip','Archive Function','ButtonPushedFcn',@(archiveFunctionButton,event) archiveFunctionButtonPushed(archiveFunctionButton));

% 15. Assign function to group button
handles.Process.functionToGroupButton=uibutton(processTab,'push','Text','F->G','Tag','FunctionToGroupButton','Tooltip','Assign Function to Group','ButtonPushedFcn',@(functionToGroupButton,event) functionToGroupButtonPushed(functionToGroupButton));

% 16. Unassign function from group button
handles.Process.functionFromGroupButton=uibutton(processTab,'push','Text','F<-G','Tag','FunctionFromGroupButton','Tooltip','Remove Function from Group','ButtonPushedFcn',@(functionFromGroupButton,event) functionFromGroupButtonPushed(functionFromGroupButton));

% 17. Reorder groups in this analysis button
handles.Process.reorderGroupsButton=uibutton(processTab,'push','Text','G Reorder','Tag','GroupReorderButton','Tooltip','Reorder Groups','ButtonPushedFcn',@(reorderGroupsButton,event) reorderGroupsButtonPushed(reorderGroupsButton));

% 18. Reorder functions in this group (in this analysis) button
handles.Process.reorderFunctionsButton=uibutton(processTab,'push','Text','F Reorder','Tag','FunctionReorderButton','Tooltip','Reorder Functions','ButtonPushedFcn',@(reorderFunctionsButton,event) reorderFunctionsButtonPushed(reorderFunctionsButton));

% 19. Create new argument button
handles.Process.newArgumentButton=uibutton(processTab,'push','Text','A+','Tag','NewArgumentButton','Tooltip','New Argument','ButtonPushedFcn',@(newArgumentButton,event) newArgumentButtonPushed(newArgumentButton));

% 20. Archive argument button
handles.Process.archiveArgumentButton=uibutton(processTab,'push','Text','A->A','Tag','ArchiveArgumentButton','Tooltip','Archive Argument','ButtonPushedFcn',@(archiveArgumentButton,event) archiveArgumentButtonPushed(archiveArgumentButton));

% 21. Add argument to function as input button
handles.Process.addInputArgumentButton=uibutton(processTab,'push','Text','I+','Tag','AddInputArgumentButton','Tooltip','Add Input Argument','ButtonPushedFcn',@(addInputArgumentButton,event) addInputArgumentButtonPushed(addInputArgumentButton));

% 22. Add argument to function as output button
handles.Process.addOutputArgumentButton=uibutton(processTab,'push','Text','O+','Tag','AddOutputArgumentButton','Tooltip','Add Output Argument','ButtonPushedFcn',@(addOutputArgumentButton,event) addOutputArgumentButtonPushed(addOutputArgumentButton));

% 23. Unassign argument from function
handles.Process.removeArgumentButton=uibutton(processTab,'push','Text','A-','Tag','RemoveArgumentButton','Tooltip','Remove Argument','ButtonPushedFcn',@(removeArgumentButton,event) removeArgumentButtonPushed(removeArgumentButton));

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
handles.Process.analysisDescriptionButton=uibutton(processTab,'push','Text','Description','Tag','AnalysisDescriptionButton','Tooltip','Current Analysis Description','ButtonPushedFcn',@(analysisDescriptionButton,event) analysisDescriptionButtonPushed(analysisDescriptionButton));

% 31. Generate analysis Run Code button
handles.Process.genRunCodeButton=uibutton(processTab,'push','Text',{'Generate','Run Code'},'Tag','GenRunCodeButton','Tooltip','Generate Run Code for Current Analysis','ButtonPushedFcn',@(genRunCodeButton,event) genRunCodeButtonPushed(genRunCodeButton));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
handles.Plot.rootSavePlotPathField=uieditfield(plotTab,'text','Value','Root Folder to Save Plots','Tag','RootSavePlotPathField');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the stats tab
% handles.Plot.rootSavePlotPathField=uieditfield(plotTab,'text','Value','Root Folder to Save Plots','Tag','RootSavePlotPathField');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the settings tab
% handles.Plot.rootSavePlotPathField=uieditfield(plotTab,'text','Value','Root Folder to Save Plots','Tag','RootSavePlotPathField');

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