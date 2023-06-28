function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
tic;

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is not supported');
    return;
end

%% Add all of the appropriate paths to MATLAB search path
currFolder=fileparts(mfilename('fullpath'));
addpath(genpath(currFolder));

%% Create the figure
fig=uifigure('Name','pgui','Visible','on',...
    'Resize','on','AutoResizeChildren','off','SizeChangedFcn',@appResize);
set(fig,'DeleteFcn',@(fig, event) saveGUIState(fig));

% Put all of the components in their place
handles=initializeComponents(fig);

setappdata(fig,'handles',handles);

assignin('base','gui',fig); % Put the GUI object into the base workspace.

%% Get the "common path". This is the folder containing project-independent instances of settings class variables.
% This path should be in its own GitHub repository.
initializeClassFolders();

%% If there are no existing project settings files, then create a 'Default' project
% 1. Does root settings file exist? YES BECAUSE THE COMMON PATH HAS BEEN SET
% 2. Does Current_Project_Name exist in the root settings file?
% 3. Is there a PI projectStruct file?
rootSettingsFile=getRootSettingsFile();
settingsVarNames=whos('-file',rootSettingsFile);
settingsVarNames={settingsVarNames.name};

% 3.
projects=getClassFilenames('Project',false);
if isempty(projects)
    projectStruct=createProjectStruct('Default');  
    Current_Project_Name=projectStruct.Text;
    save(rootSettingsFile,'Current_Project_Name','-append');
    settingsVarNames=[settingsVarNames {'Current_Project_Name'}];
end

% 2.
if ~ismember('Current_Project_Name',settingsVarNames)
    projects=getClassFilenames('Project');
    [name,abstractID,instanceID]=deText(projects{1});
    Current_Project_Name=projects{1};
    Current_Project_Name=Current_Project_Name(9:end-5); % Remove 'Project' prefix and '.json' suffix
    save(rootSettingsFile,'Current_Project_Name','-append');
end

%% Initialize the project settings file for the current project.
projectSettingsFile=getProjectSettingsFile(); % File stores the current analysis name
if ~isempty(projectSettingsFile)
    initProjectSettingsFile(projectSettingsFile);
end

%% Check if this is the first time using this computer, ensure the computer-specific fields exist.
if ~ismember('Computer_ID',settingsVarNames)
    Computer_ID=getComputerID();    
else
    load(rootSettingsFile,'Computer_ID');
end
newComputerProjectPaths(Computer_ID);

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

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
% Stored in a subfolder of the userpath
loadGUIState(fig);

% Runs only the first time that this app is ever used, or just after
% deleting the root settings file.
if ~ismember('Current_Tab_Title',settingsVarNames)
    Current_Tab_Title='Projects';
    save(rootSettingsFile,'Current_Tab_Title','-append');
end

load(rootSettingsFile,'Current_Tab_Title');

handles.Tabs.tabGroup1.SelectedTab=handles.(Current_Tab_Title).Tab;
tabGroup1SelectionChanged(fig); % To allow the variables tab to change parent as needed.
drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);