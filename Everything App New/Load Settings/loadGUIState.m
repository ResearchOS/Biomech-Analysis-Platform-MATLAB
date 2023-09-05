function []=loadGUIState(fig)

%% PURPOSE: LOAD THE GUI STATE

global conn;

handles=getappdata(fig,'handles');

%% NEED TO ENSURE THAT THE PROPER ENTRIES IN THE UITREES ARE SELECTED FOR THE BELOW CODE TO WORK.

Current_Project_Name = getCurrent('Current_Project_Name');

%% Fill PJ UI trees with the correct values
% All other UI trees are filled when selecting the project.
sortDropDown=handles.Projects.sortProjectsDropDown;
uiTree=handles.Projects.allProjectsUITree;

fillUITree(fig, 'Project', uiTree, '', sortDropDown);    
% fillUITree_SpecifyTrials(fig); % Fill in the specify trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Projects tab
% Bring up the current project's project & data paths.
selectNode(handles.Projects.allProjectsUITree, Current_Project_Name);
allProjectsUITreeSelectionChanged(fig);
currentProjectButtonPushed(fig);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Import tab
% Current_Logsheet = getCurrent('Current_Logsheet');
% if ~isempty(Current_Logsheet)
%     selectNode(handles.Import.allLogsheetsUITree, Current_Logsheet);
%     % % Bring up the current logsheet's metadata.
%     % allLogsheetsUITreeSelectionChanged(fig, true);
% end
 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Process tab
% queue = getCurrent('Process_Queue');
% queueNames = getName(queue);
% for i=1:length(queueNames)
%     addNewNode(handles.Process.queueUITree, queue{i}, queueNames{i});
% end
% setappdata(fig,'multiSelect',false);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot tab
% % if ~isempty(projectPath)
% %     handles.Plot.currentPlotLabel.Text=projectSettings.Current_Plot_Name;
% %     fillPlotUITree(fig);
% %     plotPath=getClassFilePath(projectSettings.Current_Plot_Name,'Plot');
% %     plotStruct=loadJSON(plotPath);
% %     specifyTrialsPlot=plotStruct.SpecifyTrials;
% %     checkSpecifyTrialsUITree(specifyTrialsPlot,handles.Plot.allSpecifyTrialsUITree);
% % end
% % allPlotsUITreeSelectionChanged(fig);
% % allComponentsUITreeSelectionChanged(fig);
% % All components UI tree
% % handles.Plot.sortComponentsDropDown.Value=guiSettings.Plot.SortMethod.Components;
% % sortUITree(handles.Plot.allComponentsUITree,handles.Plot.sortComponentsDropDown.Value);
% % % All plots UI tree
% % handles.Plot.sortPlotsDropDown.Value=guiSettings.Plot.SortMethod.Plots;
% % sortUITree(handles.Plot.allPlotsUITree,handles.Plot.sortPlotsDropDown.Value);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Stats tab
% % The common path where all of the custom settings are stored independent
% % of any project.
% % handles.Settings.commonPathField.Value=commonPath;
% % % All stats tables UI tree
% % handles.Stats.sortStatsTablesDropDown.Value=guiSettings.Stats.SortMethod.StatsTables;
% % sortUITree(handles.Stats.allStatsTablesUITree,handles.Stats.sortStatsTablesDropDown.Value);
% % % All pub tables UI tree
% % handles.Stats.sortPubTablesDropDown.Value=guiSettings.Stats.SortMethod.PubTables;
% % sortUITree(handles.Stats.allPubTablesUITree,handles.Stats.sortPubTablesDropDown.Value);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Settings tab
%% Load the list of all users, put them into the users dropdown
sqlquery = ['SELECT Username FROM Users'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if ~iscell(t.Username)
    t.Username = {t.Username};
end
handles.Settings.usersDropDown.Items = t.Username;
handles.Settings.usersDropDown.Value = getCurrent('Current_User');

%% Put the DB file path into the edit field
dbFile=getCurrent('DBFile');
handles.Settings.dbFilePathEditField.Value=dbFile;

Current_Tab_Title = getCurrent('Current_Tab_Title');
handles.Tabs.tabGroup1.SelectedTab=handles.(Current_Tab_Title).Tab;
tabGroup1SelectionChanged(fig); % To allow the variables tab to change parent as needed.