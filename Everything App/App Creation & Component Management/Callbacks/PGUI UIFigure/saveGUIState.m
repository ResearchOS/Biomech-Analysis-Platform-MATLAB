function []=saveGUIState(fig)

%% PURPOSE: SAVE THE SETTINGS VARIABLES TO THE MAT FILE WHEN CLOSING THE GUI TO SAVE ALL PROGRESS.
% GETS RID OF THE NEED TO SAVE ALL SETTINGS AT EVERY STEP.

fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');

VariableNamesList=getappdata(fig,'VariableNamesList');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
Plotting=getappdata(fig,'Plotting');
Stats=getappdata(fig,'Stats');

varsList={'VariableNamesList','Digraph','NonFcnSettingsStruct','Plotting','Stats'};

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

if isempty(Stats)
    varsList=varsList(~ismember(varsList,'Stats'));
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
if exist(projectSettingsMATPath,'file')~=2 || isempty(varsList)
    disp('Nothing saved upon exit!');
    return;
end

%% Delete all of the handles from Plotting struct so that it can be saved and loaded properly.
if ~isempty(Plotting)
    plotNames=fieldnames(Plotting.Plots);
    for plotNum=1:length(plotNames)
        plotName=plotNames{plotNum};
        compNames=fieldnames(Plotting.Plots.(plotName));
        compNames=compNames(~ismember(compNames,{'Movie','Metadata','SpecifyTrials','ExTrial'}));
        for compNum=1:length(compNames)
            compName=compNames{compNum};
            letters=fieldnames(Plotting.Plots.(plotName).(compName));
            for letNum=1:length(letters)
                letter=letters{letNum};
                disp([plotName ' ' compName ' ' letter]);
                Plotting.Plots.(plotName).(compName).(letter).Handle=[];
            end
        end

    end
end

save(projectSettingsMATPath,varsList{:},'-append');

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