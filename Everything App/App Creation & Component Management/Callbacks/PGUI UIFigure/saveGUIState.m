function []=saveGUIState(fig)

%% PURPOSE: SAVE THE SETTINGS VARIABLES TO THE MAT FILE WHEN CLOSING THE GUI TO SAVE ALL PROGRESS.
% GETS RID OF THE NEED TO SAVE ALL SETTINGS AT EVERY STEP.

handles=getappdata(fig,'handles');

slash=filesep;

rootSettingsFolder=[userpath slash 'PGUI Settings'];
rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];

evalin('base','clear gui;');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Projects tab
% guiSettings.Projects.SortMethod=handles.Projects.sortProjectsDropDown.Value;
% if isempty(handles.Projects.allProjectsUITree.SelectedNodes)
%     guiSettings.Projects.CurrentProject='';
% else
%     guiSettings.Projects.CurrentProject=handles.Projects.allProjectsUITree.SelectedNodes.Text;
% end
% 
% if isempty(handles.Projects.allProjectsUITree.CheckedNodes)
%     guiSettings.Projects.CheckedProjects={};
% else
%     guiSettings.Projects.CheckedProjects={handles.Projects.allProjectsUITree.CheckedNodes.Text};
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Import tab
% guiSettings.Import.SortMethod=handles.Import.sortLogsheetsDropDown.Value;
% if isempty(handles.Import.allLogsheetsUITree.SelectedNodes)
%     guiSettings.Import.CurrentLogsheet='';
% else
%     guiSettings.Import.CurrentLogsheet=handles.Import.allLogsheetsUITree.SelectedNodes.Text;
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Process tab
% guiSettings.Process.SortMethod=handles.Process.sortVariablesDropDown.Value;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Plot tab
% guiSettings.Plot.SortMethod.Components=handles.Plot.sortComponentsDropDown.Value;
% guiSettings.Plot.SortMethod.Plots=handles.Plot.sortPlotsDropDown.Value;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Stats tab
% guiSettings.Stats.SortMethod.StatsTables=handles.Stats.sortStatsTablesDropDown.Value;
% guiSettings.Stats.SortMethod.PubTables=handles.Stats.sortPubTablesDropDown.Value;
% 
% try
%     save(rootSettingsFile,'guiSettings','-append');
% catch
%     save(rootSettingsFile,'guiSettings','-v6');
% end