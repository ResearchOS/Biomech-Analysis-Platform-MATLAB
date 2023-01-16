function [handles]=initializeComponents(fig)

%% PURPOSE: CREATE ALL OF THE COMPONENTS THAT ARE ON THE PGUI FIGURE
% fig=fig.handle; % The handle to the PGUI figure
handles=getappdata(fig,'handles'); % The handle to all components in the PGUI figure

defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',[defaultPos(1:2) defaultPos(3)*2 defaultPos(4)]); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off','SelectionChangedFcn',@(tabGroup1,event) tabGroup1SelectionChanged(tabGroup1),'Tag','TabGroup'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
projectsTab=uitab(tabGroup1,'Title','Projects','Tag','Projects','AutoResizeChildren','off','SizeChangedFcn',@projectsResize); % Create the projects tab
importTab=uitab(tabGroup1,'Title','Import','Tag','Import','AutoResizeChildren','off','SizeChangedFcn',@importResize); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','Tag','Process','AutoResizeChildren','off','SizeChangedFcn',@processResize); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','Tag','Plot','AutoResizeChildren','off','SizeChangedFcn',@plotResize); % Create the plot tab
statsTab=uitab(tabGroup1,'Title','Stats','Tag','Stats','AutoResizeChildren','off','SizeChangedFcn',@statsResize); % Create the stats tab
settingsTab=uitab(tabGroup1,'Title','Settings','Tag','Settings','AutoResizeChildren','off','SizeChangedFcn',@settingsResize); % Create the settings tab
handles.Tabs.tabGroup1=tabGroup1;

% Store handles to individual tabs.
handles.Projects.Tab=projectsTab;
handles.Import.Tab=importTab;
handles.Process.Tab=processTab;
handles.Plot.Tab=plotTab;
handles.Stats.Tab=statsTab;
handles.Settings.Tab=settingsTab;

setappdata(fig,'handles',handles);

sortOptions={'DateModified (New->Old)','DateCreated (New->Old)','Alphabetical (A->Z)'};
sortOptions=sort(sortOptions); % Alphabetical order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the projects tab.
% 1. The project name label
handles.Projects.projectsLabel=uilabel(projectsTab,'Text','Projects','Tag','ProjectsLabel','FontWeight','bold');

% 2. Add new project button
handles.Projects.addProjectButton=uibutton(projectsTab,'push','Text','P+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@(addProjectButton,event) addProjectButtonPushed(addProjectButton));

% 3. Remove project button
handles.Projects.removeProjectButton=uibutton(projectsTab,'push','Text','P-','Tag','RemoveProjectButton','Tooltip','Remove current project from the list','ButtonPushedFcn',@(removeProjectButton,event) removeProjectButtonPushed(removeProjectButton));

% 4. Sort projects dropdown
handles.Projects.sortProjectsDropDown=uidropdown(projectsTab,'Editable','off','Items',sortOptions,'Tooltip','Sort Projects','Tag','SortProjectsDropDown','Value',sortOptions{1},'ValueChangedFcn',@(sortProjectsDropDown,event) sortProjectsDropDownValueChanged(sortProjectsDropDown));

% 5. All projects UI tree
handles.Projects.allProjectsUITree=uitree(projectsTab,'checkbox','SelectionChangedFcn',@(allProjectsUITree,event) allProjectsUITreeSelectionChanged(allProjectsUITree),'CheckedNodesChangedFcn',@(allProjectsUITree,event) allProjectsUITreeCheckedNodesChanged(allProjectsUITree));

% 6. Load project snapshot button (settings & code only, not data)
handles.Projects.loadSnapshotButton=uibutton(projectsTab,'push','Text','Load Snapshot','Tag','LoadSnapshotButton','Tooltip','Load Previously Saved Snapshot of the Current Project','ButtonPushedFcn',@(loadSnapshotButton,event) loadSnapshotButtonPushed(loadSnapshotButton));

% 7. Save project snapshot button (settings & code only, not data)
handles.Projects.saveSnapshotButton=uibutton(projectsTab,'push','Text','Save Snapshot','Tag','SaveSnapshotButton','Tooltip','Save Snapshot of the Current Project','ButtonPushedFcn',@(saveSnapshotButton,event) saveSnapshotButtonPushed(saveSnapshotButton));

% 8. Project data path button
handles.Projects.dataPathButton=uibutton(projectsTab,'push','Tooltip','Select Data Path','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',@(dataPathButton,event) dataPathButtonPushed(dataPathButton));

% 9. Project data path edit field
handles.Projects.dataPathField=uieditfield(projectsTab,'text','Value','Data Path (contains ''Raw Data Files'' folder)','Tag','DataPathField','ValueChangedFcn',@(dataPathField,event) dataPathFieldValueChanged(dataPathField)); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 10. Open data path button
handles.Projects.openDataPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',@(openDataPathButton,event) openDataPathButtonPushed(openDataPathButton));

% 11. Project folder path button (contains everything related to the current project)
handles.Projects.projectPathButton=uibutton(projectsTab,'push','Tooltip','Select Project Folder Path','Text','Project Path','Tag','ProjectPathButton','ButtonPushedFcn',@(projectPathButton,event) projectPathButtonPushed(projectPathButton));

% 12. Project folder path edit field
handles.Projects.projectPathField=uieditfield(projectsTab,'text','Value','Path to Project Folder','Tag','ProjectPathField','ValueChangedFcn',@(projectPathField,event) projectPathFieldValueChanged(projectPathField)); % Code path name edit field (to the folder containing all code for this project).

% 13. Open project path button
handles.Projects.openProjectPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenProjectPathButton','Tooltip','Open project folder','ButtonPushedFcn',@(openProjectPathButton,event) openProjectPathButtonPushed(openProjectPathButton));

% 14. Projects search field
handles.Projects.searchField=uieditfield(projectsTab,'text','Value','Search','Tag','SearchField','ValueChangingFcn',@(searchField,event) projectsSearchFieldValueChanging(searchField));

% 15. Current project button
handles.Projects.currentProjectButton=uibutton(projectsTab,'push','Tooltip','Select current project','Text','Select','ButtonPushedFcn',@(currentProjectButton,event) currentProjectButtonPushed(currentProjectButton));

% 14. Create project archive button (settings, code, & data)
% handles.Projects.createProjectArchiveButton=uibutton(projectsTab,'Text','Save Archive','Tag','ArchiveButton','ButtonPushedFcn',@(archiveButton,event) archiveButtonPushed(archiveButton));

% 15. Load project archive button (settings, code, & data)
% handles.Projects.loadProjectArchiveButton=uibutton(projectsTab,'Text','Load Archive','Tag','LoadArchiveButton','ButtonPushedFcn',@(loadArchiveButton,event) loadArchiveButtonPushed(loadArchiveButton));

setappdata(fig,'handles',handles);
projectsResize(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
% 1. Logsheets label
handles.Import.logsheetsLabel=uilabel(importTab,'Text','Logsheets','FontWeight','bold');

% 2. Create new logsheet button
handles.Import.addLogsheetButton=uibutton(importTab,'push','Text','L+','ButtonPushedFcn',@(addLogsheetButton,event) addLogsheetButtonPushed(addLogsheetButton));

% 3. Remove logsheet button
handles.Import.removeLogsheetButton=uibutton(importTab,'push','Text','L-','ButtonPushedFcn',@(removeLogsheetButton,event) removeLogsheetButtonPushed(removeLogsheetButton));

% 4. Sort logsheets dropdown
handles.Import.sortLogsheetsDropDown=uidropdown(importTab,'Editable','off','Items',sortOptions','Value',sortOptions{1},'ValueChangedFcn',@(sortLogsheetsDropDown,event) sortLogsheetsDropDownValueChanged(sortLogsheetsDropDown));

% 5. All logsheets UI tree
handles.Import.allLogsheetsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(allLogsheetsUITree,event) allLogsheetsUITreeSelectionChanged(allLogsheetsUITree),'CheckedNodesChangedFcn',@(allLogsheetsUITree,event) allLogsheetsUITreeCheckedNodesChanged(allLogsheetsUITree));

% 6. Logsheet search field
handles.Import.searchField=uieditfield(importTab,'Value','Search','ValueChangingFcn',@(searchField,event) importSearchFieldValueChanging(searchField));

% 7. Logsheet path field
handles.Import.logsheetPathField=uieditfield(importTab,'Value','Enter Logsheet Path','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));

% 8. Logsheet path button
handles.Import.logsheetPathButton=uibutton(importTab,'push','Text','Set Logsheet Path','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));

% 9. Open logsheet path button
handles.Import.openLogsheetPathButton=uibutton(importTab,'push','Text','O','ButtonPushedFcn',@(openLogsheetPathButton,event) openLogsheetPathButtonPushed(openLogsheetPathButton));

% 10. Number of header rows label
handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# Header Rows','FontWeight','bold');

% 11. Number of header rows numeric edit field
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Value',-1,'ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));

% 12. Subject codename label
handles.Import.subjectCodenameLabel=uilabel(importTab,'Text','Subject Codename','FontWeight','bold');

% 13. Subject codename edit field
handles.Import.subjectCodenameDropDown=uidropdown(importTab,'Items',{''},'ValueChangedFcn',@(subjectCodenameDropDown,event) subjectCodenameDropDownValueChanged(subjectCodenameDropDown));

% 14. Target trial ID label
handles.Import.targetTrialIDLabel=uilabel(importTab,'Text','Target Trial ID','FontWeight','bold');

% 15. Target trial ID edit field
handles.Import.targetTrialIDDropDown=uidropdown(importTab,'Items',{''},'ValueChangedFcn',@(targetTrialIDDropDown,event) targetTrialIDDropDownValueChanged(targetTrialIDDropDown));

% 16. Data type-specific trial ID label (optional if only one data type)

% 17. Data type-specific trial ID edit field (optional if only one data type)

% 18. Specify trials label
handles.Import.specifyTrialsLabel=uilabel(importTab,'Text','Specify Trials','FontWeight','bold');

% 19. Specify trials button
handles.Import.specifyTrialsButton=uibutton(importTab,'Text','Specify Trials','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushed(specifyTrialsButton));

% 20. Header variables UI tree
handles.Import.headersUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(headersUITree,event) headersUITreeSelectionChanged(headersUITree));

% 21. Levels drop down
handles.Import.levelDropDown=uidropdown(importTab,'Items',{'','Subject','Trial'},'Value','','ValueChangedFcn',@(levelDropDown,event) levelDropDownValueChanged(levelDropDown));

% 22. Type drop down
handles.Import.typeDropDown=uidropdown(importTab,'Items',{'','Double','Char'},'Value','','ValueChangedFcn',@(typeDropDown,event) typeDropDownValueChanged(typeDropDown));

% 23. Check all button
handles.Import.checkAllButton=uibutton(importTab,'Text','Check All','ButtonPushedFcn',@(checkAllButton,event) checkAllButtonPushed(checkAllButton));

% 24. Uncheck all button
handles.Import.uncheckAllButton=uibutton(importTab,'Text','Uncheck All','ButtonPushedFcn',@(uncheckAllButton,event) uncheckAllButtonPushed(uncheckAllButton));

% 25. Run logsheet button
handles.Import.runLogsheetButton=uibutton(importTab,'Text','Run','ButtonPushedFcn',@(runLogsheetButton,event) runLogsheetButtonPushed(runLogsheetButton));

setappdata(fig,'handles',handles);
importResize(fig);


% 1. The button to open the logsheet path file picker
% handles.Import.logsheetPathButton=uibutton(importTab,'push','Tooltip','Select Logsheet Path','Text','Path','Tag','LogsheetPathButton','ButtonPushedFcn',@(logsheetPathButton,event) logsheetPathButtonPushed(logsheetPathButton));
% 
% % 2. The text edit field for the logsheet path
% handles.Import.logsheetPathField=uieditfield(importTab,'text','Value','Logsheet Path (ends in .xlsx)','Tag','LogsheetPathField','ValueChangedFcn',@(logsheetPathField,event) logsheetPathFieldValueChanged(logsheetPathField));
% 
% % 3. Logsheet label
% handles.Import.logsheetLabel=uilabel(importTab,'Text','Logsheet:','FontWeight','bold','Tag','LogsheetLabel');
% 
% % 4. Number of header rows label
% handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# of Header Rows','Tag','NumHeaderRowsLabel','Tooltip','Number of Header Rows in Logsheet');
% 
% % 5. Number of header rows text box
% handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Tooltip','Number of Header Rows in Logsheet','Value',-1,'Tag','NumHeaderRowsField','ValueChangedFcn',@(numHeaderRowsField,event) numHeaderRowsFieldValueChanged(numHeaderRowsField));
% 
% % 6. Subject ID column header label
% handles.Import.subjIDColHeaderLabel=uilabel(importTab,'Text','Subject ID Column Header','Tag','SubjectIDColumnHeaderLabel','Tooltip','Logsheet Column Header for Subject Codenames');
% 
% % 7. Subject ID column header text box
% handles.Import.subjIDColHeaderField=uieditfield(importTab,'text','Value','Subject ID Column Header','Tooltip','Logsheet Column Header for Subject Codenames','Tag','SubjIDColumnHeaderField','ValueChangedFcn',@(subjIDColHeaderField,event) subjIDColHeaderFieldValueChanged(subjIDColHeaderField));
% 
% % 8. Trial ID column header label
% handles.Import.trialIDColHeaderDataTypeLabel=uilabel(importTab,'Text','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','TrialIDColHeaderDataTypeLabel');
% 
% % 9. Trial ID column header text box
% handles.Import.trialIDColHeaderDataTypeField=uieditfield(importTab,'text','Value','Data Type: Trial ID Column Header','Tooltip','Logsheet Column Header for Data Type-Specific File Names','Tag','DataTypeTrialIDColumnHeaderField','ValueChangedFcn',@(trialIDColHeaderField,event) trialIDColHeaderDataTypeFieldValueChanged(trialIDColHeaderField));
% 
% % 10. Target Trial ID column header label
% handles.Import.targetTrialIDColHeaderLabel=uilabel(importTab,'Text','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderLabel','Tooltip','Logsheet Column Header for projectStruct Trial Names');
% 
% % 11. Target Trial ID column header field
% handles.Import.targetTrialIDColHeaderField=uieditfield(importTab,'text','Value','Target Trial ID Column Header','Tag','TargetTrialIDColHeaderField','Tooltip','Logsheet Column Header for projectStruct Trial Names','ValueChangedFcn',@(targetTrialIDFormatField,event) targetTrialIDFormatFieldValueChanged(targetTrialIDFormatField));
% 
% % 12. Open logsheet button
% handles.Import.openLogsheetButton=uibutton(importTab,'push','Text','O','Tag','OpenLogsheetButton','Tooltip','Open logsheet','ButtonPushedFcn',@(openLogsheetButton,event) openLogsheetButtonPushed(openLogsheetButton));
% 
% % 13.  Logsheet variables UI tree
% handles.Import.logVarsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@(logVarsUITree,event) logVarsUITreeSelectionChanged(logVarsUITree),'CheckedNodesChangedFcn',@(logVarsUITree,event) logVarsUITreeCheckedNodesChanged(logVarsUITree),'Tag','LogVarsUITree');
% 
% % 14. Data type label
% handles.Import.dataTypeLabel=uilabel(importTab,'Text','Data Type','Tag','DataTypeLabel');
% 
% % 15. Data type dropdown
% handles.Import.dataTypeDropDown=uidropdown(importTab,'Items',{'','char','double'},'Tooltip','Data Type of Logsheet Variable','Editable','off','Tag','DataTypeDropDown','ValueChangedFcn',@(dataTypeDropDown,event) dataTypeDropDownValueChanged(dataTypeDropDown));
% 
% % 16. Trial/subject dropdown
% handles.Import.trialSubjectDropDown=uidropdown(importTab,'Items',{'','Trial','Subject'},'Tooltip','Variable is Trial or Subject Level','Editable','off','Tag','TrialSubjectDropDown','ValueChangedFcn',@(trialSubjectDropDown,event) trialSubjectDropDownValueChanged(trialSubjectDropDown));
% 
% % 17. Variable search field
% handles.Import.varSearchField=uieditfield(importTab,'text','Value','Search','Tag','VarSearchField','ValueChangedFcn',@(varSearchField,event) varSearchFieldValueChanged(varSearchField));
% 
% % 18. Import data from the logsheet button
% handles.Import.runLogImportButton=uibutton(importTab,'push','Text','Run Logsheet Import','Tag','RunLogImportButton','Tooltip','Import logsheet data','ButtonPushedFcn',@(runLogImportButton,event) runLogImportButtonPushed(runLogImportButton));
% 
% % 19. Import function drop down (for data type-specific column headers)
% handles.Import.importFcnDropDown=uidropdown(importTab,'Items',{'New Import Fcn'},'Editable','off','Tag','ImportFcnDropDown','ValueChangedFcn',@(importFcnDropDown,event) importFcnDropDownValueChanged(importFcnDropDown));
% 
% % 20. Check all in log headers UI tree button
% handles.Import.checkAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Check all','Tag','CheckAllLogVarsUITreeButton','Tooltip','Check all columns','ButtonPushedFcn',@(checkAllLogVarsUITreeButton,event) checkAllLogVarsUITreeButtonPushed(checkAllLogVarsUITreeButton));
% 
% % 21. Uncheck all in log headers UI tree button
% handles.Import.uncheckAllLogVarsUITreeButton=uibutton(importTab,'push','Text','Uncheck all','Tag','UncheckAllLogVarsUITreeButton','Tooltip','Uncheck all columns','ButtonPushedFcn',@(uncheckAllLogVarsUITreeButton,event) uncheckAllLogVarsUITreeButtonPushed(uncheckAllLogVarsUITreeButton));
% 
% % 22. Specify trials button
% handles.Import.specifyTrialsButton=uibutton(importTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Create or Modify Specify Trials','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));
% 
% importTab.UserData=struct('LogsheetPathButton',handles.Import.logsheetPathButton,'LogsheetPathField',handles.Import.logsheetPathField,'LogsheetLabel',handles.Import.logsheetLabel,...
%     'NumHeaderRowsLabel',handles.Import.numHeaderRowsLabel,'NumHeaderRowsField',handles.Import.numHeaderRowsField,'SubjectIDColHeaderLabel',handles.Import.subjIDColHeaderLabel,'SubjectIDColHeaderField',handles.Import.subjIDColHeaderField,...
%     'TrialIDColHeaderDataTypeLabel',handles.Import.trialIDColHeaderDataTypeLabel,'TrialIDColHeaderDataTypeField',handles.Import.trialIDColHeaderDataTypeField,'TargetTrialIDColHeaderLabel',handles.Import.targetTrialIDColHeaderLabel,...
%     'TargetTrialIDColHeaderField',handles.Import.targetTrialIDColHeaderField,'OpenLogsheetButton',handles.Import.openLogsheetButton,'LogVarsUITree',handles.Import.logVarsUITree,...
%     'DataTypeLabel',handles.Import.dataTypeLabel,'DataTypeDropDown',handles.Import.dataTypeDropDown,'TrialSubjectDropDown',handles.Import.trialSubjectDropDown,...
%     'VarSearchField',handles.Import.varSearchField,'RunLogImportButton',handles.Import.runLogImportButton,...
%     'ImportFcnDropDown',handles.Import.importFcnDropDown,'CheckAllLogVarsUITreeButton',handles.Import.checkAllLogVarsUITreeButton,'UncheckAllLogVarsUITreeButton',handles.Import.uncheckAllLogVarsUITreeButton,...
%     'SpecifyTrialsButton',handles.Import.specifyTrialsButton);

% @importResize; % Run the importResize to set all components' positions to their correct positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the process tab.
% 1. Variables/function/groups subtab
handles.Process.subTabAll=uitabgroup(processTab,'AutoResizeChildren','off');

% 2. Variables tab
handles.Process.variablesTab=uitab(handles.Process.subTabAll,'Title','Variables','AutoResizeChildren','off');

% 3. Functions tab
handles.Process.functionsTab=uitab(handles.Process.subTabAll,'Title','Functions','AutoResizeChildren','off');

% 4. Groups tab
handles.Process.groupsTab=uitab(handles.Process.subTabAll,'Title','Groups','AutoResizeChildren','off');

% 1. Variables label
% handles.Process.variablesLabel=uilabel(handles.Process.variablesTab,'Text','Variables','FontWeight','bold');

% 2. Add variable button
handles.Process.addVariableButton=uibutton(handles.Process.variablesTab,'text','V+','ButtonPushedFcn',@(addVariableButton,event) addVariableButtonPushed(addVariableButton));

% 3. Remove variable button
handles.Process.removeVariableButton=uibutton(handles.Process.variablesTab,'text','V-','ButtonPushedFcn',@(removeVariableButton,event) removeVariableButtonPushed(removeVariableButton));

% 4. Sort variables drop down
handles.Process.sortVariablesDropDown=uidropdown(handles.Process.variablesTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortVariablesDropDown,event) sortVariablesDropDownValueChanged(sortVariablesDropDown));

% 5. All variables UI tree
handles.Process.allVariablesUITree=uitree(handles.Process.variablesTab,'checkbox','SelectionChangedFcn',@(allVariablesUITree,event) allVariablesUITreeSelectionChanged(allVariablesUITree));

% 6. Variables search field
handles.Process.variablesSearchField=uieditfield(handles.Process.variablesTab,'Value','Search','ValueChangingFcn',@(variablesSearchField,event) variablesSearchFieldValueChanging(variablesSearchField));

% 7. Functions label
% handles.Process.processLabel=uilabel(handles.Process.functionsTab,'Text','Functions','FontWeight','bold');

% 8. Add function button
handles.Process.addProcessButton=uibutton(handles.Process.functionsTab,'text','F+','ButtonPushedFcn',@(addProcessButton,event) addProcessButtonPushed(addProcessButton));

% 9. Remove function button
handles.Process.removeProcessButton=uibutton(handles.Process.functionsTab,'text','F-','ButtonPushedFcn',@(removeProcessButton,event) removeProcessButtonPsuhed(removeProcessButton));

% 10. Sort functions drop down
handles.Process.sortProcessDropDown=uidropdown(handles.Process.functionsTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortFunctionsDropDown,event) sortProcessDropDownValueChanged(sortFunctionsDropDown));

% 11. All functions UI tree
handles.Process.allProcessUITree=uitree(handles.Process.functionsTab,'checkbox','SelectionChangedFcn',@(allFunctionsUITree,event) allProcessUITreeSelectionChanged(allFunctionsUITree));

% 12. Functions search field
handles.Process.processSearchField=uieditfield(handles.Process.functionsTab,'Value','Search','ValueChangingFcn',@(functionsSearchField,event) processSearchFieldValueChanging(functionsSearchField));

% 13. Assign variable button
handles.Process.assignVariableButton=uibutton(handles.Process.variablesTab,'Text','->','Visible','off','ButtonPushedFcn',@(assignVariableButton,event) assignVariableButtonPushed(assignVariableButton));

% 14. Unassign variable button
handles.Process.unassignVariableButton=uibutton(handles.Process.variablesTab,'Text','<-','Visible','off','ButtonPushedFcn',@(unassignVariableButton,event) unassignVariableButtonPushed(unassignVariableButton));

% 15. Assign function button
handles.Process.assignFunctionButton=uibutton(handles.Process.functionsTab,'Text','->','Visible','on','ButtonPushedFcn',@(assignFunctionButton,event) assignFunctionButtonPushed(assignFunctionButton));

% 16. Unassign function button
handles.Process.unassignFunctionButton=uibutton(handles.Process.functionsTab,'Text','<-','Visible','on','ButtonPushedFcn',@(unassignFunctionButton,event) unassignFunctionButtonPushed(unassignFunctionButton));

% 13. Add group button
handles.Process.addGroupButton=uibutton(handles.Process.groupsTab,'Text','G+','ButtonPushedFcn',@(addGroupButton,event) addGroupButtonPushed(addGroupButton));

% 14. Remove group button
handles.Process.removeGroupButton=uibutton(handles.Process.groupsTab,'Text','G-','ButtonPushedFcn',@(removeGroupButton,event) removeGroupButtonPushed(removeGroupButton));

% 15. Sort group drop down
handles.Process.sortGroupsDropDown=uidropdown(handles.Process.groupsTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortGroupsDropDown,event) sortGroupsDropDownValueChanged(sortGroupsDropDown));

% 16. All groups UI tree
handles.Process.allGroupsUITree=uitree(handles.Process.groupsTab,'checkbox','SelectionChangedFcn',@(allGroupsUITree,event) allGroupsUITreeSelectionChanged(allGroupsUITree));

% 17. Groups search field
handles.Process.groupsSearchField=uieditfield(handles.Process.groupsTab,'Value','Search','ValueChangingFcn',@(groupsSearchField,event) groupsSearchFieldValueChanging(groupsSearchField));

% 18. Assign group button
handles.Process.assignGroupButton=uibutton(handles.Process.groupsTab,'Text','->','Visible','on','ButtonPushedFcn',@(assignGroupButton,event) assignGroupButtonPushed(assignGroupButton));

% 19. Unassign group button
handles.Process.unassignGroupButton=uibutton(handles.Process.groupsTab,'Text','<-','Visible','on','ButtonPushedFcn',@(unassignGroupButton,event) unassignGroupButtonPushed(unassignGroupButton));

% 18. Queue UI tree
handles.Process.queueUITree=uitree(processTab,'checkbox');

% 19. Queue label
handles.Process.queueLabel=uilabel(processTab,'FontWeight','bold','Text','Queue');

% 22. Current group/function tab group
handles.Process.subtabCurrent=uitabgroup(processTab,'AutoResizeChildren','off','SelectionChangedFcn',@(subTabCurrent,event) subTabCurrentSelectionChanged(subTabCurrent));

% 23. Current group tab
handles.Process.currentGroupTab=uitab(handles.Process.subtabCurrent,'Title','Group','AutoResizeChildren','off');

% 24. Current function tab
handles.Process.currentFunctionTab=uitab(handles.Process.subtabCurrent,'Title','Function','AutoResizeChildren','off');

% 25. Run button
handles.Process.runButton=uibutton(processTab,'push','Text','Run','ButtonPushedFcn',@(runButton,event) runButtonPushed(runButton));

% 26. Current group UI tree
handles.Process.groupUITree=uitree(handles.Process.currentGroupTab,'checkbox','SelectionChangedFcn',@(groupUITree,event) groupUITreeSelectionChanged(groupUITree));

% 27. Current function UI tree
handles.Process.functionUITree=uitree(handles.Process.currentFunctionTab,'checkbox','SelectionChangedFcn',@(functionUITree,event) functionUITreeSelectionChanged(functionUITree));

% 20. Add to queue button
handles.Process.addToQueueButton=uibutton(handles.Process.currentGroupTab,'push','Text','->','ButtonPushedFcn',@(addToQueueButton,event) addToQueueButtonPushed(addToQueueButton));

% 21. Remove from queue button
handles.Process.removeFromQueueButton=uibutton(handles.Process.currentGroupTab,'push','Text','<-','ButtonPushedFcn',@(removeFromQueueButton,event) removeFromQueueButtonPushed(removeFromQueueButton));

% 30. Save as new group button
handles.Process.saveAsNewGroupButton=uibutton(handles.Process.currentGroupTab,'push','Text',{'Save As','New Group'},'ButtonPushedFcn',@(saveAsNewGroupButton,event) saveAsNewGroupButtonPushed(saveAsNewGroupButton));

% 31. Select group button
handles.Process.selectGroupButton=uibutton(handles.Process.groupsTab,'push','Text','Sel','ButtonPushedFcn',@(selectGroupButton,event) selectGroupButtonPushed(selectGroupButton));

% 32. Current group label
handles.Process.currentGroupLabel=uilabel(handles.Process.currentGroupTab,'Text','Current Group','FontWeight','bold');

% 33. Add getArg/setArg button
handles.Process.addArgsButton=uibutton(handles.Process.currentFunctionTab,'Text','+','ButtonPushedFcn',@(addArgsButton,event) addArgsButtonPushed(addArgsButton));

% 34. Remove getArg/setArg button
handles.Process.removeArgsButton=uibutton(handles.Process.currentFunctionTab,'Text','-','ButtonPushedFcn',@(removeArgsButton,event) removeArgsButtonPushed(removeArgsButton));

handles.Process.subtabCurrent.SelectedTab=handles.Process.currentGroupTab;
setappdata(fig,'handles',handles);
processResize(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
% 1. Plot label
handles.Plot.plotLabel=uilabel(plotTab,'Text','Plots','FontWeight','bold');

% 2. Add plot button
handles.Plot.addPlotButton=uibutton(plotTab,'Text','P+','ButtonPushedFcn',@(addPlotButton,event) addPlotButtonPushed(addPlotButton));

% 3. Remove plot button
handles.Plot.removePlotButton=uibutton(plotTab,'Text','P-','ButtonPushedFcn',@(removePlotButton,event) removePlotButtonPushed(removePlotButton));

% 4. Sort plots drop down
handles.Plot.sortPlotsDropDown=uidropdown(plotTab,'Items',sortOptions,'ValueChangedFcn',@(sortPlotDropDown,event) sortPlotDropDownValueChanged(sortPlotDropDown));

% 5. All plots UI tree
handles.Plot.allPlotsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(allPlotsUITree,event) allPlotsUITreeSelectionChanged(allPlotsUITree));

% 6. Plots search field
handles.Plot.plotSearchField=uieditfield(plotTab,'Value','Search','ValueChangingFcn',@(plotSearchField,event) plotSearchFieldValueChanging(plotSearchField));

% 7. Component label
handles.Plot.componentLabel=uilabel(plotTab,'Text','Components','FontWeight','bold');

% 8. Add component button
handles.Plot.addComponentButton=uibutton(plotTab,'Text','C+','ButtonPushedFcn',@(addComponentButton,event) addComponentButtonPushed(addComponentButton));

% 9. Remove component button
handles.Plot.removeComponentButton=uibutton(plotTab,'Text','C-','ButtonPushedFcn',@(removeComponentButton,event) removeComponentButtonPushed(removeComponentButton));

% 10. Sort components drop down
handles.Plot.sortComponentsDropDown=uidropdown(plotTab,'Items',sortOptions,'ValueChangedFcn',@(sortComponentDropDown,event) sortComponentDropDownValueChanged(sortComponentDropDown));

% 11. All components UI tree
handles.Plot.allComponentsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(allComponentsUITree,event) allComponentsUITreeSelectionCHanged(allComponentsUITree));

% 12. Components search field
handles.Plot.componentSearchField=uieditfield(plotTab,'Value','Search','ValueChangingFcn',@(componentSearchField,event) componentSearchFieldValueChanging(componentSearchField));

setappdata(fig,'handles',handles);
plotResize(fig);

% % 1. Search bar for all components browser
% handles.Plot.allComponentsSearchField=uieditfield(plotTab,'text','Value','Search','Tag','AllComponentsSearchField','ValueChangingFcn',@(allComponentsSearchField,event) allComponentsSearchFieldValueChanged(allComponentsSearchField));
% 
% % 2. All components UI tree
% handles.Plot.allComponentsUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(allComponentsUITree,event) allComponentsUITreeSelectionChanged(allComponentsUITree),'CheckedNodesChangedFcn',@(allComponentsUITree,event) allComponentsUITreeCheckedNodesChanged(allComponentsUITree),'Tag','AllComponentsUITree');
% 
% % 3. Plot function selector
% handles.Plot.plotFcnSearchField=uieditfield(plotTab,'text','Value','Search','Tag','PlotFcnSearchField','ValueChangingFcn',@(plotFcnSearchField,event) plotFcnSearchFieldValueChanged(plotFcnSearchField));
% 
% % 4. Plot function UI tree
% handles.Plot.plotFcnUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(plotFcnUITree,event) plotFcnUITreeSelectionChanged(plotFcnUITree),'CheckedNodesChangedFcn',@(plotFcnUITree,event) plotFcnUITreeCheckedNodesChanged(plotFcnUITree),'Tag','PlotFcnUITree');
% 
% % 5. Assign variables button
% handles.Plot.assignVarsButton=uibutton(plotTab,'push','Text','Assign Vars','Tag','AssignVarsButton','Tooltip','Assign variables to the currently selected graphics object','ButtonPushedFcn',@(assignVarsButton,event) assignVarsButtonPushed(assignVarsButton));
% 
% % 6. Assign component button
% handles.Plot.assignComponentButton=uibutton(plotTab,'push','Text','->','Tag','AssignComponentButton','Tooltip','Assign graphics object to the currently selected function version','ButtonPushedFcn',@(assignComponentButton,event) assignComponentButtonPushed(assignComponentButton));
% 
% % 7. Unassign component button
% handles.Plot.unassignComponentButton=uibutton(plotTab,'push','Text','<-','Tag','UnassignComponentButton','Tooltip','Unassign graphics object from the currently selected function version','ButtonPushedFcn',@(unassignComponentButton,event) unassignComponentButtonPushed(unassignComponentButton));
% 
% % 8. Create new function button
% handles.Plot.createPlotButton=uibutton(plotTab,'push','Text','P+','Tag','CreateFcnButton','Tooltip','Create a new plot (collection of graphics objects)','ButtonPushedFcn',@(createPlotButton,event) createFcnButtonPushed(createPlotButton));
% 
% % 9. Current component UI tree
% handles.Plot.currCompUITree=uitree(plotTab,'checkbox','SelectionChangedFcn',@(currCompUITree,event) currCompUITreeSelectionChanged(currCompUITree),'CheckedNodesChangedFcn',@(currCompUITree,event) currCompUITreeCheckedNodesChanged(currCompUITree),'Tag','CurrComponentsUITree');
% 
% % 10. Current component description label
% handles.Plot.componentDescLabel=uilabel(plotTab,'Text','Component Desc','Tag','ComponentDescLabel','FontWeight','bold');
% 
% % 11. Current component description text area
% handles.Plot.componentDescTextArea=uitextarea(plotTab,'Value','Enter Component Description Here','Tag','ComponentDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(componentDescTextArea,event) componentDescTextAreaValueChanged(componentDescTextArea));
% 
% % 12. Function version description label
% handles.Plot.fcnVerDescLabel=uilabel(plotTab,'Text','Plot Desc','Tag','FcnVerDescLabel','FontWeight','bold');
% 
% % 13. Function version description text area
% handles.Plot.fcnVerDescTextArea=uitextarea(plotTab,'Value','Enter Fcn Version Description Here','Tag','FcnVerDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(fcnVerDescTextArea,event) fcnVerDescTextAreaValueChanged(fcnVerDescTextArea));
% 
% % 14. Specify trials button
% handles.Plot.specifyTrialsButton=uibutton(plotTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Set the trials to plot','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));
% 
% % 15. Run plot button
% handles.Plot.runPlotButton=uibutton(plotTab,'push','Text','Run Plot','Tag','RunPlotButton','Tooltip','Run the plot on the specified trials','ButtonPushedFcn',@(runPlotButton,event) runPlotButtonPushed(runPlotButton));
% 
% % 16. Plot level dropdown
% handles.Plot.plotLevelDropDown=uidropdown(plotTab,'Items',{'P','PC','C','S','SC','T'},'Tooltip','Specify the level to run this at','Editable','off','Tag','PlotLevelDropDown','ValueChangedFcn',@(plotLevelDropDown,event) plotLevelDropDownValueChanged(plotLevelDropDown));
% 
% % 17. All components label
% handles.Plot.allComponentsLabel=uilabel(plotTab,'Text','All Components','Tag','AllComponentsLabel','FontWeight','bold');
% 
% % 18. All functions label
% handles.Plot.allPlotsLabel=uilabel(plotTab,'Text','Plots','Tag','AllFunctionsLabel','FontWeight','bold');
% 
% % 19. Current components label
% handles.Plot.currComponentsLabel=uilabel(plotTab,'Text','Current Components','Tag','CurrComponentsLabel','FontWeight','bold');
% 
% % 20. Create new component button
% handles.Plot.createCompButton=uibutton(plotTab,'push','Text','C+','Tag','CreateCompButton','Tooltip','Create a new component','ButtonPushedFcn',@(createCompButton,event) createCompButtonPushed(createCompButton));
% 
% % 21. Delete component button
% handles.Plot.deleteCompButton=uibutton(plotTab,'push','Text','C-','Tag','DeleteCompButton','Tooltip','Delete a component','ButtonPushedFcn',@(deleteCompButton,event) deleteCompButtonPushed(deleteCompButton));
% 
% % 22. Delete plot button
% handles.Plot.deletePlotButton=uibutton(plotTab,'push','Text','P-','Tag','DeletePlotButton','Tooltip','Delete a plot','ButtonPushedFcn',@(deletePlotButton,event) deletePlotButtonPushed(deletePlotButton));
% 
% % 23. Edit component button
% handles.Plot.editCompButton=uibutton(plotTab,'push','Text','Edit Props','Tag','EditCompButton','Tooltip','Edit component','ButtonPushedFcn',@(editCompButton,event) editCompButtonPushed(editCompButton));
% 
% % 24. Plot panel
% handles.Plot.plotPanel=uipanel(plotTab,'AutoResizeChildren','off');
% 
% % 25. Movie checkbox
% handles.Plot.isMovieCheckbox=uicheckbox(plotTab,'Text','Movie','Value',0,'Tag','IsMovieCheckbox','Tooltip','Plots a movie one frame at a time','ValueChangedFcn',@(isMovieCheckbox,event) isMovieCheckboxButtonPushed(isMovieCheckbox));
% 
% % 26. Movie increment edit field
% handles.Plot.incEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','IncEditField','ValueChangedFcn',@(incEditField,event) incEditFieldValueChanged(incEditField));
% 
% % 27. Increment frame number up by inc
% handles.Plot.incFrameUpButton=uibutton(plotTab,'push','Text','->','Tag','IncFrameUpButton','Tooltip','Increment frame up','ButtonPushedFcn',@(incFrameUpButton,event) incFrameUpButtonPushed(incFrameUpButton));
% 
% % 28. Increment frame number down by inc
% handles.Plot.incFrameDownButton=uibutton(plotTab,'push','Text','<-','Tag','IncFrameDownButton','Tooltip','Increment frame down','ButtonPushedFcn',@(incFrameDownButton,event) incFrameDownButtonPushed(incFrameDownButton));
% 
% % 29. Button to set the start frame as a variable
% handles.Plot.startFrameButton=uibutton(plotTab,'push','Text','Start Frame','Tag','StartFrameButton','Tooltip','Set start frame based on a variable','ButtonPushedFcn',@(startFrameButton,event) startFrameButtonPushed(startFrameButton));
% 
% % 30. Button to set the end frame as a variable
% handles.Plot.endFrameButton=uibutton(plotTab,'push','Text','End Frame','Tag','EndFrameButton','Tooltip','Set end frame based on a variable','ButtonPushedFcn',@(endFrameButton,event) endFrameButtonPushed(endFrameButton));
% 
% % 31. Edit field to set the start frame hard-coded
% handles.Plot.startFrameEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','StartFrameEditField','ValueChangedFcn',@(startFrameEditField,event) startFrameEditFieldValueChanged(startFrameEditField));
% 
% % 32. Edit field to set the end frame hard-coded
% handles.Plot.endFrameEditField=uieditfield(plotTab,'numeric','Value',2,'Tag','EndFrameEditField','ValueChangedFcn',@(endFrameEditField,event) endFrameEditFieldValueChanged(endFrameEditField));
% 
% % 33. Edit field to set the current frame number
% handles.Plot.currFrameEditField=uieditfield(plotTab,'numeric','Value',1,'Tag','CurrFrameEditField','ValueChangedFcn',@(currFrameEditField,event) currFrameEditFieldValueChanged(currFrameEditField));
% 
% % 34. Current example trial label
% handles.Plot.exTrialLabel=uilabel(plotTab,'Text','','FontWeight','bold');
% 
% % 35. Context menu
% handles.Plot.openPlotFcnContextMenu=uicontextmenu(fig);
% handles.Plot.openPlotFcnContextMenuItem1=uimenu(handles.Plot.openPlotFcnContextMenu,'Text','Open Fcn','MenuSelectedFcn',{@openMFilePlot});
% handles.Plot.openPlotFcnContextMenuItem2=uimenu(handles.Plot.openPlotFcnContextMenu,'Text','Refresh All Subcomponents','MenuSelectedFcn',{@refreshAllSubComps});
% 
% % 36. Context menu
% handles.Plot.refreshComponentContextMenu=uicontextmenu(fig);
% handles.Plot.refreshComponentContextMenuItem1=uimenu(handles.Plot.refreshComponentContextMenu,'Text','Refresh Component','MenuSelectedFcn',{@refreshPlotComp});
% 
% % 37. Context menu
% handles.Plot.axesLetterContextMenu=uicontextmenu(fig);
% handles.Plot.axesLetterContextMenuItem1=uimenu(handles.Plot.axesLetterContextMenu,'Text','Refresh Component','MenuSelectedFcn',{@refreshPlotComp});
% handles.Plot.axesLetterContextMenuItem2=uimenu(handles.Plot.axesLetterContextMenu,'Text','Subplot','MenuSelectedFcn',{@adjustSubplot});
% 
% 
% plotTab.UserData=struct('AllComponentsSearchField',handles.Plot.allComponentsSearchField,'AllComponentsUITree',handles.Plot.allComponentsUITree,'PlotFcnSearchField',handles.Plot.plotFcnSearchField,...
%     'PlotFcnUITree',handles.Plot.plotFcnUITree,'AssignVarsButton',handles.Plot.assignVarsButton,'AssignComponentButton',handles.Plot.assignComponentButton,'UnassignComponentButton',handles.Plot.unassignComponentButton,'CreateFcnButton',handles.Plot.createPlotButton,...
%     'CurrComponentsUITree',handles.Plot.currCompUITree,'ComponentDescLabel',handles.Plot.componentDescLabel,'ComponentDescTextArea',handles.Plot.componentDescTextArea,'FcnVerDescLabel',handles.Plot.fcnVerDescLabel,...
%     'FcnVerDescTextArea',handles.Plot.fcnVerDescTextArea,'SpecifyTrialsButton',handles.Plot.specifyTrialsButton,'RunPlotButton',handles.Plot.runPlotButton,'PlotLevelDropDown',handles.Plot.plotLevelDropDown,...
%     'AllComponentsLabel',handles.Plot.allComponentsLabel,'AllFunctionsLabel',handles.Plot.allPlotsLabel,'CurrComponentsLabel',handles.Plot.currComponentsLabel,'CreateCompButton',handles.Plot.createCompButton,...
%     'DeleteCompButton',handles.Plot.deleteCompButton,'DeletePlotButton',handles.Plot.deletePlotButton,'EditCompButton',handles.Plot.editCompButton,'PlotPanel',handles.Plot.plotPanel,...
%     'IsMovieCheckbox',handles.Plot.isMovieCheckbox,'IncEditField',handles.Plot.incEditField,'IncFrameUpButton',handles.Plot.incFrameUpButton,'IncFrameDownButton',handles.Plot.incFrameDownButton,...
%     'StartFrameButton',handles.Plot.startFrameButton,'EndFrameButton',handles.Plot.endFrameButton,'StartFrameEditField',handles.Plot.startFrameEditField,'EndFrameEditField',handles.Plot.endFrameEditField,'CurrFrameEditField',handles.Plot.currFrameEditField,...
%     'ExTrialLabel',handles.Plot.exTrialLabel);
% 
% @plotResize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the stats tab
% 1. Variables UI Tree
handles.Stats.varsUITree=uitree(statsTab,'SelectionChangedFcn',@(varsUITree,event) varsUITreeSelectionChanged(varsUITree),'Tag','VarsUITree');

% 2. Create new table
handles.Stats.createTableButton=uibutton(statsTab,'push','Text','T+','Tag','CreateTableButton','Tooltip','Create new stats table','ButtonPushedFcn',@(createTableButton,event) createTableButtonPushed(createTableButton));

% 3. Remove table
handles.Stats.removeTableButton=uibutton(statsTab,'push','Text','T-','Tag','RemoveTableButton','Tooltip','Remove stats table','ButtonPushedFcn',@(removeTableButton,event) removeTableButtonPushed(removeTableButton));

% 4. Tables UI tree
handles.Stats.tablesUITree=uitree(statsTab,'SelectionChangedFcn',@(tablesUITree,event) tablesUITreeSelectionChanged(tablesUITree),'Tag','TablesUITree');

% 5. Specify trials button
handles.Stats.specifyTrialsButton=uibutton(statsTab,'push','Text','Specify Trials','Tag','SpecifyTrialsButton','Tooltip','Specify the trials','ButtonPushedFcn',@(specifyTrialsButton,event) specifyTrialsButtonPushedPopupWindow(specifyTrialsButton));

% 6. Add repetition variable button
handles.Stats.addRepsVarButton=uibutton(statsTab,'push','Text','R+','Tag','AddRepsVarButton','Tooltip','Add repetition variable','ButtonPushedFcn',@(addRepsVarButton,event) addRepsVarButtonPushed(addRepsVarButton));

% 7. Add variables button
handles.Stats.addVarsButton=uibutton(statsTab,'push','Text','V+','Tag','AddVarsButton','Tooltip','Add variable','ButtonPushedFcn',@(addVarsButton,event) addVarsButtonPushed(addVarsButton));

% 8. Remove variables button
handles.Stats.removeVarsButton=uibutton(statsTab,'push','Text','<=','Tag','RemoveVarsButton','Tooltip','Remove variable','ButtonPushedFcn',@(removeVarsButton,event) removeVarsButtonPushed(removeVarsButton));

% 9. Move var left/up button
handles.Stats.varUpButton=uibutton(statsTab,'push','Text',{'/\','||'},'Tag','VarUpButton','Tooltip','Move variable up/left','ButtonPushedFcn',@(varUpButton,event) varUpButtonPushed(varUpButton));

% 10. Move var right/down button
handles.Stats.varDownButton=uibutton(statsTab,'push','Text',{'||','\/'},'Tag','VarDownButton','Tooltip','Move variable down/right','ButtonPushedFcn',@(varDownButton,event) varDownButtonPushed(varDownButton));

% 11. Assigned variables UI tree
handles.Stats.assignedVarsUITree=uitree(statsTab,'SelectionChangedFcn',@(assignedVarsUITree,event) assignedVarsUITreeSelectionChanged(assignedVarsUITree),'Tag','AssignedVarsUITree');

% 12. Assign function to variable
handles.Stats.assignFcnButton=uibutton(statsTab,'push','Text','<=','Tag','AssignFcnButton','Tooltip','Assign function to variable','ButtonPushedFcn',@(assignFcnButton,event) assignFcnButtonPushed(assignFcnButton));

% 13. Unassign function from variable
handles.Stats.unassignFcnButton=uibutton(statsTab,'push','Text','=>','Tag','UnassignFcnButton','Tooltip','Unassign function from variable','ButtonPushedFcn',@(unassignFcnButton,event) unassignFcnButtonPushed(unassignFcnButton));

% 14. Create function button
handles.Stats.createFcnButton=uibutton(statsTab,'push','Text','F+','Tag','CreateFcnButton','Tooltip','Create new function','ButtonPushedFcn',@(createFcnButton,event) createStatsFcnButtonPushed(createFcnButton));

% 15. Remove function button
handles.Stats.removeFcnButton=uibutton(statsTab,'push','Text','F-','Tag','RemoveFcnButton','Tooltip','Remove function','ButtonPushedFcn',@(removeFcnButton,event) removeStatsFcnButtonPushed(removeFcnButton));

% 16. Functions UI tree
handles.Stats.fcnsUITree=uitree(statsTab,'SelectionChangedFcn',@(fcnsUITree,event) fcnsUITreeSelectionChanged(fcnsUITree),'Tag','FcnsUITree');

% 17. Run button
handles.Stats.runButton=uibutton(statsTab,'push','Text','Run','Tag','RunButton','Tooltip','Create the specified stats table','ButtonPushedFcn',@(runButton,event) runButtonPushed(runButton));

% 18. Assign vars button
handles.Stats.assignVarsButton=uibutton(statsTab,'push','Text',{'Assign','Vars'},'Tag','AssignVarsButton','Tooltip','Assign additional variables to this function','ButtonPushedFcn',@(assignVarsButton,event) assignStatsVarsButtonPushed(assignVarsButton));

% 19. Variable description label
handles.Stats.varsDescLabel=uilabel(statsTab,'Text','Vars Description','FontWeight','bold');

% 20. Variable description text area
handles.Stats.varsDescTextArea=uitextarea(statsTab,'Value','Enter Var Description Here','Tag','VarsDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(varsDescTextArea,event) varsDescTextAreaValueChanged(varsDescTextArea));

% 21. Table description label
handles.Stats.tableDescLabel=uilabel(statsTab,'Text','Table Description','FontWeight','bold');

% 22. Table description text area
handles.Stats.tableDescTextArea=uitextarea(statsTab,'Value','Enter Table Description Here','Tag','TableDescTextArea','Editable','on','Visible','on','ValueChangedFcn',@(tableDescTextArea,event) tableDescTextAreaValueChanged(tableDescTextArea));

% 23. Convert stats table to MATLAB matrix button
% handles.Stats.matrixButton=uibutton(statsTab,'push','Text','Matrix','Tag','MatrixButton','Tooltip','Convert the pre-made stats table to a MATLAB matrix','ButtonPushedFcn',@(matrixButton,event) matrixButtonPushed(matrixButton));

% 24. Repetitions checkbox UI tree
% handles.Stats.matrixRepsUITree=uitree(statsTab,'checkbox','SelectionChangedFcn',@(matrixRepsUITree,event) matrixRepsUITreeSelectionChanged(matrixRepsUITree),'CheckedNodesChangedFcn',@(matrixRepsUITree,event) matrixRepsUITreeCheckedNodesChanged(matrixRepsUITree),'Tag','MatrixRepsUITree');

% 25. Data-driven add repetition variable button
handles.Stats.addDataRepVarButton=uibutton(statsTab,'push','Text','DR+','Tag','AddDataRepsVarButton','Tooltip','Add repetition variable from data','ButtonPushedFcn',@(addDataRepVarsButton,event) addDataRepVarsButtonPushed(addDataRepVarsButton));

% 26. Stats pub tables panel
handles.Stats.pubTablesPanel=uipanel(statsTab,'BackgroundColor',[0.8 0.8 0.8]);

% 27. Publication tables label
handles.Stats.pubTablesLabel=uilabel(statsTab,'FontWeight','bold','Text','Pub Tables','Tag','PubTablesLabel');

% 28. Add new publication table button
handles.Stats.addPubTableButton=uibutton(statsTab,'push','Text','PT+','Tag','AddPubTableButton','Tooltip','Create a new publication table','ButtonPushedFcn',@(addPubTableButton,event) addPubTableButtonPushed(addPubTableButton));

% 29. Remove publication table button
handles.Stats.removePubTableButton=uibutton(statsTab,'push','Text','PT-','Tag','RemovePubTableButton','Tooltip','Remove a publication table','ButtonPushedFcn',@(removePubTableButton,event) removePubTableButtonPushed(removePubTableButton));

% 30. Publication tables UI tree
handles.Stats.pubTablesUITree=uitree(statsTab,'SelectionChangedFcn',@(pubTablesUITree,event) pubTablesUITreeSelectionChanged(pubTablesUITree),'Tag','PubTablesUITree');

% 31. Edit table button
handles.Stats.editPubTableButton=uibutton(statsTab,'push','Text','Edit','Tag','EditPubTableButton','Tooltip','Edit a publication table','ButtonPushedFcn',@(editPubTableButton,event) editPubTableButtonPushed(editPubTableButton));

% 32. Create table button
handles.Stats.runPubTableButton=uibutton(statsTab,'push','Text','Run','Tag','RunPubTableButton','Tooltip','Create the table for publication','ButtonPushedFcn',@(runPubTableButton,event) runPubTableButtonPushed(runPubTableButton));

% 33. Significant figures label
handles.Stats.sigFigsLabel=uilabel(statsTab,'Text','Sig Figs','Tag','SigFigsLabel');

% 34. # significant figures edit field
handles.Stats.numSigFigsEditField=uieditfield(statsTab,'numeric','Value',3,'Tag','NumSigFigsEditField','ValueChangedFcn',@(numSigFigsEditField,event) numSigFigsEditFieldValueChanged(numSigFigsEditField));

% 35. Context menu
handles.Stats.openStatsFcnContextMenu=uicontextmenu(fig);
handles.Stats.openStatsFcnContextMenuItem1=uimenu(handles.Stats.openStatsFcnContextMenu,'Text','Open Fcn','MenuSelectedFcn',{@openMFileStats});

% 36. Context menu
handles.Stats.openMultiRepPopupWindowContextMenu=uicontextmenu(fig);
handles.Stats.openMultiRepPopupWindowContextMenuItem1=uimenu(handles.Stats.openMultiRepPopupWindowContextMenu,'Text','Assign Vars','MenuSelectedFcn',{@openMultiRepPopupWindow});

statsTab.UserData=struct('VarsUITree',handles.Stats.varsUITree,'CreateTableButton',handles.Stats.createTableButton,'RemoveTableButton',handles.Stats.removeTableButton,...
    'TablesUITree',handles.Stats.tablesUITree,'SpecifyTrialsButton',handles.Stats.specifyTrialsButton,'AddRepsVarButton',handles.Stats.addRepsVarButton,...
    'AddVarsButton',handles.Stats.addVarsButton,'RemoveVarsButton',handles.Stats.removeVarsButton,'VarUpButton',handles.Stats.varUpButton,'VarDownButton',handles.Stats.varDownButton,...
    'AsssignedVarsUITree',handles.Stats.assignedVarsUITree,'AssignFcnButton',handles.Stats.assignFcnButton,'UnassignFcnButton',handles.Stats.unassignFcnButton,...
    'CreateFcnButton',handles.Stats.createFcnButton,'RemoveFcnButton',handles.Stats.removeFcnButton,'FcnsUITree',handles.Stats.fcnsUITree,'RunButton',handles.Stats.runButton,...
    'AssignVarsButton',handles.Stats.assignVarsButton,'VarsDescLabel',handles.Stats.varsDescLabel,'VarsDescTextArea',handles.Stats.varsDescTextArea,'TableDescLabel',handles.Stats.tableDescLabel,...
    'TableDescTextArea',handles.Stats.tableDescTextArea,'AddDataRepsVarButton',handles.Stats.addDataRepVarButton,'PubTablesLabel',handles.Stats.pubTablesLabel,'AddPubTableButton',handles.Stats.addPubTableButton,...
    'RemovePubTableButton',handles.Stats.removePubTableButton,'PubTablesUITree',handles.Stats.pubTablesUITree,'EditPubTableButton',handles.Stats.editPubTableButton,'PubTablesPanel',handles.Stats.pubTablesPanel,...
    'RunPubTableButton',handles.Stats.runPubTableButton,'NumSigFigsEditField',handles.Stats.numSigFigsEditField,'NumSigFigsLabel',handles.Stats.sigFigsLabel);

@statsResize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the settings tab
% 1. Common path label
% handles.Settings.commonPathLabel=uilabel(settingsTab,'Text','Common Path','FontWeight','Bold');

% 1. Select common path button
handles.Settings.commonPathButton=uibutton(settingsTab,'push','Text','Common Path','Tag','CommonPathButton','ButtonPushedFcn',@(commonPathButton,event) commonPathButtonPushed(commonPathButton));

% 3. Common path edit field
handles.Settings.commonPathEditField=uieditfield(settingsTab,'Value','','Tag','CommonPathEditField','ValueChangedFcn',@(commonPathEditField,event) commonPathEditFieldValueChanged(commonPathEditField));

% 4. Open common path button
handles.Settings.openCommonPathButton=uibutton(settingsTab,'push','Text','O','Tag','OpenCommonPathButton','ButtonPushedFcn',@(openCommonPathButton,event) openCommonPathButtonPushed(openCommonPathButton));

setappdata(fig,'handles',handles);
settingsResize(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the context menus for UI trees
handles.Process.commonContextMenu=uicontextmenu(fig);
handles.Process.commonContextMenuItem1=uimenu(handles.Process.commonContextMenu,'Text','Open','MenuSelectedFcn',{@openJSONFile});

handles.Process.psContextMenu=uicontextmenu(fig);
handles.Process.psContextMenuItem1=uimenu(handles.Process.psContextMenu,'Text','Open','MenuSelectedFcn',{@openJSONFile});