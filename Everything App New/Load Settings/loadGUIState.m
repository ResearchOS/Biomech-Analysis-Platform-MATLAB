function []=loadGUIState(fig)

%% PURPOSE: LOAD THE GUI STATE
handles=getappdata(fig,'handles');

%% NEED TO ENSURE THAT THE PROPER ENTRIES IN THE UITREES ARE SELECTED FOR THE BELOW CODE TO WORK.

Current_Project_Name = getCurrent('Current_Project_Name');
% projectStruct = loadJSON(Current_Project_Name);


%% Fill the UI trees with their correct values
% sortDropDowns=[handles.Projects.sortProjectsDropDown; handles.Import.sortLogsheetsDropDown; 
%     handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
%     handles.Plot.sortPlotsDropDown; handles.Plot.sortComponentsDropDown;
%     handles.Process.sortGroupsDropDown; handles.Process.sortAnalysesDropDown];
% uiTrees=[handles.Projects.allProjectsUITree; handles.Import.allLogsheetsUITree;
%     handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
%     handles.Plot.allPlotsUITree; handles.Plot.allComponentsUITree;
%     handles.Process.allGroupsUITree; handles.Process.allAnalysesUITree];
% classNamesUITrees={'Project','Logsheet',...
%     'Variable','Process',...
%     'Plot','Component',...
%     'ProcessGroup','Analysis'};
% REMOVED PLOT & COMPONENTS
sortDropDowns=[handles.Projects.sortProjectsDropDown; handles.Import.sortLogsheetsDropDown; 
    handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Process.sortGroupsDropDown; handles.Process.sortAnalysesDropDown];
uiTrees=[handles.Projects.allProjectsUITree; handles.Import.allLogsheetsUITree;
    handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Process.allGroupsUITree; handles.Process.allAnalysesUITree];
classNamesUITrees={'Project','Logsheet',...
    'Variable','Process',...
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
% Bring up the current project's project & data paths.
selectNode(handles.Projects.allProjectsUITree, Current_Project_Name);
allProjectsUITreeSelectionChanged(fig);
currentProjectButtonPushed(fig);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Import tab
Current_Logsheet = getCurrent('Current_Logsheet');
if ~isempty(Current_Logsheet)
    selectNode(handles.Import.allLogsheetsUITree, Current_Logsheet);
    % % Bring up the current logsheet's metadata.
    allLogsheetsUITreeSelectionChanged(fig, true);
end
 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Process tab
queue = getCurrent('Process_Queue');
queueNames = getName(queue);
for i=1:length(queue)
    addNewNode(handles.Process.queueUITree, queue{i}, queueNames{i});
end

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
%% Put the common path into the edit field
commonPath=getCurrent('commonPath');
handles.Settings.commonPathEditField.Value=commonPath;

Current_Tab_Title = getCurrent('Current_Tab_Title');
handles.Tabs.tabGroup1.SelectedTab=handles.(Current_Tab_Title).Tab;
tabGroup1SelectionChanged(fig); % To allow the variables tab to change parent as needed.