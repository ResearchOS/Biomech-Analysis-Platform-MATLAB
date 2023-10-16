function [handles]=initializeComponents(fig)

%% PURPOSE: CREATE ALL OF THE COMPONENTS THAT ARE ON THE PGUI FIGURE
% fig=fig.handle; % The handle to the PGUI figure
handles=getappdata(fig,'handles'); % The handle to all components in the PGUI figure

defaultPos=get(0,'defaultfigureposition'); % Get the default figure position
set(fig,'Position',[defaultPos(1:2) defaultPos(3)*2 defaultPos(4)]); % Set the figure to be at that position (redundant, I know, but should be clear)
figSize=get(fig,'Position'); % Get the figure's position.
figSize=figSize(3:4); % Width & height of the figure upon creation. Size syntax: left offset, bottom offset, width, height (pixels)

%% Create tab group with the four primary tabs
tabGroup1=uitabgroup(fig,'Position',[0 0 figSize],'AutoResizeChildren','off','SelectionChangedFcn',@tabGroup1SelectionChanged,'Tag','TabGroup'); % Create the tab group for the four stages of data processing
fig.UserData=struct('TabGroup1',tabGroup1); % Store the components to the figure.
projectsTab=uitab(tabGroup1,'Title','Projects','Tag','Projects','AutoResizeChildren','off'); % Create the projects tab
importTab=uitab(tabGroup1,'Title','Import','Tag','Import','AutoResizeChildren','off'); % Create the import tab
processTab=uitab(tabGroup1,'Title','Process','Tag','Process','AutoResizeChildren','off'); % Create the process tab
plotTab=uitab(tabGroup1,'Title','Plot','Tag','Plot','AutoResizeChildren','off'); % Create the plot tab
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

setappdata(fig,'handles',handles);

sortOptions={'DateModified (New->Old)','DateCreated (New->Old)','Alphabetical (A->Z)'};
sortOptions=sort(sortOptions); % Alphabetical order
args.VR.Type = 'VR';
args.all_VR.Type = 'All_VR';
args.PR.Type = 'PR';
args.all_PR.Type = 'All_PR';
args.PG.Type = 'PG';
args.all_PG.Type = 'All_PG';
args.AN.Type = 'AN';
args.all_AN.Type = 'All_AN';
args.ST.Type = 'ST';
args.all_ST.Type = 'All_ST';
args.DoubleClick.Type = 'DoubleClick';
args.ContextMenu.Type = 'ContextMenu';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the projects tab.
% 1. The project name label
handles.Projects.projectsLabel=uilabel(projectsTab,'Text','Projects','Tag','ProjectsLabel','FontWeight','bold');

% 2. Add new project button
handles.Projects.addProjectButton=uibutton(projectsTab,'push','Text','P+','Tag','AddProjectButton','Tooltip','Create new project','ButtonPushedFcn',@componentCallback);

% 3. Remove project button
handles.Projects.removeProjectButton=uibutton(projectsTab,'push','Text','P-','Tag','RemoveProjectButton','Tooltip','Remove current project from the list','ButtonPushedFcn',@componentCallback);

% 4. Sort projects dropdown
handles.Projects.sortProjectsDropDown=uidropdown(projectsTab,'Editable','off','Items',sortOptions,'Tooltip','Sort Projects','Tag','SortProjectsDropDown','Value',sortOptions{1},'ValueChangedFcn',@(sortProjectsDropDown,event) sortProjectsDropDownValueChanged(sortProjectsDropDown));

% 5. All projects UI tree
handles.Projects.allProjectsUITree=uitree(projectsTab,'checkbox','SelectionChangedFcn',@componentCallback,'CheckedNodesChangedFcn',@allProjectsUITreeCheckedNodesChanged);

% 6. Load project snapshot button (settings & code only, not data)
handles.Projects.loadSnapshotButton=uibutton(projectsTab,'push','Text','Load Snapshot','Tag','LoadSnapshotButton','Tooltip','Load Previously Saved Snapshot of the Current Project','ButtonPushedFcn',@(loadSnapshotButton,event) loadSnapshotButtonPushed(loadSnapshotButton));

% 7. Save project snapshot button (settings & code only, not data)
handles.Projects.saveSnapshotButton=uibutton(projectsTab,'push','Text','Save Snapshot','Tag','SaveSnapshotButton','Tooltip','Save Snapshot of the Current Project','ButtonPushedFcn',@(saveSnapshotButton,event) saveSnapshotButtonPushed(saveSnapshotButton));

% 8. Project data path button
handles.Projects.dataPathButton=uibutton(projectsTab,'push','Tooltip','Select Data Path','Text','Data Path','Tag','DataPathButton','ButtonPushedFcn',{@componentCallback, 'Data_Path'});

% 9. Project data path edit field
handles.Projects.dataPathField=uieditfield(projectsTab,'text','Value','Data Path (contains ''Raw Data Files'' folder)','Tag','DataPathField','ValueChangedFcn',{@componentCallback, 'Data_Path'}); % Data path name edit field (to the folder containing 'Subject Data' folder)

% 10. Open data path button
handles.Projects.openDataPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenDataPathButton','Tooltip','Open data folder','ButtonPushedFcn',{@componentCallback, 'Data_Path'});

% 11. Project folder path button (contains everything related to the current project)
handles.Projects.projectPathButton=uibutton(projectsTab,'push','Tooltip','Select Project Folder Path','Text','Project Path','Tag','ProjectPathButton','ButtonPushedFcn',{@componentCallback, 'Project_Path'});

% 12. Project folder path edit field
handles.Projects.projectPathField=uieditfield(projectsTab,'text','Value','Path to Project Folder','Tag','ProjectPathField','ValueChangedFcn',{@componentCallback, 'Project_Path'});

% 13. Open project path button
handles.Projects.openProjectPathButton=uibutton(projectsTab,'push','Text','O','Tag','OpenProjectPathButton','Tooltip','Open project folder','ButtonPushedFcn',{@componentCallback, 'Project_Path'});

% 14. Projects search field
handles.Projects.searchField=uieditfield(projectsTab,'text','Value','Search','Tag','SearchField','ValueChangingFcn',@(searchField,event) projectsSearchFieldValueChanging(searchField));

% 15. Current project button
handles.Projects.currentProjectButton=uibutton(projectsTab,'push','Tooltip','Select current project','Text','Select','ButtonPushedFcn',@componentCallback);

% 14. Create project archive button (settings, code, & data)
% handles.Projects.createProjectArchiveButton=uibutton(projectsTab,'Text','Save Archive','Tag','ArchiveButton','ButtonPushedFcn',@(archiveButton,event) archiveButtonPushed(archiveButton));

% 15. Load project archive button (settings, code, & data)
% handles.Projects.loadProjectArchiveButton=uibutton(projectsTab,'Text','Load Archive','Tag','LoadArchiveButton','ButtonPushedFcn',@(loadArchiveButton,event) loadArchiveButtonPushed(loadArchiveButton));

setappdata(fig,'handles',handles);
% projectsResize(fig.Projects);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the import tab.
% 1. Logsheets label
handles.Import.logsheetsLabel=uilabel(importTab,'Text','Logsheets','FontWeight','bold');

% 2. Create new logsheet button
handles.Import.addLogsheetButton=uibutton(importTab,'push','Text','L+','ButtonPushedFcn',@componentCallback);

% 3. Remove logsheet button
handles.Import.removeLogsheetButton=uibutton(importTab,'push','Text','L-','ButtonPushedFcn',@componentCallback);

% 4. Sort logsheets dropdown
handles.Import.sortLogsheetsDropDown=uidropdown(importTab,'Editable','off','Items',sortOptions','Value',sortOptions{1},'ValueChangedFcn',@(sortLogsheetsDropDown,event) sortLogsheetsDropDownValueChanged(sortLogsheetsDropDown));

% 5. All logsheets UI tree
handles.Import.allLogsheetsUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@componentCallback,'CheckedNodesChangedFcn',@(allLogsheetsUITree,event) allLogsheetsUITreeCheckedNodesChanged(allLogsheetsUITree));

% 6. Logsheet search field
handles.Import.searchField=uieditfield(importTab,'Value','Search','ValueChangingFcn',@(searchField,event) importSearchFieldValueChanging(searchField));

% 7. Logsheet path field
handles.Import.logsheetPathField=uieditfield(importTab,'Value','Enter Logsheet Path','ValueChangedFcn',@componentCallback);

% 8. Logsheet path button
handles.Import.logsheetPathButton=uibutton(importTab,'push','Text','Set Logsheet Path','ButtonPushedFcn',@componentCallback);

% 9. Open logsheet path button
handles.Import.openLogsheetPathButton=uibutton(importTab,'push','Text','O','ButtonPushedFcn',@componentCallback);

% 10. Number of header rows label
handles.Import.numHeaderRowsLabel=uilabel(importTab,'Text','# Header Rows','FontWeight','bold');

% 11. Number of header rows numeric edit field
handles.Import.numHeaderRowsField=uieditfield(importTab,'numeric','Value',-1,'ValueChangedFcn',@componentCallback);

% 12. Subject codename label
handles.Import.subjectCodenameLabel=uilabel(importTab,'Text','Subject Codename','FontWeight','bold');

% 13. Subject codename edit field
handles.Import.subjectCodenameDropDown=uidropdown(importTab,'Items',{''},'ValueChangedFcn',@componentCallback);

% 14. Target trial ID label
handles.Import.targetTrialIDLabel=uilabel(importTab,'Text','Target Trial ID','FontWeight','bold');

% 15. Target trial ID edit field
handles.Import.targetTrialIDDropDown=uidropdown(importTab,'Items',{''},'ValueChangedFcn',@componentCallback);

% 16. Data type-specific trial ID label (optional if only one data type)

% 17. Data type-specific trial ID edit field (optional if only one data type)

% 20. Header variables UI tree
handles.Import.headersUITree=uitree(importTab,'checkbox','SelectionChangedFcn',@componentCallback);

% 21. Levels drop down
handles.Import.levelDropDown=uidropdown(importTab,'Items',{'','Subject','Trial'},'Value','','ValueChangedFcn',@componentCallback);

% 22. Type drop down
handles.Import.typeDropDown=uidropdown(importTab,'Items',{'','Double','Char'},'Value','','ValueChangedFcn',@componentCallback);

% 23. Check all button
handles.Import.checkAllButton=uibutton(importTab,'Text','Check All','ButtonPushedFcn',@componentCallback);

% 24. Uncheck all button
handles.Import.uncheckAllButton=uibutton(importTab,'Text','Uncheck All','ButtonPushedFcn',@componentCallback);

% 25. Run logsheet button
handles.Import.runLogsheetButton=uibutton(importTab,'Text','Run','ButtonPushedFcn',@componentCallback);

% 24. Specify trials label
handles.Import.specifyTrialsLabel=uilabel(importTab,'Text','Specify Trials','FontWeight','bold');

% 25. Add specify trials button
handles.Import.addSpecifyTrialsButton=uibutton(importTab,'Text','S+');
addSpecifyTrialsButton=handles.Import.addSpecifyTrialsButton;
set(addSpecifyTrialsButton,'ButtonPushedFcn',@componentCallback);

% 26. Remove specify trials button
handles.Import.removeSpecifyTrialsButton=uibutton(importTab,'Text','S-');
removeSpecifyTrialsButton=handles.Import.removeSpecifyTrialsButton;
set(removeSpecifyTrialsButton,'ButtonPushedFcn',@componentCallback);

% 27. Specify trials UI tree
handles.Import.allSpecifyTrialsUITree=uitree(importTab,'checkbox','Tag','Import');
specifyTrialsUITree=handles.Import.allSpecifyTrialsUITree;
set(specifyTrialsUITree,'CheckedNodesChangedFcn',@componentCallback);

% 28. Edit specify trials node button
handles.Import.editSpecifyTrialsButton=uibutton(importTab,'Text','Edit');
editSpecifyTrialsButton=handles.Import.editSpecifyTrialsButton;
set(editSpecifyTrialsButton,'ButtonPushedFcn',@componentCallback);

setappdata(fig,'handles',handles);
% importResize(fig);

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

% 5. Analyses tab
handles.Process.analysesTab=uitab(handles.Process.subTabAll,'Title','Analyses','AutoResizeChildren','off');

% 1. Variables label
% handles.Process.variablesLabel=uilabel(handles.Process.variablesTab,'Text','Variables','FontWeight','bold');

% 2. Add variable button
handles.Process.addVariableButton=uibutton(handles.Process.variablesTab,'text','V+','ButtonPushedFcn',{@componentCallback,args.all_VR});

% 3. Remove variable button
handles.Process.removeVariableButton=uibutton(handles.Process.variablesTab,'text','V-','ButtonPushedFcn',{@componentCallback,args.all_VR});

% 4. Sort variables drop down
handles.Process.sortVariablesDropDown=uidropdown(handles.Process.variablesTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortVariablesDropDown,event) sortVariablesDropDownValueChanged(sortVariablesDropDown));

% 5. All variables UI tree
handles.Process.allVariablesUITree=uitree(handles.Process.variablesTab,'checkbox','SelectionChangedFcn',@(allVariablesUITree,event) allVariablesUITreeSelectionChanged(allVariablesUITree));

% 6. Variables search field
handles.Process.variablesSearchField=uieditfield(handles.Process.variablesTab,'Value','Search','ValueChangingFcn',@(variablesSearchField,event) variablesSearchFieldValueChanging(variablesSearchField));

% 7. Functions label
% handles.Process.processLabel=uilabel(handles.Process.functionsTab,'Text','Functions','FontWeight','bold');

% 8. Add function button
handles.Process.addProcessButton=uibutton(handles.Process.functionsTab,'text','F+','ButtonPushedFcn',{@componentCallback,args.all_PR});

% 9. Remove function button
handles.Process.removeProcessButton=uibutton(handles.Process.functionsTab,'text','F-','ButtonPushedFcn',{@componentCallback,args.all_PR});

% 10. Sort functions drop down
handles.Process.sortProcessDropDown=uidropdown(handles.Process.functionsTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortFunctionsDropDown,event) sortProcessDropDownValueChanged(sortFunctionsDropDown));

% 11. All functions UI tree
handles.Process.allProcessUITree=uitree(handles.Process.functionsTab,'checkbox','SelectionChangedFcn',@(allFunctionsUITree,event) allProcessUITreeSelectionChanged(allFunctionsUITree));

% 12. Functions search field
handles.Process.processSearchField=uieditfield(handles.Process.functionsTab,'Value','Search','ValueChangingFcn',@(functionsSearchField,event) processSearchFieldValueChanging(functionsSearchField));

% 13. Assign variable button
handles.Process.assignVariableButton=uibutton(handles.Process.variablesTab,'Text','->','Visible','off','ButtonPushedFcn',{@componentCallback, args.VR});

% 14. Unassign variable button
handles.Process.unassignVariableButton=uibutton(handles.Process.variablesTab,'Text','<-','Visible','off','ButtonPushedFcn',{@componentCallback, args.VR});

% 15. Assign function button
handles.Process.assignFunctionButton=uibutton(handles.Process.functionsTab,'Text','->','Visible','on','ButtonPushedFcn',{@componentCallback, args.PR});

% 16. Unassign function button
handles.Process.unassignFunctionButton=uibutton(handles.Process.functionsTab,'Text','<-','Visible','on','ButtonPushedFcn',{@componentCallback, args.PR});

% 13. Add group button
handles.Process.addGroupButton=uibutton(handles.Process.groupsTab,'Text','G+','ButtonPushedFcn',{@componentCallback, args.all_PG});

% 14. Remove group button
handles.Process.removeGroupButton=uibutton(handles.Process.groupsTab,'Text','G-','ButtonPushedFcn',{@componentCallback, args.all_PG});

% 15. Sort group drop down
handles.Process.sortGroupsDropDown=uidropdown(handles.Process.groupsTab,'Editable','off','Items',sortOptions,'ValueChangedFcn',@(sortGroupsDropDown,event) sortGroupsDropDownValueChanged(sortGroupsDropDown));

% 16. All groups UI tree
handles.Process.allGroupsUITree=uitree(handles.Process.groupsTab,'checkbox','SelectionChangedFcn',@(allGroupsUITree,event) allGroupsUITreeSelectionChanged(allGroupsUITree));

% 17. Groups search field
handles.Process.groupsSearchField=uieditfield(handles.Process.groupsTab,'Value','Search','ValueChangingFcn',@(groupsSearchField,event) groupsSearchFieldValueChanging(groupsSearchField));

% 18. Assign group button
handles.Process.assignGroupButton=uibutton(handles.Process.groupsTab,'Text','->','Visible','on','ButtonPushedFcn',{@componentCallback, args.PG});

% 19. Unassign group button
handles.Process.unassignGroupButton=uibutton(handles.Process.groupsTab,'Text','<-','Visible','on','ButtonPushedFcn',{@componentCallback, args.PG});

% 20. Add analysis button
handles.Process.addAnalysisButton=uibutton(handles.Process.analysesTab,'Text','A+','ButtonPushedFcn',{@componentCallback, args.all_AN});

% 21. Remove analysis button
handles.Process.removeAnalysisButton=uibutton(handles.Process.analysesTab,'Text','A-','ButtonPushedFcn',{@componentCallback, args.all_AN});

% 22. Sort analyses drop down
handles.Process.sortAnalysesDropDown=uidropdown(handles.Process.analysesTab,'Editable','off','Items',sortOptions','ValueChangedFcn',@(sortAnalysesDropDown,event) sortAnalysesDropDown(sortAnalysesDropDown));

% 23. All analyses UI tree
handles.Process.allAnalysesUITree=uitree(handles.Process.analysesTab,'checkbox','SelectionChangedFcn',@componentCallback);

% 24. Analyses search field
handles.Process.analysesSearchField=uieditfield(handles.Process.analysesTab,'Value','Search','ValueChangingFcn',@(analysesSearchField, event) analysesSearchFieldValueChanging(analysesSearchField));

% 25. Select analysis button
handles.Process.selectAnalysisButton=uibutton(handles.Process.analysesTab,'push','Text','Sel','ButtonPushedFcn',{@componentCallback, args.all_AN});

% 18. Queue UI tree
handles.Process.queueUITree=uitree(processTab,'checkbox');

% 19. Queue label
handles.Process.queueLabel=uilabel(processTab,'FontWeight','bold','Text','Queue');

% 22. Current group/function tab group
handles.Process.subtabCurrent=uitabgroup(processTab,'AutoResizeChildren','off','SelectionChangedFcn',@(subTabCurrent,event) subTabCurrentSelectionChanged(subTabCurrent));

% 23. Current analysis tab
handles.Process.currentAnalysisTab=uitab(handles.Process.subtabCurrent,'Title','Analysis','AutoResizeChildren','off');

% 23. Current group tab
handles.Process.currentGroupTab=uitab(handles.Process.subtabCurrent,'Title','Group','AutoResizeChildren','off');

% 24. Current function tab
handles.Process.currentFunctionTab=uitab(handles.Process.subtabCurrent,'Title','Function','AutoResizeChildren','off');

% 25. Run button
handles.Process.runButton=uibutton(processTab,'push','Text','Run','ButtonPushedFcn',@componentCallback);

% 26. Current group UI tree
handles.Process.groupUITree=uitree(handles.Process.currentGroupTab,'checkbox','SelectionChangedFcn',{@componentCallback, args.PG},'DoubleClickedFcn',{@componentCallback, args.DoubleClick});

% 27. Current function UI tree
handles.Process.functionUITree=uitree(handles.Process.currentFunctionTab,'checkbox','SelectionChangedFcn',{@componentCallback, args.PR});

% 28. Current analysis UI tree
handles.Process.analysisUITree=uitree(handles.Process.currentAnalysisTab,'checkbox','SelectionChangedFcn',{@componentCallback, args.AN},'DoubleClickedFcn',{@componentCallback, args.DoubleClick});

% 20. Add to queue button
handles.Process.addToQueueButton=uibutton(processTab,'push','Text','->','ButtonPushedFcn',@componentCallback);

% 21. Remove from queue button
handles.Process.removeFromQueueButton=uibutton(processTab,'push','Text','<-','ButtonPushedFcn',@componentCallback);

% 30. Save as new analysis button
handles.Process.copyToNewAnalysisButton=uibutton(handles.Process.currentAnalysisTab,'push','Text',{'Copy To New','Analysis'},'ButtonPushedFcn',@componentCallback);

% 32. Current analysis label
handles.Process.currentAnalysisLabel=uilabel(handles.Process.currentAnalysisTab,'Text','Current Analysis','FontWeight','bold');

% 33. Current group label
handles.Process.currentGroupLabel=uilabel(handles.Process.currentGroupTab,'Text','Current Group','FontWeight','bold');

% 34. Current function label
handles.Process.currentFunctionLabel=uilabel(handles.Process.currentFunctionTab,'Text','Current Function','FontWeight','bold');

% 33. Add getArg/setArg button
handles.Process.addArgsButton=uibutton(handles.Process.currentFunctionTab,'Text','+','ButtonPushedFcn',@componentCallback);

% 34. Remove getArg/setArg button
handles.Process.removeArgsButton=uibutton(handles.Process.currentFunctionTab,'Text','-','ButtonPushedFcn',@componentCallback);

% 35. Toggle digraph button
handles.Process.toggleDigraphCheckbox=uicheckbox(processTab,'Value',false,'Text','Show Digraph','ValueChangedFcn',@componentCallback);

% 36. Digraph UI axes
handles.Process.digraphAxes=uiaxes(processTab,'Visible',false,'Box','off','XTickLabel',{},'YTickLabel',{},'XTick',{},'YTick',{},'PickableParts','visible','HitTest','on','ButtonDownFcn',@componentCallback);

% 49. Out of date checkbox
handles.Process.outOfDateCheckbox=uicheckbox(handles.Process.currentGroupTab,'Value',false,'Text','Out of Date','ValueChangedFcn',@componentCallback);

% 50. Send emails checkbox
handles.Process.sendEmailsCheckbox=uicheckbox(processTab, 'Visible', true, 'Value', false, 'Text', 'Send Email','ValueChangedFcn',@componentCallback);

% 51. Views dropdown
handles.Process.viewsDropDown = uidropdown(processTab,'Visible',false,'Items',{'ALL'},'Editable','off','ValueChangedFcn',@componentCallback);

% 52. Edit/save view state button
handles.Process.editViewButton = uibutton(processTab,'state','Visible',false,'Text','Edit','ValueChangedFcn',@componentCallback);

% 53. Select multi state button
handles.Process.multiSelectButton = uibutton(processTab,'state','Visible',false,'Text','Multi','ValueChangedFcn',@componentCallback);

% 38. Pretty variables checkbox
handles.Process.prettyVarsCheckbox=uicheckbox(processTab,'Visible',false,'Value',false,'Text','Pretty Vars','ValueChangedFcn',@componentCallback);

% 54. Add node (from list) button
handles.Process.addToViewButton = uibutton(processTab,'push','Visible',false,'Text','->','ButtonPushedFcn',@componentCallback);

% 55. Remove node (from axes) button
handles.Process.removeFromViewButton = uibutton(processTab,'push','Visible',false,'Text','<-','ButtonPushedFcn',@componentCallback);

% 56. Add/remove successors button
handles.Process.successorsButton = uibutton(processTab,'push','Visible',false,'Text','S','ButtonPushedFcn',@componentCallback);

% 57. Add/remove predecessors button
handles.Process.predecessorsButton = uibutton(processTab,'push','Visible',false,'Text','P','ButtonPushedFcn',@componentCallback);

% 58. Create new view button
handles.Process.newViewButton = uibutton(processTab,'push','Visible',false,'Text','VW+','ButtonPushedFcn',@componentCallback);

% 59. Archive view button
handles.Process.archiveViewButton = uibutton(processTab,'push','Visible',false,'Text','VW-','ButtonPushedFcn',@componentCallback);

% 35. Add specify trials button
handles.Process.addSpecifyTrialsButton=uibutton(processTab,'Text','S+');
addSpecifyTrialsButton=handles.Process.addSpecifyTrialsButton;
set(addSpecifyTrialsButton,'ButtonPushedFcn',{@componentCallback, args.all_ST});

% 36. Remove specify trials button
handles.Process.removeSpecifyTrialsButton=uibutton(processTab,'Text','S-');
removeSpecifyTrialsButton=handles.Process.removeSpecifyTrialsButton;
set(removeSpecifyTrialsButton,'ButtonPushedFcn',{@componentCallback,args.all_ST});

% 37. Specify trials UI tree
handles.Process.allSpecifyTrialsUITree=uitree(processTab,'checkbox','Tag','Process');
specifyTrialsUITree=handles.Process.allSpecifyTrialsUITree;
set(specifyTrialsUITree,'CheckedNodesChangedFcn',{@componentCallback,args.ST});

% 38. Edit specify trials node button
handles.Process.editSpecifyTrialsButton=uibutton(processTab,'Text','Edit');
editSpecifyTrialsButton=handles.Process.editSpecifyTrialsButton;
set(editSpecifyTrialsButton,'ButtonPushedFcn',@componentCallback);

handles.Process.subtabCurrent.SelectedTab=handles.Process.currentGroupTab;
setappdata(fig,'handles',handles);
% processResize(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the plot tab
% 1. Tab group
handles.Plot.subTabAll=uitabgroup(plotTab,'AutoResizeChildren','off');

% 3. All components tab
handles.Plot.componentsTab=uitab(handles.Plot.subTabAll,'Title','Components','AutoResizeChildren','off');

% 2. All plots tab
handles.Plot.plotsTab=uitab(handles.Plot.subTabAll,'Title','Plots','AutoResizeChildren','off');
% handles.Plot.plotLabel=uilabel(plotTab,'Text','Plots','FontWeight','bold');

% 2. Add plot button
handles.Plot.addPlotButton=uibutton(handles.Plot.plotsTab,'Text','P+','ButtonPushedFcn',@(addPlotButton,event) addPlotButtonPushed(addPlotButton));

% 3. Remove plot button
handles.Plot.removePlotButton=uibutton(handles.Plot.plotsTab,'Text','P-','ButtonPushedFcn',@(removePlotButton,event) removePlotButtonPushed(removePlotButton));

% 4. Sort plots drop down
handles.Plot.sortPlotsDropDown=uidropdown(handles.Plot.plotsTab,'Items',sortOptions,'ValueChangedFcn',@(sortPlotDropDown,event) sortPlotDropDownValueChanged(sortPlotDropDown));

% 5. All plots UI tree
handles.Plot.allPlotsUITree=uitree(handles.Plot.plotsTab,'checkbox','SelectionChangedFcn',@(allPlotsUITree,event) allPlotsUITreeSelectionChanged(allPlotsUITree));

% 6. Plots search field
handles.Plot.plotSearchField=uieditfield(handles.Plot.plotsTab,'Value','Search','ValueChangingFcn',@(plotSearchField,event) plotSearchFieldValueChanging(plotSearchField));

% 7. Component label
% handles.Plot.componentLabel=uilabel(plotTab,'Text','Components','FontWeight','bold');

% 8. Assign plot button
handles.Plot.assignPlotButton=uibutton(handles.Plot.plotsTab,'Text','->','ButtonPushedFcn',@(assignPlotButton,event) assignPlotButtonPushed(assignPlotButton));

% 9. Unassign plot button
handles.Plot.unassignPlotButton=uibutton(handles.Plot.plotsTab,'Text','<-','ButtonPushedFcn',@(unassignPlotButton,event) unassignPlotButtonPushed(unassignPlotButton));

% 8. Add component button
handles.Plot.addComponentButton=uibutton(handles.Plot.componentsTab,'Text','C+','ButtonPushedFcn',@(addComponentButton,event) addComponentButtonPushed(addComponentButton));

% 9. Remove component button
handles.Plot.removeComponentButton=uibutton(handles.Plot.componentsTab,'Text','C-','ButtonPushedFcn',@(removeComponentButton,event) removeComponentButtonPushed(removeComponentButton));

% 10. Sort components drop down
handles.Plot.sortComponentsDropDown=uidropdown(handles.Plot.componentsTab,'Items',sortOptions,'ValueChangedFcn',@(sortComponentDropDown,event) sortComponentDropDownValueChanged(sortComponentDropDown));

% 11. All components UI tree
handles.Plot.allComponentsUITree=uitree(handles.Plot.componentsTab,'checkbox','SelectionChangedFcn',@(allComponentsUITree,event) allComponentsUITreeSelectionChanged(allComponentsUITree));

% 12. Components search field
handles.Plot.componentSearchField=uieditfield(handles.Plot.componentsTab,'Value','Search','ValueChangingFcn',@(componentSearchField,event) componentSearchFieldValueChanging(componentSearchField));

% 13. Assign component button
handles.Plot.assignComponentButton=uibutton(handles.Plot.componentsTab,'Text','->','ButtonPushedFcn',@(assignComponentButton,event) assignComponentButtonPushed(assignComponentButton));

% 14. Unassign component button
handles.Plot.unassignComponentButton=uibutton(handles.Plot.componentsTab,'Text','<-','ButtonPushedFcn',@(unassignComponentButton,event) unassignComponentButtonPushed(unassignComponentButton));

% 13. Current plot/component tab group
handles.Plot.subtabCurrent=uitabgroup(plotTab,'AutoResizeChildren','off','SelectionChangedFcn',@(subTabCurrent,event) plotSubTabCurrentSelectionChanged(subTabCurrent));

% 14. Current plot tab
handles.Plot.currentPlotTab=uitab(handles.Plot.subtabCurrent,'Title','Plot','AutoResizeChildren','off');

% 15. Current component tab
handles.Plot.currentComponentTab=uitab(handles.Plot.subtabCurrent,'Title','Component','AutoResizeChildren','off');

% 16. Render button
handles.Plot.plotButton=uibutton(plotTab,'Text','Plot','ButtonPushedFcn',@(plotButton,event) plotButtonPushed(plotButton));

% 20. Select plot button
handles.Plot.selectPlotButton=uibutton(handles.Plot.plotsTab,'Text','Sel','ButtonPushedFcn',@(selectPlotButton,event) selectPlotButtonPushed(selectPlotButton));

% 21. Current plot name label
handles.Plot.currentPlotLabel=uilabel(handles.Plot.currentPlotTab,'Text','Current Plot','FontWeight','bold');

% 17. Current plot UI tree
handles.Plot.plotUITree=uitree(handles.Plot.currentPlotTab,'checkbox','SelectionChangedFcn',@(currentPlotUITree,event) plotUITreeSelectionChanged(currentPlotUITree));

% 18. Save as new plot button
handles.Plot.saveAsNewPlotButton=uibutton(handles.Plot.currentPlotTab,'Text',{'Save As','New Plot'},'ButtonPushedFcn',@(saveAsNewPlotButton,event) saveAsNewPlotButtonPushed(saveAsNewPlotButton));

% 19. Current component UI tree
handles.Plot.componentUITree=uitree(handles.Plot.currentComponentTab,'checkbox');

% 20. Add args button
handles.Plot.addArgsButton=uibutton(handles.Plot.currentComponentTab,'Text','+','ButtonPushedFcn',@(addArgsButton,event) addArgsButtonPushed_Plot(addArgsButton));

% 21. Remove args button
handles.Plot.removeArgsButton=uibutton(handles.Plot.currentComponentTab,'Text','-','ButtonPushedFcn',@(removeArgsButton,event) removeArgsButtonPushed_Plot(removeArgsButton));

% 22. Add specify trials button
handles.Plot.addSpecifyTrialsButton=uibutton(plotTab,'Text','S+');
addSpecifyTrialsButton=handles.Plot.addSpecifyTrialsButton;
set(addSpecifyTrialsButton,'ButtonPushedFcn',@(addSpecifyTrialsButton,event) addSpecifyTrialsButtonPushed(addSpecifyTrialsButton))

% 23. Remove specify trials button
handles.Plot.removeSpecifyTrialsButton=uibutton(plotTab,'Text','S-');
removeSpecifyTrialsButton=handles.Plot.removeSpecifyTrialsButton;
set(removeSpecifyTrialsButton,'ButtonPushedFcn',@(removeSpecifyTrialsButton,event) removeSpecifyTrialsButtonPushed(removeSpecifyTrialsButton));

% 24. Specify trials UI tree
handles.Plot.allSpecifyTrialsUITree=uitree(plotTab,'checkbox');
specifyTrialsUITree=handles.Plot.allSpecifyTrialsUITree;
set(specifyTrialsUITree,'CheckedNodesChangedFcn',@(specifyTrialsUITree,event) specifyTrialsUITreeCheckedNodesChanged(specifyTrialsUITree));

% 25. Edit specify trials node button
handles.Plot.editSpecifyTrialsButton=uibutton(plotTab,'Text','Edit');
editSpecifyTrialsButton=handles.Plot.editSpecifyTrialsButton;
set(editSpecifyTrialsButton,'ButtonPushedFcn',@(editSpecifyTrialsButton,event) editSpecifyTrialsButtonPushed(editSpecifyTrialsButton));

% 26. Properties tab
handles.Plot.propertiesTab=uitab(handles.Plot.subtabCurrent,'Title','Properties','AutoResizeChildren','off');

% 27. Properties UI tree
handles.Plot.propertiesUITree=uitree(handles.Plot.propertiesTab,'checkbox','SelectionChangedFcn',@(propertiesUITree,event) propertiesUITreeSelectionChanged(propertiesUITree));

% 28. Edit property text area
handles.Plot.editPropertyTextArea=uitextarea(handles.Plot.propertiesTab,'Value','','ValueChangedFcn',@(editPropertyTextArea,event) editPropertyTextAreaValueChanged(editPropertyTextArea));

handles.Plot.subtabCurrent.SelectedTab=handles.Plot.currentPlotTab;
setappdata(fig,'handles',handles);
% plotResize(fig);

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

% @statsResize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the settings tab
% 1. Common path label
% handles.Settings.commonPathLabel=uilabel(settingsTab,'Text','Common Path','FontWeight','Bold');

% 1. Select db file path button
handles.Settings.dbFilePathButton=uibutton(settingsTab,'push','Text','DB File','Tag','DBFileButton','ButtonPushedFcn',@(dbFileButton,event) dbFileButtonPushed(dbFileButton));

% 3. Common path edit field
handles.Settings.dbFilePathEditField=uieditfield(settingsTab,'Value','','ValueChangedFcn',@(dbFilePathEditField,event) dbFilePathEditFieldValueChanged(dbFilePathEditField));

% 4. Open common path button
handles.Settings.opendbFilePathButton=uibutton(settingsTab,'push','Text','O','ButtonPushedFcn',@(opendbFilePathButton,event) opendbFilePathButtonPushed(opendbFilePathButton));

% 5. All users dropdown
handles.Settings.usersDropDown = uidropdown(settingsTab,'Items',{'Admin'},'Value','Admin','Editable','off','ValueChangedFcn',@(usersDropDown, event) usersDropDownValueChanged(usersDropDown));

% 6. Add user button
handles.Settings.addUserButton = uibutton(settingsTab,'push','Text','Add User','ButtonPushedFcn',@(addUserButton, event) addUserButtonPushed(addUserButton));

% 7. Delete user button
handles.Settings.removeUserButton = uibutton(settingsTab,'push','Text','Delete User','ButtonPushedFcn',@(removeUserButton, event) removeUserButtonPushed(removeUserButton));

setappdata(fig,'handles',handles);
% settingsResize(fig);
appResize(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the context menus for UI trees
handles.Process.ContextMenuTop=uicontextmenu(fig);
handles.Process.ContextMenu.Edit=uimenu(handles.Process.ContextMenuTop,'Text','Edit','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'EditObj'});
handles.Process.ContextMenu.SaveEdits=uimenu(handles.Process.ContextMenuTop,'Text','Save Edits','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'SaveEdits'});
% handles.Process.ContextMenu.OpenJSON=uimenu(handles.Process.ContextMenuTop,'Text','Open JSON','MenuSelectedFcn',{@openJSONFile});
handles.Process.ContextMenu.OpenMFile=uimenu(handles.Process.ContextMenuTop,'Text','Open M File','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'OpenMFile'});
handles.Process.ContextMenu.CopyToNew=uimenu(handles.Process.ContextMenuTop,'Text','Copy to New','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'CopyToNew'});
% handles.Process.ContextMenu.NewVersion=uimenu(handles.Process.ContextMenuTop,'Text','New Version','MenuSelectedFcn',{@createNewVersion});
% handles.Process.ContextMenu.CompareVersions=uimenu(handles.Process.ContextMenuTop,'Text','Compare Versions','MenuSelectedFcn',{@compareVersions});
% handles.Process.ContextMenu.Archive=uimenu(handles.Process.ContextMenuTop,'Text','Archive','MenuSelectedFcn',{@deleteObject});
handles.Process.ContextMenu.CopyUUID=uimenu(handles.Process.ContextMenuTop,'Text','Copy UUID','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'CopyUUID'});
handles.Process.ContextMenu.PasteUUID=uimenu(handles.Process.ContextMenuTop,'Text','Paste UUID','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'PasteUUID'});
handles.Process.ContextMenu.ShowNeighbors=uimenu(handles.Process.ContextMenuTop,'Text','Show Neighbors','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'ShowNeighbors'});
handles.Process.ContextMenu.EditSubvar=uimenu(handles.Process.ContextMenuTop,'Text','Edit Subvar','MenuSelectedFcn',{@componentCallback, args.ContextMenu, 'EditSubvar'});
% handles.Process.ContextMenu.OpenAbstractJSON=uimenu(handles.Process.ContextMenuTop,'Text','Open Abstract JSON','MenuSelectedFcn',{@openPIJSONFile});