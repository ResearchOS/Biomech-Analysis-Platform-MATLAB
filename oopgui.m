function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
% global gui;

slash=filesep;

a=evalin('base','whos;');
classes={a.class};
if ismember('GUI',classes)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is currently not supported');
    return;
end

gui = GUI; % Create the GUI object. Includes figure handle and handles for all components.
assignin('base','gui',gui); % Put the GUI object into the base workspace.

settingsPath=getSettingsPath(); % The path to the PGUI settings variables

handles=gui.handles;

%% Fill the UI trees with their correct values
classNames={'Variable','Plot','PubTable','StatsTable','Component'};
uiTrees=[handles.Process.fcnArgsUITree, ...
    handles.Plot.plotFcnUITree, handles.Stats.pubTablesUITree, handles.Stats.tablesUITree, handles.Plot.allComponentsUITree];
selChangedFcns={};

for i=1:length(classNames)
    class=classNames{i};
    uiTree=uiTrees(i);

    classFolder=[settingsPath slash class];
    fillUITree(classFolder, uiTree);
    feval(selChangedFcns{i},gui);
end