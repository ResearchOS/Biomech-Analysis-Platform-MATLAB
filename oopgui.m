function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
tic;
slash=filesep;

classNames={'Variable','Plot','PubTable','StatsTable','Component','Project','Process','Logsheet'}; % One folder for each object type

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is currently not supported');
    return;
end

%% Add all of the appropriate paths to MATLAB search path
currFolder=fileparts(mfilename('fullpath'));
addpath(genpath(currFolder));

rmpath(genpath('/Users/mitchelltillman/Desktop/Stevens_Classes_Research/MATLAB_Code/GitRepos/Biomech-Analysis-Platform/Everything App'));

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

%% Get the "common path"
% The common path, which contains all the instances of the settings
% variables. This path should be in its own GitHub repository.
commonPath=getCommonPath(fig);
addpath(genpath(commonPath)); % Ensure that the class folders are on the search path.

handles.Settings.commonPathEditField.Value=commonPath;

rmpath(genpath('/Users/mitchelltillman/Desktop/Stevens_Classes_Research/MATLAB_Code/GitRepos/Biomech-Analysis-Platform/Everything App'));

%% If there are no existing project settings files, then create a 'Default' project
projects=getClassFilenames(fig,'Project');
if isempty(projects)
    createProjectStruct(fig,'Default');
end

%% Load all existing settings for objects/classes (i.e. not GUI object settings)
% Stored in the user-specified common path
for i=1:length(classNames)
    class=classNames{i};
    classFolder=[commonPath slash class];

    classVar=loadClassVar(fig,classFolder);
    setappdata(fig,class,classVar); % Store the class data to the figure. Empty structs indicate that there were no files in that folder.
end

%% Fill the UI trees with their correct values
sortDropDowns=[handles.Projects.sortProjectsDropDown; handles.Import.sortLogsheetsDropDown];
% uiTrees=[handles.Process.allVarsUITree, handles.Plot.allPlotsUITree, ...
%     handles.Stats.allPubTablesUITree, handles.Stats.allStatsTablesUITree, ...
%     handles.Plot.allComponentsUITree, handles.Stats.allVarsUITree, ...
%     handles.Project.allProjectsUITree, handles.Import.allLogsheetsUITree];
uiTrees=[handles.Projects.allProjectsUITree; handles.Import.allLogsheetsUITree];
% classNamesUITrees={'Variable','Plot','PubTable','StatsTable','Component','Variable','Project','Logsheet'}; % One folder for each object type
classNamesUITrees={'Project','Logsheet'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
end

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
% Stored in a subfolder of the userpath
loadGUIState(fig);

drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);