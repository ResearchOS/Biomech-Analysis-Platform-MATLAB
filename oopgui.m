function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION

slash=filesep;

classNames={'Variable','Plot','PubTable','StatsTable','Component','Project','Process'}; % One folder for each object type

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is currently not supported');
    return;
end

%% Create the figure
fig=uifigure('Name','pgui',...
    'Visible','on',...
    'Resize','on',...
    'AutoResizeChildren','off',...
    'SizeChangedFcn',@appResize);
set(fig,'DeleteFcn',@(fig, event) saveGUIState(fig));

% Put all of the components in their place
handles=initializeComponents(fig);

setappdata(fig,'handles',handles);
setappdata(fig,'classNames',classNames);

assignin('base','gui',fig); % Put the GUI object into the base workspace.

% The common path, which contains all the instances of the settings
% variables. This path should be in its own GitHub repository.
commonPath=getCommonPath(fig);

%% Load all existing settings for objects/classes (i.e. not GUI object settings)
% Stored in the user-specified common path
for i=1:length(classNames)
    class=classNames{i};
    classFolder=[commonPath slash class];

    classVar=loadClassVar(classFolder);
    setappdata(fig,class,classVar); % Store the class data to the figure. Empty structs indicate that there were no files in that folder.
end

%% Fill the UI trees with their correct values
uiTrees=[handles.Process.allVarsUITree, handles.Plot.allPlotsUITree, ...
    handles.Stats.allPubTablesUITree, handles.Stats.allStatsTablesUITree, ...
    handles.Plot.allComponentsUITree, handles.Stats.allVarsUITree, ...
    handles.Project.allProjectsUITree, handles.Import.allLogsheetsUITree];
classNamesUITrees={'Variable','Plot','PubTable','StatsTable','Component','Variable','Project','Logsheet'}; % One folder for each object type

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    
    fillUITree(fig, class, uiTree);    
end

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
% Stored in a subfolder of the userpath
loadGUIState(fig);