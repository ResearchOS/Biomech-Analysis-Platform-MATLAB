function []=saveGUIState(fig)

%% PURPOSE: SAVE THE SETTINGS VARIABLES TO THE MAT FILE WHEN CLOSING THE GUI TO SAVE ALL PROGRESS.
% GETS RID OF THE NEED TO SAVE ALL SETTINGS AT EVERY STEP.

fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');

VariableNamesList=getappdata(fig,'VariableNamesList');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
Plotting=getappdata(fig,'Plotting');

varsList={'VariableNamesList','Digraph','NonFcnSettingsStruct','Plotting'};

if isempty(VariableNamesList)
    varsList=varsList(~ismember(varsList,'VariableNamesList'));
end

if isempty(Digraph)
    varsList=varsList(~ismember(varsList,'Digraph'));
end

if isempty(NonFcnSettingsStruct)
    varsList=varsList(~ismember(varsList,'NonFcnSettingsStruct'));
end

if isempty(Plotting)
    varsList=varsList(~ismember(varsList,'Plotting'));
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

save(projectSettingsMATPath,'VariableNamesList',varsList{:},'-append');

%% SAVE THE CURRENT PLOT
if ~isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    slash=filesep;
    Q=figure('Visible','off');
    set(handles.Plot.plotPanel.Children,'Parent',Q);
    plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;
    codePath=getappdata(fig,'codePath');

    folderName=[codePath  'Plot' slash 'Stashed GUI Plots'];
    if ~isfolder(folderName)
        mkdir(folderName);
    end
    saveas(Q,[folderName slash plotName '.fig']);
end

% Remove the PGUI variable from the workspace now that it is closed.
evalin('base','clear gui;');