function []=loadGUIState(fig)

%% PURPOSE: LOAD THE GUI STATE
handles=getappdata(fig,'handles');

%% NEED TO ENSURE THAT THE PROPER ENTRIES IN THE UITREES ARE SELECTED FOR THE BELOW CODE TO WORK.

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
projectStruct = loadJSON(Current_Project_Name);


%% Fill the UI trees with their correct values
sortDropDowns=[handles.Projects.sortProjectsDropDown; handles.Import.sortLogsheetsDropDown; 
    handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Plot.sortPlotsDropDown; handles.Plot.sortComponentsDropDown;
    handles.Process.sortGroupsDropDown; handles.Process.sortAnalysesDropDown];
uiTrees=[handles.Projects.allProjectsUITree; handles.Import.allLogsheetsUITree;
    handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Plot.allPlotsUITree; handles.Plot.allComponentsUITree;
    handles.Process.allGroupsUITree; handles.Process.allAnalysesUITree];
classNamesUITrees={'Project','Logsheet',...
    'Variable','Process',...
    'Plot','Component',...
    'ProcessGroup','Analysis'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
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
selectNode(handles.Import.allLogsheetsUITree, projectStruct.Current_Logsheet);
% Bring up the current logsheet's metadata.
allLogsheetsUITreeSelectionChanged(fig, true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process tab
if ~isempty(projectPath)
    handles.Process.currentAnalysisLabel.Text=projectStruct.Current_Analysis;

    for i=1:length(projectStruct.Process_Queue)
        uitreenode(handles.Process.queueUITree,'Text',projectStruct.Process_Queue{i});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot tab
% if ~isempty(projectPath)
%     handles.Plot.currentPlotLabel.Text=projectSettings.Current_Plot_Name;
%     fillPlotUITree(fig);
%     plotPath=getClassFilePath(projectSettings.Current_Plot_Name,'Plot');
%     plotStruct=loadJSON(plotPath);
%     specifyTrialsPlot=plotStruct.SpecifyTrials;
%     checkSpecifyTrialsUITree(specifyTrialsPlot,handles.Plot.allSpecifyTrialsUITree);
% end
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

load(rootSettingsFile,'Current_Tab_Title');

handles.Tabs.tabGroup1.SelectedTab=handles.(Current_Tab_Title).Tab;
tabGroup1SelectionChanged(fig); % To allow the variables tab to change parent as needed.