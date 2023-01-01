function []=loadGUIState(fig)

%% PURPOSE: LOAD THE GUI STATE
handles=getappdata(fig,'handles');

% slash=filesep;

% rootSettingsFolder=[userpath slash 'PGUI Settings'];
% rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];
% 
% load(rootSettingsFile,'commonPath'); % The folder where all of the project-independent custom settings are stored
% warning('off','MATLAB:load:variableNotFound');
% load(rootSettingsFile,'guiSettings'); % The settings for all of the GUI objects not set by the data itself 
% warning('on','MATLAB:load:variableNotFound');
% 
% if exist('guiSettings','var')~=1
%     saveGUIState(fig); % Initialize the GUI settings saved to .mat file
%     return;
% end

%% NEED TO ENSURE THAT THE PROPER ENTRIES IN THE UITREES ARE SELECTED FOR THE BELOW CODE TO WORK.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Projects tab
currentProjectButtonPushed(fig);

% Bring up the current project's project & data paths.
allProjectsUITreeSelectionChanged(fig);


% currProject=handles.Projects.projectsLabel.Text;
% project=getappdata(fig,'Project');
% projectIdx=ismember({project.Text},currProject);
% 
% computerID=getComputerID();
% 
% handles.Projects.projectPathField.Value=project(projectIdx).ProjectPath.(computerID);
% handles.Projects.dataPathField.Value=project(projectIdx).DataPath.(computerID);
% 
% 
% handles.Projects.sortProjectsDropDown.Value=guiSettings.Projects.SortMethod;
% sortUITree(handles.Projects.allProjectsUITree,handles.Projects.sortProjectsDropDown.Value);
% currProjNode=findobj(handles.Projects.allProjectsUITree,'Text',guiSettings.Projects.CurrentProject);
% handles.Projects.allProjectsUITree.SelectedNodes=currProjNode;
% 
% checkedNodes=findobj(handles.Projects.allProjectsUITree,'Text',guiSettings.Projects.CheckedProjects);
% handles.Projects.allProjectsUITree.CheckedNodes=checkedNodes;
% allProjectsUITreeCheckedNodesChanged(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import tab
% Bring up the current logsheet's metadata.
allLogsheetsUITreeSelectionChanged(fig);
% All logsheets UI Tree
% handles.Import.sortLogsheetsDropDown.Value=guiSettings.Import.SortMethod;
% sortUITree(handles.Import.allLogsheetsUITree,handles.Import.sortLogsheetsDropDown.Value);
% currLogsheetNode=findobj(handles.Import.allLogsheetsUITree,'Text',guiSettings.Import.CurrentLogsheet);
% handles.Import.allLogsheetsUITree.SelectedNodes=currLogsheetNode;
% allLogsheetsUITreeSelectionChanged(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process tab
% All variables UI tree
% handles.Process.sortVariablesDropDown.Value=guiSettings.Process.SortMethod;
% sortUITree(handles.Process.allVarsUITree,handles.Process.sortVariablesDropDown.Value);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot tab
% All components UI tree
% handles.Plot.sortComponentsDropDown.Value=guiSettings.Plot.SortMethod.Components;
% sortUITree(handles.Plot.allComponentsUITree,handles.Plot.sortComponentsDropDown.Value);
% % All plots UI tree
% handles.Plot.sortPlotsDropDown.Value=guiSettings.Plot.SortMethod.Plots;
% sortUITree(handles.Plot.allPlotsUITree,handles.Plot.sortPlotsDropDown.Value);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Stats tab
% The common path where all of the custom settings are stored independent
% of any project.
% handles.Settings.commonPathField.Value=commonPath;
% % All stats tables UI tree
% handles.Stats.sortStatsTablesDropDown.Value=guiSettings.Stats.SortMethod.StatsTables;
% sortUITree(handles.Stats.allStatsTablesUITree,handles.Stats.sortStatsTablesDropDown.Value);
% % All pub tables UI tree
% handles.Stats.sortPubTablesDropDown.Value=guiSettings.Stats.SortMethod.PubTables;
% sortUITree(handles.Stats.allPubTablesUITree,handles.Stats.sortPubTablesDropDown.Value);

