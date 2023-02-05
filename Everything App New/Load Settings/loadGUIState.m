function []=loadGUIState(fig)

%% PURPOSE: LOAD THE GUI STATE
handles=getappdata(fig,'handles');

%% NEED TO ENSURE THAT THE PROPER ENTRIES IN THE UITREES ARE SELECTED FOR THE BELOW CODE TO WORK.

rootSettingsFile=getRootSettingsFile();
projectPath=getProjectPath(1);
if ~isempty(projectPath)
    projectSettingsFile=getProjectSettingsFile();
    projectSettings=loadJSON(projectSettingsFile);
end

fillUITree_SpecifyTrials(fig); % Fill in the specify trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Projects tab
load(rootSettingsFile,'Current_Project_Name');
selectNode(handles.Projects.allProjectsUITree, Current_Project_Name);

% Bring up the current project's project & data paths.
allProjectsUITreeSelectionChanged(fig);
currentProjectButtonPushed(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Import tab
% Bring up the current logsheet's metadata.
allLogsheetsUITreeSelectionChanged(fig);
% fillHeadersUITree(fig);
% All logsheets UI Tree
% handles.Import.sortLogsheetsDropDown.Value=guiSettings.Import.SortMethod;
% sortUITree(handles.Import.allLogsheetsUITree,handles.Import.sortLogsheetsDropDown.Value);
% currLogsheetNode=findobj(handles.Import.allLogsheetsUITree,'Text',guiSettings.Import.CurrentLogsheet);
% handles.Import.allLogsheetsUITree.SelectedNodes=currLogsheetNode;
% allLogsheetsUITreeSelectionChanged(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process tab
if ~isempty(projectPath)
    handles.Process.currentGroupLabel.Text=projectSettings.Current_ProcessGroup_Name;
    fillProcessGroupUITree(fig);
    % Fill in queue.
    % TODO: initialize the "ProcessQueue" field when the
    % "Current_ProcessGroup_Name" field is initialized so I don't have to check if the field exists.
    if isfield(projectSettings,'ProcessQueue')
        for i=1:length(projectSettings.ProcessQueue)
            uitreenode(handles.Process.queueUITree,'Text',projectSettings.ProcessQueue{i});
        end
    end
end
% allVariablesUITreeSelectionChanged(fig);
% allProcessUITreeSelectionChanged(fig);
% allGroupsUITreeSelectionChanged(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot tab
if ~isempty(projectPath)
    handles.Plot.currentPlotLabel.Text=projectSettings.Current_Plot_Name;
    fillPlotUITree(fig);
end
% allPlotsUITreeSelectionChanged(fig);
% allComponentsUITreeSelectionChanged(fig);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Settings tab
%% Put the common path into the edit field
commonPath=getCommonPath();
handles.Settings.commonPathEditField.Value=commonPath;

load(rootSettingsFile,'Store_Settings');
handles.Settings.storeSettingsCheckbox.Value=Store_Settings;